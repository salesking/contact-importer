# A mapping element connects source with targed field. It further does
# a conversion if needed
#
# == Conversions:
# - join: merges multiple incoming fields into a target
# - enum: maps source strings to enum target values
#
# - split: split source field into multiple target fields
#
class MappingElement < ActiveRecord::Base
  CONVERT_TYPES = ['enum', 'date', 'join']

  belongs_to :mapping

  validates :conv_type, inclusion: {in: CONVERT_TYPES, message: "Unknown conversion type %{value}"},
                        allow_blank: true

  #attr_accessible :conv_type, :target, :source, :conv_opts, :import_id

  # === Parameter
  #<Array>:: Source data row
  def convert(data_row)
    if conv_type && self.respond_to?("convert_#{conv_type}")
      self.send("convert_#{conv_type}", data_row)
    else # simple field mapping
      data_row[source.to_i]
    end
  end

  #
  #  convert_opts = {"male":"Herr","female":"Frau"}
  def convert_enum(data_row)
    val = data_row[source.to_i]
    res = parsed_opts.detect {|trg_val, src_val| val == src_val }
    res && res[0]
  end

  def convert_date(data_row)
    val = data_row[source.to_i]
#    if val && val.empty?
    date = Date.strptime(val, parsed_opts['date']) rescue val
    date.is_a?(Date) ? date.strftime("%Y.%m.%d") : val
  end

  # == Params
  # <Array>:. Incomming csv fields
  def convert_join(data_row)
    source_ids = source.split(',').map{|i| i.to_i}
    vals = source_ids.map{ |i| data_row[i] }
    vals.join(' ')
  end

  # ===Returns
  # <Hash>:: parsed(decoded json) conversion options
  def parsed_opts
     ActiveSupport::JSON.decode conv_opts
  end

end
