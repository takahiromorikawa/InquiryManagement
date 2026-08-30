require "test_helper"

class InquiryTest < ActiveSupport::TestCase
  test "有効な属性で作成でき、ステータスの初期値は unhandled" do
    inquiry = Inquiry.create!(name: "顧客", company: "顧客株式会社", email: "c@example.com", subject: "件名", body: "本文")
    assert inquiry.unhandled?
  end

  test "必須項目が欠けていると無効" do
    inquiry = Inquiry.new
    assert_not inquiry.valid?
    assert inquiry.errors.of_kind?(:name, :blank)
    assert inquiry.errors.of_kind?(:company, :blank)
    assert inquiry.errors.of_kind?(:email, :blank)
    assert inquiry.errors.of_kind?(:subject, :blank)
    assert inquiry.errors.of_kind?(:body, :blank)
  end

  test "status に定義外の値を渡すと ArgumentError" do
    assert_raises(ArgumentError) { Inquiry.new(status: "unknown") }
  end

  test "replies は投稿日時の古い順で、削除時に一緒に消える" do
    inquiry = inquiries(:in_progress_inquiry)
    assert_equal inquiry.replies.order(:created_at).to_a, inquiry.replies.to_a
    reply_ids = inquiry.reply_ids
    assert_not_empty reply_ids
    inquiry.destroy
    assert_empty Reply.where(id: reply_ids)
  end
end
