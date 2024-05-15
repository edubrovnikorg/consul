require "application_system_test_case"

class Admin::Budgets::ImagesTest < ApplicationSystemTestCase
  setup do
    @admin_budgets_image = admin_budgets_images(:one)
  end

  test "visiting the index" do
    visit admin_budgets_images_url
    assert_selector "h1", text: "Admin/Budgets/Images"
  end

  test "creating a Image" do
    visit admin_budgets_images_url
    click_on "New Admin/Budgets/Image"

    fill_in "Filename", with: @admin_budgets_image.filename
    fill_in "Image", with: @admin_budgets_image.image_id
    click_on "Create Image"

    assert_text "Image was successfully created"
    click_on "Back"
  end

  test "updating a Image" do
    visit admin_budgets_images_url
    click_on "Edit", match: :first

    fill_in "Filename", with: @admin_budgets_image.filename
    fill_in "Image", with: @admin_budgets_image.image_id
    click_on "Update Image"

    assert_text "Image was successfully updated"
    click_on "Back"
  end

  test "destroying a Image" do
    visit admin_budgets_images_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Image was successfully destroyed"
  end
end
