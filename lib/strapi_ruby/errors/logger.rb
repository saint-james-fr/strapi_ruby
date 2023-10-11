require "colorize"

module StrapiRuby
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
        log.formatter = proc do |severity, datetime, progname, msg|
          case severity
          when "ERROR"
            "[#{datetime.strftime("%Y-%m-%d %H:%M:%S")}] #{progname} - #{severity}: #{msg}".red
          else
            "[#{datetime.strftime("%Y-%m-%d %H:%M:%S")}] #{progname} - #{severity}: #{msg}"
          end
        end
      end
    end
  end
end
