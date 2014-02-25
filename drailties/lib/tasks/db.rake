require 'yaml'
require 'active_record'

namespace :disco do
  namespace :db do
    def disco_database_configuration(disco_config, database)
      disco_config.reduce({}) do |map, (key, value)|
        if value.is_a?(Hash) && value.has_key?(database)
          map[key] = value[database]
        end
        map
      end
    end

    task :load_config => :environment do
      migrate_path = 'db/migrate'
      ActiveRecord::Tasks::DatabaseTasks.db_dir = Rails.application.config.paths['db'].first
      ActiveRecord::Tasks::DatabaseTasks.seed_loader = Rails.application
      ActiveRecord::Base.clear_all_connections!

      if ENV['SYSTEM'] == 'domain'
        migrate_path = 'db/migrate_domain'
        ActiveRecord::Tasks::DatabaseTasks.env = ENV['DOMAIN_ENV'] || Rails.env
        disco_config = YAML.load_file(File.join Rails.root, 'config', 'disco.yml')
        ActiveRecord::Tasks::DatabaseTasks.database_configuration = disco_database_configuration(disco_config, 'domain_database')
        ActiveRecord::Tasks::DatabaseTasks.migrations_paths =
            Array(ENV['DOMAIN_MIGRATIONS_DIR'] || Rails.application.paths[migrate_path] || File.join(Rails.root, migrate_path))
        ActiveRecord::Tasks::DatabaseTasks.fixtures_path = File.join Rails.root, 'test', 'fixtures_domain'
        ENV['SCHEMA'] = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, 'schema_domain.rb')
        ENV['DB_STRUCTURE'] || File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, 'structure_domain.sql')

      else # 'projection' - normal rails
        ActiveRecord::Tasks::DatabaseTasks.env = ENV['PROJECTION_ENV'] || Rails.env
        ActiveRecord::Tasks::DatabaseTasks.database_configuration = Rails.application.config.database_configuration
        ActiveRecord::Tasks::DatabaseTasks.migrations_paths = Array(Rails.application.paths[migrate_path])
        ActiveRecord::Tasks::DatabaseTasks.fixtures_path = File.join Rails.root, 'test', 'fixtures'
        ENV['SCHEMA'] = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, 'schema.rb')
        ENV['DB_STRUCTURE'] = File.join(ActiveRecord::Tasks::DatabaseTasks.db_dir, 'structure.sql')
      end

      if defined?(ENGINE_PATH) && (engine = Rails::Engine.find(ENGINE_PATH))
        if engine.paths[migrate_path].existent
          ActiveRecord::Tasks::DatabaseTasks.migrations_paths += Array(engine.paths[migrate_path])
        elsif Dir.exists?(File.join engine.root, migrate_path)
          ActiveRecord::Tasks::DatabaseTasks.migrations_paths << File.join(engine.root, migrate_path)
        end
      end
      Rails.env = ActiveRecord::Tasks::DatabaseTasks.env

      #puts "env = #{ActiveRecord::Tasks::DatabaseTasks.env}"
      puts "system = #{ENV['SYSTEM']}"
      #puts "config = #{ActiveRecord::Tasks::DatabaseTasks.database_configuration[ActiveRecord::Tasks::DatabaseTasks.env]}"
    end

    def connect
      ActiveRecord::Base.establish_connection ActiveRecord::Tasks::DatabaseTasks.env
    end

    namespace :migrate do
      desc 'Copys the migrations files from the gems directories (options: SYSTEM=(projection|domain))'
      task :copy => :load_config do
        target_path = ActiveRecord::Tasks::DatabaseTasks.migrations_paths.first
        gems = %w(active_event active_domain)
        gems = %w(active_projection) if ENV['SYSTEM'] != 'domain'
        gems.each do |gem|
          gem_spec = Gem::Specification.find_by_name(gem)
          if gem.nil?
            puts "missing gem #{gem}!"
          elsif Dir.exists?(File.join gem_spec.gem_dir, 'db/migrate')
            cp_r (File.join gem_spec.gem_dir, 'db/migrate/.'), target_path
          else
            puts "missing db/migrate in gem #{gem}!"
          end
        end
      end

      desc 'Copy and run migrations (options: SYSTEM=(projection|domain))'
      task :setup do
        Rake::Task[:'drails:db:migrate:copy'].invoke
        Rake::Task[:'drails:db:create'].invoke
        Rake::Task[:'drails:db:migrate'].invoke
      end

      # make sure the right database is connected
      task :down do connect end
      task :up do connect end
      task :status do connect end
    end

    task :migrate do connect end

    namespace :schema do
      task :load do connect end
    end
    namespace :structure do
      task :load do connect end
    end
  end

  load 'active_record/railties/databases.rake'

  namespace :domain do
    task :environment do
      ENV['SYSTEM'] = 'domain'
    end

    namespace :create do
      task :all => [:environment, :'drails:db:create:all']
    end

    desc 'Create the database from config/disco.yml (use create:all to create all dbs in the config)'
    task :create => [:environment, :'drails:db:create']

    namespace :drop do
      task :all => [:environment, :'drails:db:drop:all']
    end

    desc 'Drops the database using config/disco.yml (use drop:all to drop all databases)'
    task :drop => [:environment, :'drails:db:drop']

    desc 'run domain migrations'
    task :migrate => [:environment, :'drails:db:migrate']

    namespace :migrate do
      desc 'Display status of migrations'
      task :status => [:environment, :'drails:db:migrate:status']

      desc 'Copy migrations from rails disco'
      task :copy => [:environment, :'drails:db:migrate:copy']

      desc 'Copy and run migrations from rails disco'
      task :setup => [:environment, :'drails:db:migrate:setup']

      desc 'drop and create, copy and run migrations from rails disco'
      task :reset => [:environment, :'drails:db:migrate:reset']
    end

    desc 'create and load schema and seeds for domain database'
    task :setup => [:environment, :'drails:db:setup']
  end

  def reenable
    Rake::Task.tasks.map &:reenable
  end

  desc 'creates the domain and projection databases for the current environment'
  task :create do
    ENV['SYSTEM'] = 'projection'
    Rake::Task[:'drails:db:create'].invoke

    reenable
    Rake::Task[:'drails:domain:create'].invoke
  end

  desc 'drops the domain and projection databases for the current environment'
  task :drop do
    ENV['SYSTEM'] = 'projection'
    Rake::Task[:'drails:db:drop'].invoke

    reenable
    Rake::Task[:'drails:domain:drop'].invoke
  end

  desc 'migrates the domain and projection databases for the current environment'
  task :migrate do
    ENV['SYSTEM'] = 'projection'
    Rake::Task[:'drails:db:migrate'].invoke

    reenable
    Rake::Task[:'drails:domain:migrate'].invoke
  end

  desc 'Create and load schema and seeds for domain and projection databases'
  task :setup do
    ENV['SYSTEM'] = 'projection'
    Rake::Task[:'drails:db:setup'].invoke

    reenable
    Rake::Task[:'drails:domain:setup'].invoke
  end

  desc 'Drop, recreate and load schema and seeds for domain and projection databases'
  task :reset do
    ENV['SYSTEM'] = 'projection'
    Rake::Task[:'drails:db:drop'].invoke
    Rake::Task[:'drails:db:setup'].invoke

    reenable
    Rake::Task[:'drails:domain:drop'].invoke
    Rake::Task[:'drails:domain:setup'].invoke
  end

  namespace :migrate do
    desc 'copies, creates and runs all migrations for domain and projection databases for the current environment'
    task :setup do
      ENV['SYSTEM'] = 'projection'
      Rake::Task[:'drails:db:migrate:setup'].invoke

      reenable
      Rake::Task[:'drails:domain:migrate:setup'].invoke
    end

    desc 'Resets your domain and projection databases using your migrations for the current environment'
    task :reset do
      ENV['SYSTEM'] = 'projection'
      Rake::Task[:'drails:db:migrate:reset'].invoke

      reenable
      Rake::Task[:'drails:domain:migrate:reset'].invoke
    end

    desc 'Display status of domain and projection migrations'
    task :status do
      ENV['SYSTEM'] = 'projection'
      Rake::Task[:'drails:db:migrate:status'].invoke

      reenable
      Rake::Task[:'drails:domain:migrate:status'].invoke
    end
  end
end
