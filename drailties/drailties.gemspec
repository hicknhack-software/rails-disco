version = File.read(File.expand_path('../../RAILS-DISCO_VERSION', __FILE__)).strip

Gem::Specification.new do |s|
  s.name          = 'drailties'
  s.version       = version
  
  s.authors       = 'Robert Kranz'
  s.email         = 'robert.kranz@hicknhack-software.com'
  s.homepage      = 'https://github.com/hicknhack-software/rails-disco'
  
  s.summary       = 'Tools for working with Rails Disco'
  s.description   = 'Internals: rake tasks, generators, commandline interface'
  
  s.license       = 'MIT'

  s.files         = Dir['{lib}/**/*', 'Rakefile', 'MIT-LICENSE']
  s.require_path  = 'lib'

  s.bindir        = 'bin'
  s.executables   = ['drails']

  s.add_dependency 'active_event', version
  s.add_dependency 'active_domain', version
  s.add_dependency 'active_projection', version

  s.add_dependency 'rails', '~> 4.0.0'
end