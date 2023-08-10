require "application_system_test_case"

class Admin::DistrictStreetFiltersTest < ApplicationSystemTestCase
  setup do
    @admin_district_street_filter = admin_district_street_filters(:one)
  end

  test "visiting the index" do
    visit admin_district_street_filters_url
    assert_selector "h1", text: "Admin/District Street Filters"
  end

  test "creating a District street filter" do
    visit admin_district_street_filters_url
    click_on "New Admin/District Street Filter"

    fill_in "District streets", with: @admin_district_street_filter.district_streets_id
    fill_in "From", with: @admin_district_street_filter.from
    fill_in "To", with: @admin_district_street_filter.to
    click_on "Create District street filter"

    assert_text "District street filter was successfully created"
    click_on "Back"
  end

  test "updating a District street filter" do
    visit admin_district_street_filters_url
    click_on "Edit", match: :first

    fill_in "District streets", with: @admin_district_street_filter.district_streets_id
    fill_in "From", with: @admin_district_street_filter.from
    fill_in "To", with: @admin_district_street_filter.to
    click_on "Update District street filter"

    assert_text "District street filter was successfully updated"
    click_on "Back"
  end

  test "destroying a District street filter" do
    visit admin_district_street_filters_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "District street filter was successfully destroyed"
  end
end
