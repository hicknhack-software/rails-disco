puts 'Starting Projection Server'
puts '=> Ctrl-C to shutdown projections server'
trap(:INT) { exit }
count = [ARGV.shift.to_i, 1].max
count.times do |i|
  Process.spawn({"ROOT_DIR" => ROOT_DIR, "WORKER_COUNT" => count.to_s, "WORKER_NUMBER" => i.to_s}, "ruby #{File.expand_path '../server', __FILE__}/projection_servers.rb")
end
Process.waitall