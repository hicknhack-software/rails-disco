require 'json'

module ActiveEvent
  class SSE
    def initialize(io)
      @io = io
    end

    def event(event, data = nil, options = {})
      self.data options.merge(event: event, data: JSON.dump(data))
    end

    def data(data)
      data.each_pair do |key, value|
        (value+"\n").split("\n", -1)[0..-2].each do |v|
          @io.write "#{key}: #{v}\n"
        end
      end
      @io.write "\n"
    end

    def close
      @io.close
    end
  end
end
