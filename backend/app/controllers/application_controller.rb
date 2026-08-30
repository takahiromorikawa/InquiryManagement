class ApplicationController < ActionController::API
  include Authentication

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "リソースが見つかりません" }, status: :not_found
  end
end
