require 'rails/generators'

if [nil, "-h", "--help"].include?(ARGV.first)
  puts "Usage: drails generate GENERATOR [args] [options]"
  puts
  puts "General options:"
  puts "  -h, [--help]     # Print generator's options and usage"
  puts "  -p, [--pretend]  # Run but do not make any changes"
  puts "  -f, [--force]    # Overwrite files that already exist"
  puts "  -s, [--skip]     # Skip files that already exist"
  puts "  -q, [--quiet]    # Suppress status output"
  puts
  puts "Please choose a generator below."
  puts
  puts "Scaffold"
  puts "Command"
  puts "Projection"
  exit(1)
end

Rails::Generators.invoke "drails:#{ARGV.shift}", ARGV, behavior: :invoke, destination_root: ROOT_DIR