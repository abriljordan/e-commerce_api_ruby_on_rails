module Api
  module V1
    module Admin
      class ReviewAnalyticsController < BaseController
        def index
          start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 30.days.ago
          end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Time.current

          analytics = if start_date == 30.days.ago && end_date == Time.current
                       Rails.cache.fetch('review_analytics', expires_in: 1.hour) do
                         ReviewAnalyticsService.new(start_date, end_date).calculate
                       end
                     else
                       ReviewAnalyticsService.new(start_date, end_date).calculate
                     end

          render json: analytics, serializer: ReviewAnalyticsSerializer
        end
      end
    end
  end
end 