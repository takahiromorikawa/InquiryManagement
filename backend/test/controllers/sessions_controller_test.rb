require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @staff = staffs(:yamada) }

  test "POST /login は正しい認証情報で 200 と担当者情報を返す" do
    post login_url, params: { email: @staff.email, password: "password" }, as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal @staff.id, body["id"]
    assert_equal @staff.name, body["name"]
    assert_equal @staff.email, body["email"]
    assert_nil body["password_digest"], "パスワードハッシュは返さない"
  end

  test "POST /login はメールアドレスの大文字小文字を区別しない" do
    post login_url, params: { email: @staff.email.upcase, password: "password" }, as: :json
    assert_response :success
  end

  test "POST /login はパスワード誤りで 401 を返す" do
    post login_url, params: { email: @staff.email, password: "wrong" }, as: :json
    assert_response :unauthorized
  end

  test "POST /login は未登録メールアドレスで 401 を返す" do
    post login_url, params: { email: "nobody@example.com", password: "password" }, as: :json
    assert_response :unauthorized
  end

  test "DELETE /logout はログイン後にセッションを破棄して 204 を返す" do
    post login_url, params: { email: @staff.email, password: "password" }, as: :json
    assert_response :success

    delete logout_url
    assert_response :no_content

    # 破棄後は保護対象（logout 自身）が 401
    delete logout_url
    assert_response :unauthorized
  end

  test "DELETE /logout は未ログインだと 401 を返す" do
    delete logout_url
    assert_response :unauthorized
  end
end
