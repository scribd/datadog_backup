# frozen_string_literal: true

module DatadogBackup
  class Client
    RETRY_OPTIONS = {
      max: 5,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2
    }.freeze

    def initialize
      @client = Faraday.new(
        url: ENV.fetch('DD_SITE_URL', 'https://api.datadoghq.com/'),
        headers: {
          'DD-API-KEY' => ENV.fetch('DD_API_KEY'),
          'DD-APPLICATION-KEY' => ENV.fetch('DD_APP_KEY')
        }
      ) do |faraday|
        faraday.request :json
        faraday.request :retry, RETRY_OPTIONS
        faraday.response(:logger, LOGGER, { headers: true, bodies: LOGGER.debug?, log_level: :debug }) do |logger|
          logger.filter(/(DD-API-KEY:)([^&]+)/, '\1[REDACTED]')
          logger.filter(/(DD-APPLICATION-KEY:)([^&]+)/, '\1[REDACTED]')
        end
        faraday.response :raise_error
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end
    end

    def get_body(path, params = {}, headers = {})
      response = @client.get(path, params, headers)
      response.body
    end

    def post_body(path, body, headers = {})
      response = @client.post(path, body, headers)
      response.body
    end

    def put_body(path, body, headers = {})
      response = @client.put(path, body, headers)
      response.body
    end
  end
end
