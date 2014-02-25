module ActiveDomain
  # Returns the version of the currently loaded ActiveDomain as a Gem::Version
  def self.version
    Gem::Version.new '0.4.4'
  end

  module VERSION #:nodoc:
    MAJOR, MINOR, TINY, PRE = ActiveDomain.version.segments
    STRING = ActiveDomain.version.to_s
  end
end
