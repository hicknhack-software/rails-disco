puts 'Domain and Projection Server started'
puts '=> Ctrl-C to shutdown both server'
trap(:INT) { exit }
Process.spawn({"ROOT_DIR" => ROOT_DIR}, "ruby #{File.expand_path '../server', __FILE__}/domain_server.rb")
Process.spawn({"ROOT_DIR" => ROOT_DIR}, "ruby #{File.expand_path '../server', __FILE__}/projection_servers.rb")
Process.spawn({"ROOT_DIR" => ROOT_DIR}, "rails s")
Process.waitall