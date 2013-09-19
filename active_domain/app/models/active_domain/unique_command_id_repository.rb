module ActiveDomain
  class UniqueCommandIdRepository
    def self.new_for(command_name)
      @@commands[command_name] ||= create_or_get(command_name)
      create_new @@commands[command_name]
    end

    private
    def self.initialize
    end

    def self.create_or_get(command_name)
      UniqueCommandId.where(command: command_name).first || UniqueCommandId.create!(command: command_name, last_id: 0)
    end

    def self.create_new(command)
      command.update! last_id: command.last_id + 1
      command.last_id
    end

    @@commands = {}
  end
end
