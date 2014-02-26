module ActiveEvent
  # Returns the version of the currently loaded ActiveEvent as a Gem::Version
  def self.version
    Gem::Version.new '0.5.0'
  end

  module VERSION #:nodoc:
    MAJOR, MINOR, TINY, PRE = ActiveEvent.version.segments
    STRING = ActiveEvent.version.to_s
  end
end
