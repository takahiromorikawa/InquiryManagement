require "test_helper"

class RepliesControllerTest < ActionDispatch::IntegrationTest
  setup { @inquiry = inquiries(:unhandled_inquiry) }

  test "POST /inquiries/:id/replies は未ログインだと 401" do
    assert_no_difference -> { Reply.count } do
      post inquiry_replies_url(@inquiry), params: { body: "対応します" }, as: :json
    end
    assert_response :unauthorized
  end

  test "POST /inquiries/:id/replies はログイン中の担当者として返信を登録し 201 を返す" do
    login_as staffs(:sato)

    assert_difference -> { @inquiry.replies.count }, 1 do
      post inquiry_replies_url(@inquiry), params: { body: "担当します。少々お待ちください。" }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert body["id"].present?
    assert_equal "担当します。少々お待ちください。", body["body"]
    assert_equal "佐藤 花子", body["staff"], "返信者はログインセッションから特定する"
  end

  test "POST /inquiries/:id/replies は本文が空だと 422 を返し登録しない" do
    login_as staffs(:sato)

    assert_no_difference -> { Reply.count } do
      post inquiry_replies_url(@inquiry), params: { body: "" }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test "POST /inquiries/:id/replies は存在しない問い合わせに対して 404" do
    login_as staffs(:sato)
    post inquiry_replies_url(inquiry_id: 999_999), params: { body: "本文" }, as: :json
    assert_response :not_found
  end

  test "投稿した返信は詳細の replies 末尾に古い順で現れる" do
    login_as staffs(:yamada)
    post inquiry_replies_url(inquiries(:in_progress_inquiry)), params: { body: "追記です" }, as: :json
    assert_response :created

    get inquiry_url(inquiries(:in_progress_inquiry))
    bodies = response.parsed_body["replies"].map { |r| r["body"] }
    assert_equal "追記です", bodies.last
  end
end
