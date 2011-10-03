class DataRow < ActiveRecord::Base
  belongs_to :import
#  scope :failed # error not nil
end
