count = [ARGV.shift.to_i, 1].max
puts "Starting domain, projection (*#{count}) and Rails server..."
puts '=> Ctrl-C to shutdown all servers'
env = {'ROOT_DIR' => Dir.pwd}
pids = []
pids << Process.spawn(env, "ruby #{File.expand_path '../../server', __FILE__}/domain_server.rb")
count.times do |i|
  pids << Process.spawn(env.merge('WORKER_COUNT' => count.to_s, 'WORKER_NUMBER' => i.to_s), "ruby #{File.expand_path '../../server', __FILE__}/projection_servers.rb")
end
pids << Process.spawn(env, 'rails s')
trap(:INT) do
  pids.each do |pid|
    begin
      Process.kill 9, pid
    rescue Exception
      # do nothing
    end
  end
  puts
  exit(1)
end
Process.waitall
