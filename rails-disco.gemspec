version = File.read(File.expand_path('../RAILS-DISCO_VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name        = 'rails-disco'
  s.version     = version

  s.authors     = ['HicknHack Software']
  s.email       = 'rails-disco@hicknhack-software.com'
  s.homepage    = 'https://github.com/hicknhack-software/rails-disco'
  
  s.summary     = 'A distributed party with commands, events and projections'
  s.description = <<-EOF
    Rails Disco is a framework that extends Rails with support for the best parts of event sourcing.

    Instead of updating models synchronously in Rails, these changes are captured in commands. Commands are validated in a domain and create the only source of truth: events. Later events can be projected into Rails models and other actions.

    Have a look at the documentation on Github for more details.
EOF

  s.license 	= 'MIT'

  s.files 		= ['README.md']

  s.add_dependency 'disco-railties', version
end
