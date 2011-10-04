class DataRow < ActiveRecord::Base
  belongs_to :import
  scope :failed, where(:sk_id => nil)
  scope :success, where("data_rows.sk_id IS NOT NULL")
end
