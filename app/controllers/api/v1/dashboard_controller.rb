module Api
  module V1
    class DashboardController < ApplicationController
      def show
        year = (params[:year].presence || Date.current.year).to_i
        month = (params[:month].presence || Date.current.month).to_i

        return render_error("Mês ou ano inválido", :bad_request) unless valid_period?(year, month)

        render_success(DashboardSerializer.call(current_user, year: year, month: month))
      end

      private

      def valid_period?(year, month)
        year.between?(2000, 2100) && month.between?(1, 12)
      end
    end
  end
end
