# simple ring buffer
class RingBuffer < Array
  attr_accessor :max_size

  def initialize(max_size, *args, &block)
    super(*args, &block)
    self.max_size = max_size
  end

  def max_size=(new_size)
    replace first(new_size) if new_size < size
    self.max_size = new_size
  end

  def <<(item)
    shift if max_size && size == max_size
    super
  end
  alias :push :<<
end
