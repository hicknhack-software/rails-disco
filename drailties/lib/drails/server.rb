puts 'Starting domain, projection and Rails server...'
puts '=> Ctrl-C to shutdown all servers'
env = {'ROOT_DIR' => ROOT_DIR}
pids = []
pids << Process.spawn(env, "ruby #{File.expand_path '../server', __FILE__}/domain_server.rb")
pids << Process.spawn(env, "ruby #{File.expand_path '../server', __FILE__}/projection_servers.rb")
pids << Process.spawn(env, 'rails s')
trap(:INT) do
  pids.each do |pid|
    begin
      Process.kill 9, pid
    rescue Exception
      # do nothing
    end
  end
  exit
end
Process.waitall
