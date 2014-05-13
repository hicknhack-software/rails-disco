puts 'Starting Domain Command Server'
puts '=> Ctrl-C to shutdown domain server'
Signal.trap('INT') do
  puts
  exit(1)
end

Process.spawn({'ROOT_DIR' => Dir.pwd}, "ruby #{File.expand_path '../../server', __FILE__}/domain_server.rb")
Process.waitall
