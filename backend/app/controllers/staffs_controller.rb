class StaffsController < ApplicationController
  # 担当者の一覧・追加は管理者（admin: true）のみ。
  before_action :require_admin

  # GET /staffs — 登録済みの担当者一覧を返す。
  def index
    render json: Staff.order(:id).map { |staff| staff_json(staff) }
  end

  # POST /staffs — 新しい担当者を追加する。追加される担当者は一般権限（admin: false）。
  def create
    staff = Staff.new(staff_params)

    if staff.save
      render json: staff_json(staff), status: :created
    else
      render json: { errors: staff.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def staff_params
    params.permit(:name, :email, :password)
  end

  def staff_json(staff)
    staff.as_json(only: %i[id name email admin])
  end
end
