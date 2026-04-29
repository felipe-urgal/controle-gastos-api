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

        UserSession.where(user_id: user.id, revoked_at: nil).update_all(revoked_at: Time.current)

        raw_token = SessionTokenService.generate_token
        token_digest = SessionTokenService.digest(raw_token)

        UserSession.create!(
          user: user,
          token_digest: token_digest,
          expires_at: 7.days.from_now,
          last_used_at: Time.current
        )

        user.update_column(:last_login, Time.current)

        render_success(
          {
            token: raw_token,
            user: UserSerializer.call(user)
          },
          "Login realizado com sucesso!"
        )
      end

      def logout
        current_session.revoke!
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
    end
  end
end
