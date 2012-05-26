module MappingsHelper
  def mapping_options
    Mapping.by_company(session['company_id']).with_fields.map{|m| [m.title, m.id]}
  end
end
