version = File.read(File.expand_path('../../RAILS-DISCO_VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name          = 'active_event'
  s.version       = version

  s.authors       = 'Andreas Reischuck'
  s.email         = 'rails-disco@hicknhack-software.com'
  s.homepage      = 'https://github.com/hicknhack-software/rails-disco'

  s.summary       = 'Simple event sourcing stuff (part of rails-disco)'
  s.description   = 'Event server, validations, commands and events for rails-disco'
  
  s.license       = 'MIT'

  s.files         = Dir['{app,db,lib}/**/*', 'README.md', 'MIT-LICENSE']
  s.require_path = 'lib'
  s.test_files    = Dir['spec/**/*']

  s.add_dependency 'activerecord', '>3.2.0', '<4.1.0'
  s.add_dependency 'activemodel', '>3.2.0', '<4.1.0'
  s.add_dependency 'bunny'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'coveralls'
end
