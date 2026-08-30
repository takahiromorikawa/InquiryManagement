require "test_helper"

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  # --- POST /inquiries（認証不要 / UC1） ---------------------------------

  test "POST /inquiries は問い合わせを登録し 201 と登録内容を返す" do
    assert_difference -> { Inquiry.count }, 1 do
      post inquiries_url, params: {
        name: "顧客 花子",
        company: "花子物産株式会社",
        email: "hanako@example.com",
        subject: "料金プランについて",
        body: "詳しい料金体系を教えてください。"
      }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert body["id"].present?
    assert_equal "顧客 花子", body["name"]
    assert_equal "花子物産株式会社", body["company"]
    assert_equal "料金プランについて", body["subject"]
    assert_equal "unhandled", body["status"], "作成時のステータスは常に unhandled"
    assert_equal [], body["replies"]
  end

  test "必須項目が欠けていると 422 を返し、登録しない" do
    assert_no_difference -> { Inquiry.count } do
      post inquiries_url, params: { name: "", company: "", email: "", subject: "", body: "" }, as: :json
    end

    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].present?
  end

  test "会社名が未入力だと 422 を返す" do
    assert_no_difference -> { Inquiry.count } do
      post inquiries_url, params: {
        name: "顧客", email: "c@example.com", subject: "件名", body: "本文"
      }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test "許可外のパラメータ（status）は無視される" do
    post inquiries_url, params: {
      name: "顧客", company: "顧客商事", email: "c@example.com", subject: "件名", body: "本文",
      status: "completed"
    }, as: :json

    assert_response :created
    assert_equal "unhandled", response.parsed_body["status"]
  end

  # --- GET /inquiries（認証必須 / UC3） ---------------------------------

  test "GET /inquiries は未ログインだと 401" do
    get inquiries_url
    assert_response :unauthorized
  end

  test "GET /inquiries はログイン済みなら一覧を受信日時の新しい順で返す" do
    login_as staffs(:yamada)
    get inquiries_url

    assert_response :success
    list = response.parsed_body
    assert_equal Inquiry.count, list.size
    assert_equal %w[id subject name company status created_at].sort, list.first.keys.sort
    assert_equal inquiries(:unhandled_inquiry).id, list.first["id"], "新しい順の先頭"
    assert_equal inquiries(:in_progress_inquiry).id, list.last["id"]
  end

  # --- GET /inquiries/:id（認証必須 / UC4） ----------------------------

  test "GET /inquiries/:id は未ログインだと 401" do
    get inquiry_url(inquiries(:in_progress_inquiry))
    assert_response :unauthorized
  end

  test "GET /inquiries/:id は本体と返信スレッド（担当者名つき・古い順）を返す" do
    login_as staffs(:yamada)
    get inquiry_url(inquiries(:in_progress_inquiry))

    assert_response :success
    body = response.parsed_body
    assert_equal "高橋 次郎", body["name"]
    assert_equal "高橋商店", body["company"]
    assert_equal "takahashi@example.com", body["email"]
    assert_equal "in_progress", body["status"]

    replies = body["replies"]
    assert_equal 2, replies.size
    assert_equal ["お問い合わせありがとうございます。確認いたします。",
                  "宛名を修正した請求書を再送しました。"], replies.map { |r| r["body"] }
    assert_equal ["山田 太郎", "佐藤 花子"], replies.map { |r| r["staff"] }
  end

  test "GET /inquiries/:id は存在しないIDで 404" do
    login_as staffs(:yamada)
    get inquiry_url(id: 999_999)
    assert_response :not_found
  end

  # --- PATCH /inquiries/:id（認証必須 / UC6） --------------------------

  test "PATCH /inquiries/:id は未ログインだと 401" do
    inquiry = inquiries(:unhandled_inquiry)
    patch inquiry_url(inquiry), params: { status: "in_progress" }, as: :json
    assert_response :unauthorized
    assert_equal "unhandled", inquiry.reload.status
  end

  test "PATCH /inquiries/:id はステータスを更新し、更新後の詳細を返す" do
    login_as staffs(:yamada)
    inquiry = inquiries(:unhandled_inquiry)

    patch inquiry_url(inquiry), params: { status: "completed" }, as: :json

    assert_response :success
    assert_equal "completed", response.parsed_body["status"]
    assert_equal "completed", inquiry.reload.status
    assert response.parsed_body.key?("replies")
  end

  test "PATCH /inquiries/:id は対応済みから未対応へ戻せる" do
    login_as staffs(:yamada)
    inquiry = inquiries(:in_progress_inquiry)
    patch inquiry_url(inquiry), params: { status: "unhandled" }, as: :json
    assert_response :success
    assert_equal "unhandled", inquiry.reload.status
  end

  test "PATCH /inquiries/:id は定義外のステータスで 422 を返し変更しない" do
    login_as staffs(:yamada)
    inquiry = inquiries(:unhandled_inquiry)
    patch inquiry_url(inquiry), params: { status: "archived" }, as: :json
    assert_response :unprocessable_entity
    assert_equal "unhandled", inquiry.reload.status
  end

  test "PATCH /inquiries/:id は存在しないIDで 404" do
    login_as staffs(:yamada)
    patch inquiry_url(id: 999_999), params: { status: "completed" }, as: :json
    assert_response :not_found
  end
end
