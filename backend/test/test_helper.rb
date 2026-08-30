ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  # 指定の担当者としてログインし、以降のリクエストにセッションCookieを引き継ぐ。
  def login_as(staff, password: "password")
    post login_url, params: { email: staff.email, password: password }, as: :json
    assert_response :success
  end
end
