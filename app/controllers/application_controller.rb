class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :authenticate_request

  attr_reader :current_user, :current_session

  private

  def authenticate_request
    token = session_token

    return render_unauthorized if token.blank?

    token_digest = SessionTokenService.digest(token)

    @current_session = UserSession.includes(:user).active.find_by(token_digest: token_digest)

    return render_unauthorized unless @current_session

    @current_session.update_column(:last_used_at, Time.current)
    @current_user = @current_session.user
  end

  def session_token
    cookie_token || bearer_token
  end

  def cookie_token
    cookies.signed[:session_token]
  end

  def bearer_token
    header = request.headers["Authorization"]
    return nil if header.blank?

    parts = header.split(" ")
    return nil unless parts.length == 2 && parts.first == "Bearer"

    parts.last
  end

  def render_success(data = nil, message = nil, status = :ok)
    render json: {
      success: true,
      message: message,
      data: data
    }, status: status
  end

  def render_error(message, status = :bad_request, code = nil)
    render json: {
      success: false,
      error: {
        code: code,
        message: message
      }
    }, status: status
  end

  def render_unauthorized
    render_error("Não autenticado", :unauthorized, "NOT_AUTHENTICATED")
  end
end
