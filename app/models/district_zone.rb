class DistrictZone < ApplicationRecord
  belongs_to :district, inverse_of: :district_zones
end
