class Company < ActiveRecord::Base
  has_many :users
  has_many :imports
  has_many :mappings
end
