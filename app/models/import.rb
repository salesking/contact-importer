class Import < ActiveRecord::Base
  belongs_to :company
  has_many :mappings
  has_many :data_rows
  belongs_to :attachment

  accepts_nested_attributes_for :mappings

  validates :col_sep, :quote_char,  :presence=>true


  def create_clients(site, token)
    opts = {:col_sep => self.col_sep, :quote_char => self.quote_char }
    data = FasterCSV.read(self.attachment.full_filename, opts)
    errors = []
    # setup sk object
    Sk.init(site, token)
    # kick header if present?
    data[1..-1].each do |i|
      obj = Sk::Client.new
      self.mappings.each do |m|
        # always send the mapping the whole data_row array
        obj.send("#{m.target}=", m.convert(i))
      end
      if obj.save # to sk
        # create import-data success
        a = self.data_rows.build :sk_id => obj.id
        a.save!
      else
        a = self.data_rows.build
        a.source= i.to_csv(:col_sep=>col_sep, :quote_char=>quote_char)
        a.log = obj.errors.full_messages
        a.save!
      end
    end
  end

  def success?
    data_rows.failed.empty?
  end

end