module NsClient
  class HttpClient
    attr_reader :config, :logger

    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def client
      ## TODO
    end

    def deliver(value, topic:, **options)
      ## TODO Post request
    end
  end
end