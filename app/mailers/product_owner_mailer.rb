class ProductOwnerMailer < ApplicationMailer
  def new_review_notification(review)
    @review = review
    @product = review.product
    @user = review.user

    mail(
      to: @product.user.email,
      subject: "New Review for Your Product: #{@product.name}"
    )
  end
end 