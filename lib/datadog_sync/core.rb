module DatadogSync
  class Core

    def initialize(opts)
      @opts = opts
    end

    def logger
      @opts[:logger]
    end

    def execute!
      logger.warn "Hello World: #{@opts}"
    end

  end
end
