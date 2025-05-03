# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.to_s + '/swagger'

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.json' => {
      swagger: '2.0',
      info: {
        title: 'E-commerce API V1',
        version: 'v1',
        description: 'This is the API documentation for the E-commerce application'
      },
      basePath: '/api/v1',
      securityDefinitions: {
        Bearer: {
          type: :apiKey,
          name: 'Authorization',
          in: :header
        }
      },
      security: [
        {
          Bearer: []
        }
      ],
      paths: {},
      definitions: {
        error: {
          type: :object,
          properties: {
            error: { type: :string }
          }
        },
        pagination: {
          type: :object,
          properties: {
            current_page: { type: :integer },
            next_page: { type: :integer, nullable: true },
            prev_page: { type: :integer, nullable: true },
            total_pages: { type: :integer },
            total_count: { type: :integer }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :json
end
