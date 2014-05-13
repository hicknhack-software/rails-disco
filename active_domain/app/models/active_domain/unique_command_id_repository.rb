module ActiveDomain
  class UniqueCommandIdRepository
    def self.new_for(command_name)
      @@commands[command_name] ||= create_or_get(command_name)
      create_new @@commands[command_name]
    end

    private

    def initialize
    end

    def self.create_or_get(command_name)
      UniqueCommandId.find_or_create_by! command: command_name
    end

    def self.create_new(command)
      command.update! last_id: command.last_id + 1
      command.last_id
    end

    @@commands = {}
  end
end
