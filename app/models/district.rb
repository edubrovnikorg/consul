class District < ApplicationRecord
  has_many :district_streets, inverse_of: :district, :dependent => :delete_all

  attr_accessor :district_streets
end
