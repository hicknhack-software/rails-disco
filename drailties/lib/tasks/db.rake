require 'yaml'
require 'logger'
require 'active_record'

namespace :drails do
  namespace :db do
    def create_database(config)
      options = {:charset => 'utf8', :collation => 'utf8_unicode_ci'}

      create_db = lambda do |config|
        ActiveRecord::Base.establish_connection config.merge('database' => nil)
        ActiveRecord::Base.connection.create_database config['database'], options
        ActiveRecord::Base.establish_connection config
      end

      begin
        create_db.call config
      rescue Mysql::Error => sqlerr
        if sqlerr.errno == 1405
          print "#{sqlerr.error}. \nPlease provide the root password for your mysql installation\n>"
          root_password = $stdin.gets.strip

          grant_statement = <<-SQL
          GRANT ALL PRIVILEGES ON #{config['database']}.*
            TO '#{config['username']}'@'localhost'
            IDENTIFIED BY '#{config['password']}' WITH GRANT OPTION;
          SQL

          create_db.call config.merge('database' => nil, 'username' => 'root', 'password' => root_password)
        else
          $stderr.puts sqlerr.error
          $stderr.puts "Couldn't create database for #{config.inspect}, charset: utf8, collation: utf8_unicode_ci"
          $stderr.puts "(if you set the charset manually, make sure you have a matching collation)" if config['charset']
        end
      end
    end

    task :db_env do
      DATABASE_ENV = ENV['DATABASE_ENV'] || 'development'
    end

    task :environment => :db_env do
      if ENV['ENV'] == 'domain'
        @migration_dir = ENV['MIGRATIONS_DIR'] || 'db/migrate_domain'
        @env = 'domain'
      else
        @migration_dir = ENV['MIGRATIONS_DIR'] || 'db/migrate'
        @env = 'projection'
      end
    end

    task :configuration => :environment do
      @config = YAML.load_file("config/disco.yml")[DATABASE_ENV]["#{@env}_database"]
    end

    task :configure_connection => :configuration do
      ActiveRecord::Base.establish_connection @config
      ActiveRecord::Base.logger = Logger.new STDOUT if @config['logger']
    end

    desc 'Create the database from config/disco.yml for the current DATABASE_ENV (options: ENV=(projection|domain))'
    task :create => :configure_connection do
      create_database @config
    end

    desc 'Drops the database for the current DATABASE_ENV (options: ENV=(projection|domain))'
    task :drop => :configure_connection do
      ActiveRecord::Base.connection.drop_database @config['database']
    end

    desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n) (options: ENV=(projection|domain)).'
    task :rollback => :configure_connection do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      ActiveRecord::Migrator.rollback @migration_dir, step
    end

    desc 'Retrieves the current schema version number'
    task :version => :configure_connection do
      puts "Current version: #{ActiveRecord::Migrator.current_version}"
    end

    desc 'Copys the migrations files from the gems directories (options: ENV=(projection|domain))'
    task :copy_migrations => :environment do
      if @env == 'domain'
        cp_r Gem::Specification.find_by_name('active_event').gem_dir + '/db/migrate/.', @migration_dir
        cp_r Gem::Specification.find_by_name('active_domain').gem_dir + '/db/migrate/.', @migration_dir
      else
        cp_r Gem::Specification.find_by_name('active_projection').gem_dir + '/db/migrate/.', @migration_dir
      end
    end

    desc 'Migrates the database (options: VERSION=x, ENV=(projection|domain))'
    task :migrate => :configure_connection do
      ActiveRecord::Migration.verbose = true
      ActiveRecord::Migrator.migrate @migration_dir, ENV['VERSION'] ? ENV['VERSION'].to_i : nil
    end

    desc 'Copys the domain migrations and migrates the domain database'
    task :setup_domain do
      ENV['ENV'] = 'domain'
      Rake::Task[:'drails:db:copy_migrations'].invoke
      Rake::Task[:'drails:db:migrate'].invoke
    end

    desc 'Copys the projection migrations and migrates the projection database'
    task :setup_projection do
      ENV['ENV'] = 'projection'
      Rake::Task[:'drails:db:copy_migrations'].invoke
      Rake::Task[:'drails:db:migrate'].invoke
    end

    desc 'Copys the gem migrations and migrates the domain and the projection database after'
    task :setup do
      Rake::Task[:'drails:db:setup_domain'].invoke
      Rake::Task[:'drails:db:environment'].reenable
      Rake::Task[:'drails:db:configure_connection'].reenable
      Rake::Task[:'drails:db:configuration'].reenable
      Rake::Task[:'drails:db:migrate'].reenable
      Rake::Task[:'drails:db:copy_migrations'].reenable
      Rake::Task[:'drails:db:setup_projection'].invoke
    end
  end
end