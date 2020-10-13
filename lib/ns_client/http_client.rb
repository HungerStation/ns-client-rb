require 'ns_client/type'
require 'ns_client/request_error'
require 'ns_client/not_supported_topic'
require 'typhoeus'

module NsClient
  class HttpClient
    include NsClient::Type

    DEFAULT_TIMEOUT = 0.250 # 250ms
    DEFAULT_HEADERS = {'Content-Type' => 'application/json'}

    attr_reader :config, :logger

    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    # Deliver request to notification service
    # @param value [json], body payload
    # @param topic [string], message topic
    def deliver(value, topic:, version: 1, **options)
      validate_topic(topic)
      key = NsClient::Type::TOPICS.select{ |key, value| value == topic }.keys&.first
      url = full_url(NsClient::Type::PATHS[key], version)
      request(url: url, params: value, method: 'post')
    end

    private
    
    # Request url
    # @param url [String] the postfix for url
    # @param params [Json], payload
    # @metahod [string], http request method
    # @return [json] full response
    def request(url:, params: {}, method:, timeout: DEFAULT_TIMEOUT)
      method = format_method(method)
      @response = typhoeus_request(url: url, method: method, params: params, timeout: timeout).run
      response_code = @response.code
      if response_code >= 200 && response_code < 300
        return {} if @response&.body.empty?
        return JSON.parse(@response.body)
      end

      raise NsClient::RequestError, "Error While sending Request"
    rescue StandardError => e
      raise NsClient::RequestError, "Error While Request due to #{e.message}"
    end

    # Construct request using typhoeus
    # @param url [String] the postfix for url
    # @param params [Json], payload
    # @method [string], http request method
    # @return [Response] typoeaus response
    def typhoeus_request(url:, method:, params:, headers: DEFAULT_HEADERS, timeout: DEFAULT_TIMEOUT)
      Typhoeus::Request.new(
          url,
          {
            method: method,
            headers: headers,
            timeout: timeout
          }.merge({body: params})
      )
    end

    # Convert method to symbol
    # @param method [String] http request method
    # #return [String] stringify method
    def format_method(method)
      method.to_s.downcase.to_sym
    end

    # Construct URL
    # @param endpoint [String] suffix path of endpoint
    # @param version [Integer], API version
    # @return [String] full url
    def full_url(endpoint, version)
      return "#{NsClient.config.backup_url}/#{endpoint}" if version == 1

      "#{NsClient.config.backup_url}/V#{version}/#{endpoint}"
    end

    # validate topic 
    # @param topic [String]
    def validate_topic(topic)
      raise NsClient::NotSupportedTopic, "topic #{topic} is not supported" unless TOPICS.values.include? topic.to_s
    end
  end
end