module ActiveProjection
  # Returns the version of the currently loaded ActiveProjection as a Gem::Version
  def self.version
    Gem::Version.new '0.1.0'
  end

  module VERSION #:nodoc:
    MAJOR, MINOR, TINY, PRE = ActiveProjection.version.segments
    STRING = ActiveProjection.version.to_s
  end
end
