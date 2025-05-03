class ReviewNotificationService
  def initialize(review)
    @review = review
    @product = review.product
    @user = review.user
  end

  def notify_review_created
    notify_admin
    notify_product_owner if product_owner_exists?
  end

  def notify_review_approved
    notify_reviewer
  end

  def notify_review_rejected
    notify_reviewer
  end

  private

  def notify_admin
    AdminMailer.new_review_notification(@review).deliver_later
  end

  def notify_product_owner
    ProductOwnerMailer.new_review_notification(@review).deliver_later
  end

  def notify_reviewer
    UserMailer.review_status_notification(@review).deliver_later
  end

  def product_owner_exists?
    @product.user.present?
  end
end 