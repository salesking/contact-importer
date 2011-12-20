class DataRow < ActiveRecord::Base
  belongs_to :import
  
  attr_writer :data

  scope :failed, where(sk_id: nil)
  scope :success, where("data_rows.sk_id IS NOT NULL")
  
  before_save :populate_client
  
  private
  
  def populate_client
    client = Sk::Client.new
    address = Sk::Address.new

    import.attachment.mapping.mapping_elements.each do |mapping_element|
      value = mapping_element.convert(@data)
      if mapping_element.target.match(/^address\./)
        field_name = mapping_element.target[/\.(.*)$/, 1]
        address.send("#{field_name}=", value)
      else
        client.send("#{mapping_element.target}=", value)
      end
    end
    client.addresses = [address]

    if client.save
      self.sk_id = client.id
    else
      self.source = @data.to_csv(col_sep: import.attachment.col_sep, quote_char: import.attachment.quote_char)
      self.log = client.errors.full_messages.to_sentence
    end
  end
end
