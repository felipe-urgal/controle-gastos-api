module Api
  module V1
    class UserController < ApplicationController
      def update
        if password_update_requested? && !current_user.authenticate(params[:currentPassword].to_s)
          return render_error("Senha atual inválida", :unprocessable_entity)
        end

        attrs = {}

        attrs[:name] = params[:name] if params.key?(:name)
        attrs[:email] = params[:email]&.to_s&.strip&.downcase if params.key?(:email)
        attrs[:show_values] = params[:showValues] unless params[:showValues].nil?

        if password_update_requested?
          attrs[:password] = params[:newPassword]
          attrs[:password_confirmation] = params[:newPassword]
        end

        if current_user.update(attrs)
          render_success(UserSerializer.call(current_user), "Usuário atualizado com sucesso")
        else
          render_error(current_user.errors.full_messages.first, :unprocessable_entity)
        end
      end

      def destroy
        current_user.destroy!
        render_success(nil, "Conta excluída com sucesso")
      end

      private

      def password_update_requested?
        params[:newPassword].present?
      end
    end
  end
end
