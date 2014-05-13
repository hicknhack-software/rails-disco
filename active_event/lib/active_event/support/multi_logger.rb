require 'logger'

module ActiveEvent
  module Support
    class MultiLogger
      [:info, :debug, :error, :fatal, :warn, :unknown].each do |action|
        define_method action do |msg|
          @loggers.each do |logger|
            logger.send(action, msg)
          end
        end
      end

      def initialize(progname = nil, formatter = nil)
        @loggers = []
        @loggers << Logger.new(STDOUT)
        @loggers << Logger.new('log/disco.log')
        @loggers.each do |logger|
          logger.progname = progname if progname.present?
          logger.formatter = if formatter.present?
                               formatter
                             else
                               proc do |severity, datetime, pprogname, msg|
                                 "#{datetime}: [#{pprogname}][#{severity}]: #{msg}\n"
                               end
                             end
        end
      end
    end
  end
end
