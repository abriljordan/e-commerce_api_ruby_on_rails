require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/auth/login' do
    post 'Login' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }

      response '200', 'successful login' do
        let(:user) { create(:user) }
        let(:credentials) { { email: user.email, password: user.password } }
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'invalid@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/register' do
    post 'Register' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string },
          email: { type: :string },
          password: { type: :string },
          first_name: { type: :string },
          last_name: { type: :string }
        },
        required: ['username', 'email', 'password']
      }

      response '201', 'user created' do
        let(:user) { { username: 'testuser', email: 'test@example.com', password: 'password123' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { username: 'testuser' } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/logout' do
    delete 'Logout' do
      tags 'Authentication'
      security [Bearer: []]
      produces 'application/json'

      response '200', 'successful logout' do
        let(:Authorization) { "Bearer #{token}" }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'Bearer invalid' }
        run_test!
      end
    end
  end
end 