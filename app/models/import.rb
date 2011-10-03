class Import < ActiveRecord::Base
  belongs_to :company
  has_many :mappings
  has_many :import_data
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
      else
        errors << obj.errors.inspect
        # collect errors and save import-data
      end
    end
    raise errors.inspect unless errors.empty?
  end

end
