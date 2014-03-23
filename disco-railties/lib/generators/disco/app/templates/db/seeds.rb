#
# With Rails Disco you can invoke domain commands
#
# Examples:
#
#   city_id = domain_run(CityCreateCommand.new(name: 'Chicago'))
#   domain_run(MayorCreateCommand(name: 'Emanuel', city_id: city_id)
@@can_run = true
def domain_run(command)
  Domain.run_command(command) if @@can_run
rescue DRb::DRbConnError
  puts 'no domain server for seeds'
  @@can_run = false
end
