require 'test_helper'

class Admin::Budgets::ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_budgets_image = admin_budgets_images(:one)
  end

  test "should get index" do
    get admin_budgets_images_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_budgets_image_url
    assert_response :success
  end

  test "should create admin_budgets_image" do
    assert_difference('Admin::Budgets::Image.count') do
      post admin_budgets_images_url, params: { admin_budgets_image: { filename: @admin_budgets_image.filename, image_id: @admin_budgets_image.image_id } }
    end

    assert_redirected_to admin_budgets_image_url(Admin::Budgets::Image.last)
  end

  test "should show admin_budgets_image" do
    get admin_budgets_image_url(@admin_budgets_image)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_budgets_image_url(@admin_budgets_image)
    assert_response :success
  end

  test "should update admin_budgets_image" do
    patch admin_budgets_image_url(@admin_budgets_image), params: { admin_budgets_image: { filename: @admin_budgets_image.filename, image_id: @admin_budgets_image.image_id } }
    assert_redirected_to admin_budgets_image_url(@admin_budgets_image)
  end

  test "should destroy admin_budgets_image" do
    assert_difference('Admin::Budgets::Image.count', -1) do
      delete admin_budgets_image_url(@admin_budgets_image)
    end

    assert_redirected_to admin_budgets_images_url
  end
end
