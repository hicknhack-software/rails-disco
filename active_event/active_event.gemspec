version = File.read(File.expand_path('../../RAILS-DISCO_VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name          = 'active_event'
  s.version       = version

  s.authors       = 'HicknHack Software'
  s.email         = 'rails-disco@hicknhack-software.com'
  s.homepage      = 'https://github.com/hicknhack-software/rails-disco'

  s.summary       = 'Commands, Events and Validations for Rails Disco'
  s.description   = <<-EOF
    Contains commands, events, validations for Rails Disco.

    Commands are used to transport updates from Rails to the domain.
    Validations are used to validate commands in Rails and the domain.
    Events are created in the domain and processed in projections.

    Have a look at the rails-disco documentation on Github for more details.
EOF
  
  s.license       = 'MIT'

  s.files         = Dir['{app,db,lib}/**/*', 'README.md', 'MIT-LICENSE']
  s.require_path = 'lib'
  s.test_files    = Dir['spec/**/*']

  s.add_dependency 'activerecord', '>3.2.0', '<4.2.0'
  s.add_dependency 'activemodel', '>3.2.0', '<4.2.0'
  s.add_dependency 'bunny'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'coveralls'
end
