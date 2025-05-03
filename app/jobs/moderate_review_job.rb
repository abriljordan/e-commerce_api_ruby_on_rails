class ModerateReviewJob < ApplicationJob
  queue_as :default

  def perform(review_id)
    review = ProductReview.find(review_id)
    service = ReviewModerationService.new(review)
    service.moderate
  end
end 