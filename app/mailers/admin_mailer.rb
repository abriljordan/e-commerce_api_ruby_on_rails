class AdminMailer < ApplicationMailer
  def new_review_notification(review)
    @review = review
    @product = review.product
    @user = review.user

    mail(
      to: ENV['ADMIN_EMAIL'],
      subject: "New Review for #{@product.name}"
    )
  end
end 