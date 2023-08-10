require 'test_helper'

class Admin::DistrictStreetFiltersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_district_street_filter = admin_district_street_filters(:one)
  end

  test "should get index" do
    get admin_district_street_filters_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_district_street_filter_url
    assert_response :success
  end

  test "should create admin_district_street_filter" do
    assert_difference('Admin::DistrictStreetFilter.count') do
      post admin_district_street_filters_url, params: { admin_district_street_filter: { district_streets_id: @admin_district_street_filter.district_streets_id, from: @admin_district_street_filter.from, to: @admin_district_street_filter.to } }
    end

    assert_redirected_to admin_district_street_filter_url(Admin::DistrictStreetFilter.last)
  end

  test "should show admin_district_street_filter" do
    get admin_district_street_filter_url(@admin_district_street_filter)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_district_street_filter_url(@admin_district_street_filter)
    assert_response :success
  end

  test "should update admin_district_street_filter" do
    patch admin_district_street_filter_url(@admin_district_street_filter), params: { admin_district_street_filter: { district_streets_id: @admin_district_street_filter.district_streets_id, from: @admin_district_street_filter.from, to: @admin_district_street_filter.to } }
    assert_redirected_to admin_district_street_filter_url(@admin_district_street_filter)
  end

  test "should destroy admin_district_street_filter" do
    assert_difference('Admin::DistrictStreetFilter.count', -1) do
      delete admin_district_street_filter_url(@admin_district_street_filter)
    end

    assert_redirected_to admin_district_street_filters_url
  end
end
