require "test_helper"

class StaffsControllerTest < ActionDispatch::IntegrationTest
  # --- GET /staffs（管理者のみ / UC8） ---------------------------------

  test "GET /staffs は未ログインだと 401" do
    get staffs_url
    assert_response :unauthorized
  end

  test "GET /staffs は一般担当者だと 403" do
    login_as staffs(:sato)
    get staffs_url
    assert_response :forbidden
  end

  test "GET /staffs は管理者なら担当者一覧を返す" do
    login_as staffs(:yamada)
    get staffs_url

    assert_response :success
    list = response.parsed_body
    assert_equal Staff.count, list.size
    assert_equal %w[id name email admin].sort, list.first.keys.sort
    assert_nil list.first["password_digest"]
  end

  # --- POST /staffs（管理者のみ / UC8） -------------------------------

  test "POST /staffs は一般担当者だと 403 で作成しない" do
    login_as staffs(:sato)
    assert_no_difference -> { Staff.count } do
      post staffs_url, params: { name: "新人", email: "newbie@example.com", password: "password123" }, as: :json
    end
    assert_response :forbidden
  end

  test "POST /staffs は管理者なら担当者を追加する（追加分は一般権限）" do
    login_as staffs(:yamada)

    assert_difference -> { Staff.count }, 1 do
      post staffs_url, params: {
        name: "田中 三郎", email: "tanaka3@example.com", password: "password123"
      }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert_equal "田中 三郎", body["name"]
    assert_equal false, body["admin"], "追加された担当者は管理者ではない"
    assert Staff.find_by(email: "tanaka3@example.com").authenticate("password123")
  end

  test "POST /staffs はメールアドレス重複で 422" do
    login_as staffs(:yamada)
    post staffs_url, params: {
      name: "重複", email: staffs(:sato).email, password: "password123"
    }, as: :json
    assert_response :unprocessable_entity
  end

  test "POST /staffs はパスワードが8文字未満だと 422" do
    login_as staffs(:yamada)
    post staffs_url, params: {
      name: "短パス", email: "shortpw@example.com", password: "short"
    }, as: :json
    assert_response :unprocessable_entity
  end

  test "POST /staffs は氏名が空だと 422" do
    login_as staffs(:yamada)
    post staffs_url, params: { name: "", email: "noname@example.com", password: "password123" }, as: :json
    assert_response :unprocessable_entity
  end
end
