require 'disco/generators'

if [nil, '-h', '--help'].include?(ARGV.first)
  Rails::Generators.help 'generate'
  exit
end

name = ARGV.shift
name = name.sub(/^disco:/, '')

root = defined?(ENGINE_ROOT) ? ENGINE_ROOT : Rails.root
Rails::Generators.invoke "disco:#{name}", ARGV, behavior: :invoke, destination_root: root
