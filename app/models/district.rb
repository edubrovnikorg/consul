class District < ApplicationRecord
  has_many :district_streets, inverse_of: :district
end
