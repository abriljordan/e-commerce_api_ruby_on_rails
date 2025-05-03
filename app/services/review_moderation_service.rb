class ReviewModerationService
  def initialize(review)
    @review = review
    @product = review.product
    @user = review.user
  end

  def moderate
    return false unless @review.pending?

    if meets_guidelines?
      approve_review
    else
      reject_review
    end
  end

  private

  def meets_guidelines?
    # Check for minimum content length
    return false if @review.content.length < 10

    # Check for inappropriate language
    return false if contains_inappropriate_language?

    # Check for spam patterns
    return false if contains_spam_patterns?

    true
  end

  def contains_inappropriate_language?
    inappropriate_words = Rails.application.config.inappropriate_words || []
    inappropriate_words.any? { |word| @review.content.downcase.include?(word) }
  end

  def contains_spam_patterns?
    spam_patterns = [
      /http[s]?:\/\/\S+/i, # URLs
      /[A-Z]{5,}/, # Excessive capitalization
      /!{3,}/, # Excessive exclamation marks
      /\b(?:buy|cheap|discount|offer|promotion)\b/i # Marketing keywords
    ]

    spam_patterns.any? { |pattern| @review.content.match?(pattern) }
  end

  def approve_review
    @review.update(approved: true)
    ReviewNotificationJob.perform_later(@review.id, 'approved')
    true
  end

  def reject_review
    @review.update(approved: false)
    ReviewNotificationJob.perform_later(@review.id, 'rejected')
    false
  end
end 