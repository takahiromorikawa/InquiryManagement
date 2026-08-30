class RepliesController < ApplicationController
  # POST /inquiries/:inquiry_id/replies
  # ログイン中の担当者として問い合わせに返信する（UC5）。
  def create
    inquiry = Inquiry.find(params[:inquiry_id])
    reply = inquiry.replies.build(body: params[:body], staff: current_staff)

    if reply.save
      render json: reply_json(reply), status: :created
    else
      render json: { errors: reply.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def reply_json(reply)
    {
      id: reply.id,
      body: reply.body,
      staff: reply.staff.name,
      created_at: reply.created_at
    }
  end
end
