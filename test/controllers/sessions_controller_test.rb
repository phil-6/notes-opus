require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should create session with valid credentials" do
    user = users(:alice)
    post session_url, params: { email_address: user.email_address, password: "password123" }
    assert_redirected_to root_url
  end

  test "should not create session with invalid credentials" do
    post session_url, params: { email_address: "wrong@example.com", password: "wrong" }
    assert_redirected_to new_session_url
  end

  test "should destroy session" do
    user = users(:alice)
    post session_url, params: { email_address: user.email_address, password: "password123" }

    delete session_url
    assert_redirected_to new_session_url
  end
end
