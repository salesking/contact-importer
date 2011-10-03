class DataRow < ActiveRecord::Base
  belongs_to :import
  scope :failed, where(:sk_id => nil)
end
