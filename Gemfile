source 'https://rubygems.org'

gemspec

gem 'drailties', path: 'drailties'

group :test do
  gem 'rspec', require: false
  gem 'factory_girl', require: false
  gem 'coveralls', require: false
end

platforms :ruby, :mswin, :mingw do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter', '>= 1.3.0'
end
