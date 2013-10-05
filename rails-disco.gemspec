version = File.read(File.expand_path('../RAILS-DISCO_VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name        = 'rails-disco'
  s.version     = version

  s.authors     = ['Robert Kranz', 'Andreas Reischuck']
  s.email       = 'rails-disco@hicknhack-software.com'
  s.homepage    = 'https://github.com/hicknhack-software/rails-disco'
  
  s.summary     = 'A distributed party with commands, events and projections'
  s.description = 'Rails Disco is a framework on top of the rails framework to provide cqrs and simple event sourcing possibilities to rails.'

  s.license 	= 'MIT'

  s.files 		= ['README.md']

  s.add_dependency 'drailties', version
end
