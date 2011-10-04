class Import < ActiveRecord::Base
  belongs_to :company
  has_many :mappings
  has_many :data_rows
  belongs_to :attachment

  scope :by_c, lambda { |company_id| where(:company_id=>company_id) }
  
  accepts_nested_attributes_for :mappings

  attr_accessible :col_sep, :quote_char, :mappings, :name, :kind, 
                  :attachment_id # need to validate belongs to current company

  validates :col_sep, :quote_char,  :presence=>true


  def create_clients(site, token)
    opts = {:col_sep => self.col_sep, :quote_char => self.quote_char }
    data = FasterCSV.read(self.attachment.full_filename, opts)
    # setup sk object
    Sk.init(site, token)
    # kick header if present?
    data[1..-1].each do |row|
      obj = Sk::Client.new
      # divide client from address fields
      adr_fields = []
      cli_fields = []
      mappings.each do |map|
        if map.target.match(/^address\./)
          adr_fields << map
        else
          cli_fields << map
        end
      end
      # assign 
      cli_fields.each do |m|
        # always send the mapping the whole data_row array
        obj.send("#{m.target}=", m.convert(row))
      end
      adr = Sk::Address.new
      adr_fields.each do |a|
        # strip address. prefix from target name .. from end until .
        # => address.city => city
        field_name = a.target[/\.(.*)$/, 1]
        adr.send("#{field_name}=", a.convert(row))
      end
      obj.addresses = [adr]
      if obj.save # to sk
        # create import-data success
        a = self.data_rows.build :sk_id => obj.id
        a.save!
      else
        a = self.data_rows.build
        a.source= row.to_csv(:col_sep=>col_sep, :quote_char=>quote_char)
        a.log = obj.errors.full_messages
        a.save!
      end
    end
  end

  def success?
    data_rows.failed.empty?
  end

end