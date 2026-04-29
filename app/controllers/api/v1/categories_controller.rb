module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        categories = current_user.categories.order(created_at: :desc)

        if params[:isActive].present?
          categories = categories.where(is_active: ActiveModel::Type::Boolean.new.cast(params[:isActive]))
        end

        if params[:type].present?
          mapped_type = map_category_type(params[:type])
          categories = categories.where(category_type: mapped_type) if mapped_type
        end

        if params[:search].present?
          term = "%#{params[:search]}%"
          categories = categories.where("name ILIKE ? OR description ILIKE ?", term, term)
        end

        total = categories.count

        page = params[:page].to_i
        page_size = params[:pageSize].to_i

        if page.positive? && page_size.positive?
          categories = categories.offset((page - 1) * page_size).limit(page_size)
        end

        render_success({
          items: categories.map { |category| CategorySerializer.call(category) },
          total: total,
          page: page.positive? ? page : nil,
          pageSize: page_size.positive? ? page_size : nil,
          totalPages: (page.positive? && page_size.positive?) ? (total.to_f / page_size).ceil : nil
        }, "Categorias carregadas com sucesso")
      end

      def show
        category = current_user.categories.find_by(id: params[:id])
        return render_error("Categoria não encontrada", :not_found) unless category

        render_success(CategorySerializer.call(category))
      end

      def create
        category = current_user.categories.new(category_params)

        if category.save
          render_success(CategorySerializer.call(category), "Categoria criada com sucesso", :created)
        else
          render_error(category.errors.full_messages.first, :unprocessable_entity)
        end
      end

      def update
        category = current_user.categories.find_by(id: params[:id])
        return render_error("Categoria não encontrada", :not_found) unless category

        if category.update(category_params)
          render_success(CategorySerializer.call(category), "Categoria atualizada com sucesso")
        else
          render_error(category.errors.full_messages.first, :unprocessable_entity)
        end
      end

      def destroy
        category = current_user.categories.find_by(id: params[:id])
        return render_error("Categoria não encontrada", :not_found) unless category

        # por enquanto, como ainda não temos Transaction no Rails:
        # depois trocamos por category.transactions.exists?
        if false
          return render_error("Categoria possui transações vinculadas", :unprocessable_entity)
        end

        category.destroy!
        render_success(nil, "Categoria excluída com sucesso")
      end

      private

      def category_params
        attrs = {}

        attrs[:name] = params[:name] if params.key?(:name)
        attrs[:color] = params[:color] if params.key?(:color)
        attrs[:icon] = params[:icon] if params.key?(:icon)
        attrs[:category_type] = map_category_type(params[:type]) if params.key?(:type)
        attrs[:is_active] = params[:isActive] unless params[:isActive].nil?
        attrs[:description] = params[:description] if params.key?(:description)
        attrs[:position] = params[:position] if params.key?(:position)

        attrs
      end

      def map_category_type(value)
        case value.to_s.upcase
        when "INCOME" then "income"
        when "EXPENSE" then "expense"
        else nil
        end
      end
    end
  end
end
