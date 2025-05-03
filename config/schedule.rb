every 1.hour do
  rake 'reviews:cache_analytics'
end

every 1.day, at: '4:30 am' do
  rake 'reviews:update_statistics'
end

every 1.day, at: '5:00 am' do
  rake 'reviews:cleanup'
end

every 1.day, at: '6:00 am' do
  runner 'User.find_each { |user| CacheReviewRecommendationsJob.perform_later(user.id) }'
end 