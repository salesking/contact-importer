# Mapping is a container for a set of mapping elements
class Mapping < ActiveRecord::Base
  has_many :mapping_elements, dependent: :destroy
  has_many :attachments, dependent: :nullify
  
  scope :by_c, lambda { |company_id| where(company_id: company_id) }
  
  accepts_nested_attributes_for :mapping_elements
end
