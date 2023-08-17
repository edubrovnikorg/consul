class DistrictStreetFilter < ApplicationRecord
  belongs_to :district_street, dependent: :destroy
end
