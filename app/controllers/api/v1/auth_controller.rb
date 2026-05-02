# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [
        :login,
        :register
      ]

      def register
        user = User.new(register_params)

        if user.save
          render_success(
            UserSerializer.call(user),
            "Usuário criado com sucesso!",
            :created
          )
        else
          render_error(user.errors.full_messages.first, :unprocessable_entity)
        end
      end

      def login
        email = params[:email].to_s.strip.downcase
        password = params[:password].to_s

        if email.blank? || password.blank?
          return render_error("E-mail e senha são obrigatórios", :bad_request)
        end

        user = User.find_by(email: email)

        unless user&.authenticate(password)
          return render_error("E-mail ou senha inválidos!", :unauthorized)
        end

        # Se quiser manter apenas 1 sessão ativa por usuário:
        UserSession.where(user_id: user.id, revoked_at: nil).update_all(revoked_at: Time.current)

        raw_token = SessionTokenService.generate_token
        token_digest = SessionTokenService.digest(raw_token)
        expires_at = 7.days.from_now

        UserSession.create!(
          user: user,
          token_digest: token_digest,
          expires_at: expires_at,
          last_used_at: Time.current
        )

        user.update_column(:last_login, Time.current)

        set_session_cookie(raw_token, expires_at)

        render_success(
          {
            user: UserSerializer.call(user)
          },
          "Login realizado com sucesso!"
        )
      end

      def logout
        current_session&.revoke!
        delete_session_cookie

        render_success(nil, "Logout realizado com sucesso!")
      end

      def me
        render_success(UserSerializer.call(current_user))
      end

      private

      def register_params
        {
          name: params[:name],
          email: params[:email],
          password: params[:password],
          password_confirmation: params[:password]
        }
      end

      def set_session_cookie(raw_token, expires_at)
        cookies.signed[:session_token] = {
          value: raw_token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: cookie_same_site,
          expires: expires_at,
          domain: cookie_domain
        }.compact
      end

      def delete_session_cookie
        cookies.delete(
          :session_token,
          {
            secure: Rails.env.production?,
            same_site: cookie_same_site,
            domain: cookie_domain
          }.compact
        )
      end

      def cookie_same_site
        # Se front e API estiverem no mesmo "site" (ex: app.meudominio.com + api.meudominio.com), :lax costuma funcionar.
        # Se tiver cenário realmente cross-site, troque para :none (e secure true em produção).
        Rails.env.production? ? :lax : :lax
      end

      def cookie_domain
        # Em desenvolvimento, normalmente deixe nil.
        # Em produção, se usar subdomínios (app.xxx.com + api.xxx.com), pode usar:
        # ".seudominio.com"
        nil
      end
    end
  end
end
