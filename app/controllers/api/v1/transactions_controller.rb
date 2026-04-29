module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :set_transaction, only: [:show, :update, :destroy]

      def index
        page = params[:page].present? ? [params[:page].to_i, 1].max : 1
        page_size = params[:pageSize].to_i
        page_size = 10 if page_size <= 0
        page_size = 100 if page_size > 100

        scope = current_user.transactions.includes(:account, :category)
        scope = apply_filters(scope)
        scope = apply_search(scope)

        total = scope.count

        ordered_scope = scope.order(
          year: :desc,
          month: :desc,
          day: :desc,
          created_at: :desc
        )

        items = ordered_scope
                  .offset((page - 1) * page_size)
                  .limit(page_size)

        render_success(
          {
            items: items.map { |transaction| TransactionSerializer.call(transaction) },
            total: total,
            page: page,
            pageSize: page_size,
            totalPages: (total.to_f / page_size).ceil,
            summary: build_summary(scope)
          }
        )
      end

      def show
        return if performed?

        render_success(TransactionSerializer.call(@transaction))
      end

      def create
        account = current_user.accounts.find_by(
          id: transaction_params[:accountId],
          is_active: true
        )
        return render_error("Conta inválida ou inativa", :unprocessable_entity) unless account

        category = current_user.categories.find_by(id: transaction_params[:categoryId])
        return render_error("Categoria inválida", :unprocessable_entity) unless category

        transaction = current_user.transactions.new(
          amount: transaction_params[:amount],
          description: transaction_params[:description],
          year: transaction_params[:year],
          month: transaction_params[:month],
          day: transaction_params[:day],
          status: normalized_status(transaction_params[:status] || "COMPLETED"),
          account: account,
          category: category,
          transaction_type: normalized_type(category.category_type)
        )

        if transaction.save
          transaction.account.recalculate_balance!
          transaction = current_user.transactions.includes(:account, :category).find(transaction.id)

          render_success(
            TransactionSerializer.call(transaction),
            "Transação criada com sucesso",
            :created
          )
        else
          render_error(transaction.errors.full_messages.first, :unprocessable_entity)
        end
      end

      def update
        return if performed?

        old_account = @transaction.account
        account = @transaction.account
        category = @transaction.category

        if transaction_params.key?(:accountId)
          account = current_user.accounts.find_by(
            id: transaction_params[:accountId],
            is_active: true
          )
          return render_error("Conta inválida ou inativa", :unprocessable_entity) unless account
        end

        if transaction_params.key?(:categoryId)
          category = current_user.categories.find_by(id: transaction_params[:categoryId])
          return render_error("Categoria inválida", :unprocessable_entity) unless category
        end

        attrs = {}

        attrs[:amount] = transaction_params[:amount] if transaction_params.key?(:amount)
        attrs[:description] = transaction_params[:description] if transaction_params.key?(:description)
        attrs[:year] = transaction_params[:year] if transaction_params.key?(:year)
        attrs[:month] = transaction_params[:month] if transaction_params.key?(:month)
        attrs[:day] = transaction_params[:day] if transaction_params.key?(:day)
        attrs[:status] = normalized_status(transaction_params[:status]) if transaction_params.key?(:status)

        attrs[:account] = account if transaction_params.key?(:accountId)
        attrs[:category] = category if transaction_params.key?(:categoryId)

        # type SEMPRE deriva da categoria
        if transaction_params.key?(:categoryId)
          attrs[:transaction_type] = normalized_type(category.category_type)
        end

        if @transaction.update(attrs)
          old_account.recalculate_balance!

          if old_account.id != @transaction.account_id
            @transaction.account.recalculate_balance!
          end

          @transaction = current_user.transactions.includes(:account, :category).find(@transaction.id)

          render_success(
            TransactionSerializer.call(@transaction),
            "Transação atualizada com sucesso"
          )
        else
          render_error(@transaction.errors.full_messages.first, :unprocessable_entity)
        end
      end

      def destroy
        return if performed?

        account = @transaction.account

        @transaction.destroy!
        account.recalculate_balance!

        render_success(nil, "Transação excluída com sucesso")
      end

      private

      def set_transaction
        @transaction = current_user.transactions.includes(:account, :category).find_by(id: params[:id])

        return if @transaction

        render_error("Transação não encontrada", :not_found)
      end

      def transaction_params
        params.permit(
          :amount,
          :description,
          :year,
          :month,
          :day,
          :status,
          :type,       # aceitamos por compatibilidade, mas IGNORAMOS
          :accountId,
          :categoryId
        )
      end

      def apply_filters(scope)
        filtered = scope

        # compatibilidade com front antigo: account OU accountId
        account_id = params[:accountId].presence || params[:account].presence
        filtered = filtered.where(account_id: account_id) if account_id.present?

        filtered = filtered.where(category_id: params[:categoryId]) if params[:categoryId].present?

        if params[:status].present?
          filtered = filtered.where(status: normalized_status(params[:status]))
        end

        if params[:type].present?
          filtered = filtered.where(transaction_type: normalized_type(params[:type]))
        end

        filtered = filtered.where(year: params[:year].to_i) if params[:year].present?
        filtered = filtered.where(month: params[:month].to_i) if params[:month].present?

        filtered
      end

      def apply_search(scope)
        return scope unless params[:search].present?

        term = "%#{params[:search].to_s.strip}%"
        scope.where("description ILIKE ?", term)
      end

      def build_summary(scope)
        income = scope.where(transaction_type: "INCOME", status: "COMPLETED").sum(:amount)
        expense = scope.where(transaction_type: "EXPENSE", status: "COMPLETED").sum(:amount)

        {
          income: income,
          expense: expense,
          balance: income - expense
        }
      end

      def normalized_status(value)
        value.to_s.upcase
      end

      def normalized_type(value)
        value.to_s.upcase
      end
    end
  end
end
