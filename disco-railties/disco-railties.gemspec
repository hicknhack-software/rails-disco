version = File.read(File.expand_path('../../RAILS-DISCO_VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name          = 'disco-railties'
  s.version       = version
  
  s.authors       = 'HicknHack Software'
  s.email         = 'rails-disco@hicknhack-software.com'
  s.homepage      = 'https://github.com/hicknhack-software/rails-disco'
  
  s.summary       = 'Tools for working with Rails Disco'
  s.description   = 'Rails Disco internals: rake tasks, generators and the commandline interface'
  
  s.license       = 'MIT'

  s.files         = Dir['{lib}/**/*', 'Rakefile', 'MIT-LICENSE']
  s.require_path  = 'lib'

  s.bindir        = 'bin'
  s.executables   = %w(disco drails)

  s.add_dependency 'active_event', version
  s.add_dependency 'active_domain', version
  s.add_dependency 'active_projection', version

  s.add_dependency 'rails', '~> 4.0.0'
end
