require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

Rails::Generators::AppGenerator.start

ROOT_DIR = Dir.pwd
ARGV.unshift 'app'
require 'drails/generate'