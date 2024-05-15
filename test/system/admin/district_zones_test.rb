require "application_system_test_case"

class Admin::DistrictZonesTest < ApplicationSystemTestCase
  setup do
    @admin_district_zone = admin_district_zones(:one)
  end

  test "visiting the index" do
    visit admin_district_district_zones_url
    assert_selector "h1", text: "Admin/District Zones"
  end

  test "creating a District zone" do
    visit admin_district_district_zones_url
    click_on "New Admin/District Zone"

    click_on "Create District zone"

    assert_text "District zone was successfully created"
    click_on "Back"
  end

  test "updating a District zone" do
    visit admin_district_district_zones_url
    click_on "Edit", match: :first

    click_on "Update District zone"

    assert_text "District zone was successfully updated"
    click_on "Back"
  end

  test "destroying a District zone" do
    visit admin_district_district_zones_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "District zone was successfully destroyed"
  end
end
