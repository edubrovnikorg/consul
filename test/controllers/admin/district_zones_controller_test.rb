require 'test_helper'

class Admin::DistrictZonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_district_zone = admin_district_zones(:one)
  end

  test "should get index" do
    get admin_district_district_zones_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_district_zone_url
    assert_response :success
  end

  test "should create admin_district_zone" do
    assert_difference('Admin::DistrictZone.count') do
      post admin_district_district_zones_url, params: { admin_district_zone: {  } }
    end

    assert_redirected_to admin_district_zone_url(Admin::DistrictZone.last)
  end

  test "should show admin_district_zone" do
    get admin_district_zone_url(@admin_district_zone)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_district_zone_url(@admin_district_zone)
    assert_response :success
  end

  test "should update admin_district_zone" do
    patch admin_district_zone_url(@admin_district_zone), params: { admin_district_zone: {  } }
    assert_redirected_to admin_district_zone_url(@admin_district_zone)
  end

  test "should destroy admin_district_zone" do
    assert_difference('Admin::DistrictZone.count', -1) do
      delete admin_district_zone_url(@admin_district_zone)
    end

    assert_redirected_to admin_district_district_zones_url
  end
end
