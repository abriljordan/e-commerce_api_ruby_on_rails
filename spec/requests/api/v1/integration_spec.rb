require 'swagger_helper'

RSpec.describe 'E-commerce API Integration', type: :request do
  let(:user) { create(:user) }
  let(:address) { create(:address, user: user) }
  let(:category) { create(:category) }
  let(:product) { create(:product, :with_image, category: category) }
  let(:product_variant) { create(:product_variant, product: product) }
  let(:cart) { create(:cart, user: user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{user.generate_jwt}" } }

  describe 'Complete E-commerce Flow' do
    it 'performs a complete e-commerce transaction' do
      # 1. Login
      post '/api/v1/auth/login', params: {
        email: user.email,
        password: user.password
      }
      expect(response).to have_http_status(:ok)
      expect(json_response).to include('access_token', 'refresh_token')

      # 2. Add product to cart
      cart_item_params = {
        cart_item: {
          product_id: product.id,
          product_variant_id: product_variant.id,
          quantity: 2
        }
      }
      
      puts "\nBefore cart item creation:"
      puts "Auth headers: #{auth_headers.inspect}"
      puts "User cart: #{user.cart.inspect}"
      
      post '/api/v1/cart_items', params: cart_item_params, headers: auth_headers
      
      puts "\nAfter cart item creation:"
      puts "Response status: #{response.status}"
      puts "Response body: #{response.body}"
      puts "Cart item params: #{cart_item_params.inspect}"
      puts "Product exists? #{Product.exists?(product.id)}"
      puts "Product variant exists? #{ProductVariant.exists?(product_variant.id)}"
      puts "Cart exists? #{Cart.exists?(user.cart.id)}"
      puts "Current user cart items: #{user.cart.cart_items.reload.to_json}"
      
      # Try to create cart item manually to see validation errors
      cart_item = user.cart.cart_items.new(cart_item_params[:cart_item])
      if !cart_item.valid?
        puts "\nValidation errors:"
        puts cart_item.errors.full_messages
      end
      
      expect(response).to have_http_status(:created)
      cart_item = json_response
      expect(cart_item['quantity']).to eq(2)

      # 3. Update cart item
      patch "/api/v1/cart_items/#{cart_item['id']}", params: {
        cart_item: {
          quantity: 3
        }
      }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(json_response['quantity']).to eq(3)

      # 4. Create order
      post '/api/v1/orders', params: {
        order: {
          address_id: address.id,
          order_items: [
            {
              product_variant_id: product_variant.id,
              quantity: 3
            }
          ]
        }
      }, headers: auth_headers
      expect(response).to have_http_status(:created)
      order = json_response
      expect(order['status']).to eq('pending')
      expect(order['total_amount']).to be_a(Numeric)

      # 5. Create product review
      post "/api/v1/products/#{product.id}/reviews", params: {
        product_review: {
          title: 'Great product!',
          content: 'This product exceeded my expectations.',
          rating: 5
        }
      }, headers: auth_headers
      expect(response).to have_http_status(:created)
      review = json_response
      expect(review['rating']).to eq(5)
      expect(review['title']).to eq('Great product!')

      # 6. View user orders
      get '/api/v1/orders', headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(json_response['orders']).to be_an(Array)
      expect(json_response['orders'].first['id']).to eq(order['id'])

      # 7. Refresh token
      post '/api/v1/auth/refresh', params: {
        refresh_token: user.generate_refresh_token
      }
      expect(response).to have_http_status(:ok)
      expect(json_response).to include('access_token', 'refresh_token')

      # 8. Logout
      delete '/api/v1/auth/logout', headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(json_response['message']).to eq('Successfully logged out')
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end 