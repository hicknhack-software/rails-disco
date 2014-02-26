require 'rails/generators'

module Rails
  module Generators

    def self.help(command = 'generate')
      lookup!

      namespaces = subclasses.map { |k| k.namespace }
      namespaces.sort!

      drails = []
      namespaces.each do |namespace|
        drails << namespace if namespace.split(':').first == 'drails'
      end

      puts <<-EOT
Usage: drails #{command} GENERATOR [args] [options]

General options:
  -h, [--help]     # Print generator's options and usage
  -p, [--pretend]  # Run but do not make any changes
  -f, [--force]    # Overwrite files that already exist
  -s, [--skip]     # Skip files that already exist
  -q, [--quiet]    # Suppress status output

Please choose a generator below.

      EOT

      drails.reject! { |n| hidden_namespaces.include?(n) }
      drails.map! { |n| n.sub(/^drails:/, '') }
      drails.delete('app')
      drails.delete('plugin_new')
      print_list('drails', drails)
    end

  end
end

Rails::Generators.options.deep_merge! drails: {
    command: :command,
    command_processor: :command_processor,
    migration: :migration,
    model: :model,
    projection: :projection,
    scaffold_controller: :scaffold_controller,
}
