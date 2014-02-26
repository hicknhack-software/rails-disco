count = [ARGV.shift.to_i, 1].max
puts "Starting Projection Server (#{count} processes)"
puts '=> Ctrl-C to shutdown projections server'
Signal.trap('INT') { puts; exit(1) }

count.times do |i|
  Process.spawn({'ROOT_DIR' => Dir.pwd, 'WORKER_COUNT' => count.to_s, 'WORKER_NUMBER' => i.to_s}, "ruby #{File.expand_path '../../server', __FILE__}/projection_servers.rb")
end
Process.waitall
