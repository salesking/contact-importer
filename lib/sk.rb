require 'sk_api_schema'
require 'sk_sdk/base'
class Sk

  # init SalesKing classes and set connection oAuth token
  def self.init(site, token)
    %w{Client Address}.each do |model|
      eval "class #{model} < SK::SDK::Base;end" unless defined?("Sk::#{model.constantize}")
    end
    SK::SDK::Base.set_connection( {:site => site, :token => token} )
  end

  # Construct fields for importing clients.
  #
  # == Returns
  #Array[ { field_name=>{properties} }, ]
  #Array[ { name=>,
  #         kind => } }, ]
  def self.client_fields
    # skip fields that dont make sence
    exclude_cli = ['lock_version', 'team_id', 'addresses', 'due_days', 'cash_discount']
    exclude_adr = ['order', 'address_type', 'address2', 'pobox', 'lat', 'long', '_destroy']
    client_schema = SK::Api::Schema.read('client', '1.0')
    adr_schema = SK::Api::Schema.read('address', '1.0')
    props = []
    client_schema['properties'].each do |name, prop|
      props << { name => prop } unless prop['readonly'] || exclude_cli.include?(name)
    end
    # only one address for now inline
    adr_schema['properties'].each do |name, prop|
      props << { "address.#{name}" => prop } unless prop['readonly'] || exclude_adr.include?(name)
    end
    props
  end

  def self.read_schema(kind)
    # read json-schema
    SK::Api::Schema.read(kind, '1.0')
  end
end
