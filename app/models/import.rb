class Import < ActiveRecord::Base

  ##############################################################################
  # Associations
  ##############################################################################
  has_many :mappings, :dependent => :destroy
  has_many :data_rows, :dependent => :destroy
  belongs_to :attachment, :dependent => :destroy
  ##############################################################################
  # Scopes
  ##############################################################################
  scope :by_c, lambda { |company_id| where(:company_id=>company_id) }  
  ##############################################################################
  # Behavior
  ##############################################################################
  accepts_nested_attributes_for :mappings
  attr_accessible :col_sep, :quote_char, :mappings_attributes, :name, :kind,
                  :attachment_id # need to validate belongs to current company
  ##############################################################################
  # Validations
  ##############################################################################
  validates :col_sep,:quote_char,  :presence=>true #:kind,


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
        a.log = obj.errors.full_messages.join(',')
        a.save!
      end
    end
  end

  # An import is successful if no rows failed
  def success?
    data_rows.failed.count == 0
  end

end