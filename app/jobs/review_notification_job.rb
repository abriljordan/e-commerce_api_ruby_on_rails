class ReviewNotificationJob < ApplicationJob
  queue_as :default

  def perform(review_id, action)
    review = ProductReview.find(review_id)
    service = ReviewNotificationService.new(review)

    case action
    when 'created'
      service.notify_review_created
    when 'approved'
      service.notify_review_approved
    when 'rejected'
      service.notify_review_rejected
    end
  end
end 