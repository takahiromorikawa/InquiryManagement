require "test_helper"

class ReplyTest < ActiveSupport::TestCase
  test "inquiry・staff・body が揃っていれば有効" do
    reply = Reply.new(inquiry: inquiries(:unhandled_inquiry), staff: staffs(:yamada), body: "返信本文")
    assert reply.valid?
  end

  test "body・inquiry・staff は必須" do
    reply = Reply.new
    assert_not reply.valid?
    assert reply.errors.of_kind?(:body, :blank)
    assert reply.errors.of_kind?(:inquiry, :blank)
    assert reply.errors.of_kind?(:staff, :blank)
  end
end
