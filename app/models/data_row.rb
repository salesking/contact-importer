class DataRow < ActiveRecord::Base
  belongs_to :import

  attr_writer :data

  scope :failed, -> {where(sk_id: nil)}
  scope :success, -> {where('data_rows.sk_id IS NOT NULL')}

  before_save :populate_contact

  private

  def populate_contact
    contact = Sk::Contact.new
    address = Sk::Address.new

    import.attachment.mapping.mapping_elements.each do |mapping_element|
      value = mapping_element.convert(@data)
      if mapping_element.target.match(/^address\./)
        field_name = mapping_element.target[/\.(.*)$/, 1]
        address.send("#{field_name}=", value)
      else
        contact.send("#{mapping_element.target}=", value)
      end
    end
    contact.addresses = [address]

    if contact.save
      self.sk_id = contact.id
    else
      self.source = @data.to_csv(col_sep: import.attachment.col_sep, quote_char: import.attachment.quote_char)
      self.log = contact.errors.full_messages.to_sentence
    end
  end
end
