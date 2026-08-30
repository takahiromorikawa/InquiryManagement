require "test_helper"

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  test "POST /inquiries は問い合わせを登録し 201 と登録内容を返す" do
    assert_difference -> { Inquiry.count }, 1 do
      post inquiries_url, params: {
        name: "顧客 花子",
        email: "hanako@example.com",
        subject: "料金プランについて",
        body: "詳しい料金体系を教えてください。"
      }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert body["id"].present?
    assert_equal "顧客 花子", body["name"]
    assert_equal "料金プランについて", body["subject"]
    assert_equal "unhandled", body["status"], "作成時のステータスは常に unhandled"
  end

  test "必須項目が欠けていると 422 を返し、登録しない" do
    assert_no_difference -> { Inquiry.count } do
      post inquiries_url, params: { name: "", email: "", subject: "", body: "" }, as: :json
    end

    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].present?
  end

  test "許可外のパラメータ（status）は無視される" do
    post inquiries_url, params: {
      name: "顧客", email: "c@example.com", subject: "件名", body: "本文",
      status: "completed"
    }, as: :json

    assert_response :created
    assert_equal "unhandled", response.parsed_body["status"]
  end
end
