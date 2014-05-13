require 'rails/generators'

module Rails
  module Generators

    def self.help(command = 'generate')
      lookup!

      namespaces = subclasses.map { |k| k.namespace }
      namespaces.sort!

      disco = []
      namespaces.each do |namespace|
        disco << namespace if namespace.split(':').first == 'disco'
      end

      puts <<-EOT
Usage: disco #{command} GENERATOR [args] [options]

General options:
  -h, [--help]     # Print generator's options and usage
  -p, [--pretend]  # Run but do not make any changes
  -f, [--force]    # Overwrite files that already exist
  -s, [--skip]     # Skip files that already exist
  -q, [--quiet]    # Suppress status output

Please choose a generator below.

      EOT

      disco.reject! { |n| hidden_namespaces.include?(n) }
      disco.map! { |n| n.sub(/^disco:/, '') }
      disco.delete('app')
      disco.delete('plugin_new')
      print_list('disco', disco)
    end

  end
end

Rails::Generators.options.deep_merge! disco: {
  command: :command,
  command_processor: :command_processor,
  migration: :migration,
  model: :model,
  projection: :projection,
  scaffold_controller: :scaffold_controller,
}
