class Import < ActiveRecord::Base
  has_many :data_rows, dependent: :destroy
  belongs_to :attachment

  scope :by_c, lambda { |company_id| where(company_id: company_id) }
  default_scope order('imports.id desc')
  
  validates :attachment, presence: true
  
  def title
    title = I18n.t('imports.title_success', count: data_rows.success.count)
    if (failed = data_rows.failed.count) > 0
      [title, I18n.t('imports.title_failed', count: failed)].to_sentence
    else
      title
    end
  end

  # TODO: refactor to self.data_row.build(:data => row)
  def create_clients(site, token)
    # setup sk object
    Sk.init(site, token)
    # kick header if present?
    attachment.rows[1..-1].each do |row|
      obj = Sk::Client.new
      # divide client from address fields
      adr_fields = []
      cli_fields = []
      attachment.mapping.mapping_elements.each do |map|
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
        a.source = row.to_csv(col_sep: attachment.col_sep, quote_char: attachment.quote_char)
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