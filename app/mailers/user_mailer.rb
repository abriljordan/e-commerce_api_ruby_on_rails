class UserMailer < ApplicationMailer
  def review_status_notification(review)
    @review = review
    @product = review.product
    @user = review.user

    mail(
      to: @user.email,
      subject: "Your Review for #{@product.name} has been #{@review.approved ? 'approved' : 'rejected'}"
    )
  end
end 