source 'https://rubygems.org'

gemspec

gem 'disco-railties', path: 'disco-railties'

group :test do
  gem 'rspec', require: false
  gem 'factory_girl', require: false
  gem 'coveralls', require: false
  gem 'rubocop', require: false
end

platforms :ruby, :mswin, :mingw do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter', '>= 1.3.0'
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end
