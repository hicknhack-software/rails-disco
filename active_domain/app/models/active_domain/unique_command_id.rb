module ActiveDomain
  class UniqueCommandId < ActiveRecord::Base
    self.table_name = 'unique_command_ids'
  end
end
