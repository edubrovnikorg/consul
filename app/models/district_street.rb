class DistrictStreet < ApplicationRecord
  belongs_to :district, inverse_of: :district_streets
  has_many :district_street_filters, inverse_of: :district_street, :dependent => :delete_all
  accepts_nested_attributes_for :district_street_filters, reject_if: :all_blank, allow_destroy: true
end
