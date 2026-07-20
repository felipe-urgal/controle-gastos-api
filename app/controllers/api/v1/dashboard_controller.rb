module Api
  module V1
    class DashboardController < ApplicationController
      def show
        year = (params[:year].presence || Date.current.year).to_i
        month = (params[:month].presence || Date.current.month).to_i

        render_success(DashboardSerializer.call(current_user, year: year, month: month))
      end
    end
  end
end
