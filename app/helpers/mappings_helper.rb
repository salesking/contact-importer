module MappingsHelper
  def mapping_options
    e = Mapping.by_company(session['company_id']).with_fields.map{|m| [m.title, m.id]}
    puts (Mapping.by_company(session['company_id']).with_fields).inspect
    puts e.inspect
    e
  end
end
