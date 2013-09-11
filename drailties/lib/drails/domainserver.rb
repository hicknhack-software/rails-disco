puts 'Starting Domain Command Server'
puts '=> Ctrl-C to shutdown domain server'
trap(:INT) { exit }
Process.spawn({"ROOT_DIR" => ROOT_DIR}, "ruby #{File.expand_path '../server', __FILE__}/domain_server.rb")
Process.waitall