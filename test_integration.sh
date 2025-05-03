#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Base URL
BASE_URL="http://localhost:3000/api/v1"

# Function to print step headers
print_step() {
    echo -e "\n${GREEN}=== $1 ===${NC}"
}

# Function to make API calls and handle responses
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local token=$4

    local headers=("-H" "Content-Type: application/json")
    if [ ! -z "$token" ]; then
        headers+=("-H" "Authorization: Bearer $token")
    fi

    if [ "$method" = "GET" ]; then
        response=$(curl -s -X $method "$BASE_URL$endpoint" "${headers[@]}")
    else
        response=$(curl -s -X $method "$BASE_URL$endpoint" "${headers[@]}" -d "$data")
    fi

    echo "$response"
}

# 1. Registration
print_step "1. Registering a new user"
register_response=$(make_request "POST" "/auth/register" '{
    "user": {
        "username": "integration_test_user",
        "email": "integration_test@example.com",
        "password": "Password123",
        "first_name": "Integration",
        "last_name": "Test"
    }
}')
echo "Registration Response: $register_response"

# 2. Login
print_step "2. Logging in"
login_response=$(make_request "POST" "/auth/login" '{
    "email": "integration_test@example.com",
    "password": "Password123"
}')
echo "Login Response: $login_response"

# Extract tokens from login response
access_token=$(echo $login_response | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
refresh_token=$(echo $login_response | grep -o '"refresh_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$access_token" ]; then
    echo -e "${RED}Failed to get access token${NC}"
    exit 1
fi

# 3. View Products
print_step "3. Viewing all products"
products_response=$(make_request "GET" "/products" "" "$access_token")
echo "Products Response: $products_response"

# Extract first product ID
product_id=$(echo $products_response | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

# 4. View Specific Product
print_step "4. Viewing specific product"
product_response=$(make_request "GET" "/products/$product_id" "" "$access_token")
echo "Product Response: $product_response"

# 5. Add to Cart
print_step "5. Adding product to cart"
cart_response=$(make_request "POST" "/cart_items" '{
    "cart_item": {
        "product_variant_id": 1,
        "quantity": 2
    }
}' "$access_token")
echo "Cart Response: $cart_response"

# 6. Update Cart
print_step "6. Updating cart item"
update_cart_response=$(make_request "PATCH" "/cart_items/1" '{
    "cart_item": {
        "quantity": 3
    }
}' "$access_token")
echo "Update Cart Response: $update_cart_response"

# 7. Create Order
print_step "7. Creating an order"
order_response=$(make_request "POST" "/orders" '{
    "order": {
        "address_id": 1,
        "order_items": [
            {
                "product_variant_id": 1,
                "quantity": 1
            }
        ]
    }
}' "$access_token")
echo "Order Response: $order_response"

# Extract order ID
order_id=$(echo $order_response | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

# 8. Create Review
print_step "8. Creating a product review"
review_response=$(make_request "POST" "/products/$product_id/reviews" '{
    "product_review": {
        "title": "Great product!",
        "content": "This product exceeded my expectations.",
        "rating": 5
    }
}' "$access_token")
echo "Review Response: $review_response"

# 9. View User Orders
print_step "9. Viewing user orders"
orders_response=$(make_request "GET" "/orders" "" "$access_token")
echo "Orders Response: $orders_response"

# 10. Refresh Token
print_step "10. Refreshing access token"
refresh_response=$(make_request "POST" "/auth/refresh" "{
    \"refresh_token\": \"$refresh_token\"
}")
echo "Refresh Response: $refresh_response"

# Extract new tokens
new_access_token=$(echo $refresh_response | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
new_refresh_token=$(echo $refresh_response | grep -o '"refresh_token":"[^"]*' | cut -d'"' -f4)

# 11. Logout
print_step "11. Logging out"
logout_response=$(make_request "POST" "/auth/logout" "" "$new_access_token")
echo "Logout Response: $logout_response"

echo -e "\n${GREEN}Integration test completed successfully!${NC}" 