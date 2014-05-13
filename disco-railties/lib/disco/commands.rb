ARGV << '--help' if ARGV.empty?

aliases = {
    'ds' => 'domainserver',
    's' => 'server',
    'ps' => 'projectionserver',
    'g' => 'generate',
    'd' => 'destroy',
    '-h' => '--help',
    '-v' => '--version',
}

help_message = <<-EOT
Usage: disco COMMAND [ARGS]

The most common disco commands are:
 generate(g)           Generate new Rails Disco code
 domainserver(ds)      Start the domain server
 projectionserver(ps)  Start the projection server
 server(s)             Start domain and projection server
 new                   Creates a new Rails Disco application
                       "disco new my_app" creates a
                       new application called MyApp in "./my_app"

In addition to those, there are:
 application           Generate the Rails Disco application code
 destroy(d)            Undo code generated with "generate"

All commands can be run with -h (or --help) for more information.
EOT

command = ARGV.shift
command = aliases[command] || command

case command
when 'generate', 'destroy'
  require 'disco/generators'

  require APP_PATH
  Rails.application.require_environment!
  Rails.application.load_generators

  require "disco/commands/#{command}"

when 'server', 'domainserver', 'projectionserver'
  Dir.chdir(File.expand_path('../../', APP_PATH)) unless File.exists?(File.expand_path('config.ru'))

  require "disco/commands/#{command}"

when 'new'
  if %w(-h --help).include?(ARGV.first)
    require 'disco/commands/application'
  else
    puts "Can't initialize a new Rails Disco application within the directory of another, please change to a non-Rails Disco directory first.\n"
    puts "Type 'disco' for help."
    exit(1)
  end

when '--version'
  require 'rails-disco/version'
  puts "Rails Disco #{RailsDisco::VERSION::STRING}"

when '--help'
  puts help_message

else
  puts "Error: Command '#{command}' not recognized"
  puts help_message
  exit(1)
end
