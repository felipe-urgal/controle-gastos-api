module Api
  module V1
    class AccountsController < ApplicationController
      def index
        accounts = current_user.accounts.order(created_at: :desc)

        if params[:isActive].present?
          accounts = accounts.where(is_active: ActiveModel::Type::Boolean.new.cast(params[:isActive]))
        end

        if params[:type].present?
          mapped_type = map_account_type(params[:type])
          accounts = accounts.where(account_type: mapped_type) if mapped_type
        end

        if params[:currency].present?
          accounts = accounts.where(currency: params[:currency].to_s.upcase)
        end

        if params[:search].present?
          term = "%#{params[:search]}%"
          accounts = accounts.where("name ILIKE ? OR description ILIKE ?", term, term)
        end

        total = accounts.count

        page = params[:page].to_i
        page_size = params[:pageSize].to_i

        if page.positive? && page_size.positive?
          accounts = accounts.offset((page - 1) * page_size).limit(page_size)
        end

        render_success({
          items: accounts.map { |account| AccountSerializer.call(account) },
          total: total,
          page: page.positive? ? page : nil,
          pageSize: page_size.positive? ? page_size : nil,
          totalPages: (page.positive? && page_size.positive?) ? (total.to_f / page_size).ceil : nil
        }, "Contas carregadas com sucesso")
      end

      def show
        account = current_user.accounts.find_by(id: params[:id])
        return render_error("Conta não encontrada", :not_found) unless account

        render_success(AccountSerializer.call(account))
      end

      def create
        account = current_user.accounts.new(account_params)

        if account.save
          render_success(AccountSerializer.call(account), "Conta criada com sucesso", :created)
        else
          render_error(account.errors.full_messages.first, :unprocessable_entity)
        end
      end

      def update
        account = current_user.accounts.find_by(id: params[:id])
        return render_error("Conta não encontrada", :not_found) unless account

        if account.update(account_params)
          render_success(AccountSerializer.call(account), "Conta atualizada com sucesso")
        else
          render_error(account.errors.full_messages.first, :unprocessable_entity)
        end
      end

      def destroy
        account = current_user.accounts.find_by(id: params[:id])
        return render_error("Conta não encontrada", :not_found) unless account

        # por enquanto, como ainda não temos Transaction no Rails:
        # depois trocamos por account.transactions.exists?
        if false
          return render_error("Conta possui transações vinculadas", :unprocessable_entity)
        end

        account.destroy!
        render_success(nil, "Conta excluída com sucesso")
      end

      private

      def account_params
        attrs = {}

        attrs[:name] = params[:name] if params.key?(:name)
        attrs[:account_type] = map_account_type(params[:type] || params[:accountType]) if params.key?(:type) || params.key?(:accountType)
        attrs[:currency] = params[:currency] if params.key?(:currency)
        attrs[:is_active] = params[:isActive] unless params[:isActive].nil?
        attrs[:color] = params[:color] if params.key?(:color)
        attrs[:icon] = params[:icon] if params.key?(:icon)
        attrs[:description] = params[:description] if params.key?(:description)

        attrs
      end

      def map_account_type(value)
        case value.to_s.upcase
        when "CREDIT_DEBIT" then "credit_debit"
        when "INVESTMENT" then "investment"
        else nil
        end
      end
    end
  end
end
