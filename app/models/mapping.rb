# Mapping is a container for a set of mapping elements
class Mapping < ActiveRecord::Base
  include UserReference

  has_many :mapping_elements, dependent: :destroy
  has_many :attachments, dependent: :nullify

  default_scope ->{order('mappings.id desc')}

  accepts_nested_attributes_for :mapping_elements
  scope :by_company, lambda {|company_id| where(company_id: company_id)}
  scope :with_fields, -> {joins(:mapping_elements).
                      select('mappings.id, count(mapping_elements.id) as element_count').
                      group('mappings.id'). # fuck up with postgres
                      having('element_count > 0') }

  def title
    I18n.t('mappings.title', count: mapping_elements.count, fields: mapping_elements.collect(&:target).to_sentence)
  end
end
