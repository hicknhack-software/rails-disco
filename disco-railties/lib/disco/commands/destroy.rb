require 'disco/generators'

if [nil, '-h', '--help'].include?(ARGV.first)
  Rails::Generators.help 'destroy'
  exit
end

name = ARGV.shift
name = name.sub(/^disco:/, '')

root = defined?(ENGINE_ROOT) ? ENGINE_ROOT : Rails.root
Rails::Generators.invoke "disco:#{name}", ARGV, behavior: :revoke, destination_root: root
