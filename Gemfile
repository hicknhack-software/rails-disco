source 'https://rubygems.org'

gemspec

gem 'drailties', path: 'drailties'

group :test do
  gem 'rspec'
  gem 'factory_girl'
end

platforms :ruby do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'activerecord-jdbcsqlite3-adapter', '>= 1.3.0'
end
