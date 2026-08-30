require "test_helper"

class StaffTest < ActiveSupport::TestCase
  test "パスワードはハッシュ化され、authenticate で検証できる" do
    staff = Staff.create!(name: "担当", email: "new-staff@example.com", password: "secret123")
    assert_not_equal "secret123", staff.password_digest
    assert staff.authenticate("secret123")
    assert_not staff.authenticate("wrong")
  end

  test "email は必須かつ一意" do
    existing = staffs(:yamada)
    dup = Staff.new(name: "別人", email: existing.email, password: "password")
    assert_not dup.valid?
    assert dup.errors.of_kind?(:email, :taken)
  end
end
