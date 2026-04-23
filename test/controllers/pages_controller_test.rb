require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in @user = users(:family_admin)
  end

  test "dashboard" do
    get root_path
    assert_response :ok
  end

  test "changelog renders from CHANGELOG.md" do
    get changelog_path
    assert_response :ok
  end

  test "changelog renders fallback when file is missing" do
    File.stubs(:exist?).returns(false)
    get changelog_path
    assert_response :ok
    assert_select "p", text: /No changelog entries yet/
  end
end
