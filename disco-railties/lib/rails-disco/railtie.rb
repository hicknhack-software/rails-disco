require 'rails/railtie'
module RailsDisco
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'tasks/db.rake'
      load 'tasks/testing.rake'
    end
  end
end
