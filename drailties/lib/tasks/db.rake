require 'yaml'
require 'logger'
require 'active_record'

namespace :db do
  def create_database config
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

  task :environment, [:file_name] => [:db_env] do |t, args|
    if args.file_name == 'domain'
      @migration_dir = ENV['MIGRATIONS_DIR'] || 'db/migrate_domain'
    else
      @migration_dir = ENV['MIGRATIONS_DIR'] || 'db/migrate'
    end
  end

  task :configuration, [:file_name] => [:environment] do |t, args|
    @config = YAML.load_file("config/disco.yml")[DATABASE_ENV]["#{args.file_name}_database"]
  end

  task :configure_connection => :configuration do
    ActiveRecord::Base.establish_connection @config
    ActiveRecord::Base.logger = Logger.new STDOUT if @config['logger']
  end

  desc 'Create the database from config/disco.yml for the current DATABASE_ENV'
  task :create => :configure_connection do
    create_database @config
  end

  desc 'Drops the database for the current DATABASE_ENV'
  task :drop => :configure_connection do
    ActiveRecord::Base.connection.drop_database @config['database']
  end

  desc 'Migrate the database (options: VERSION=x, VERBOSE=false).'
  task :migrate => :configure_connection do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate @migration_dir, ENV['VERSION'] ? ENV['VERSION'].to_i : nil
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task :rollback => :configure_connection do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback @migration_dir, step
  end

  desc 'Retrieves the current schema version number'
  task :version => :configure_connection do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  desc 'Migrates the domain database (for use in multi project setup)'
  task :setup_domain do
    Rake::Task[:'db:configuration'].invoke('domain')
    cp_r Gem::Specification.find_by_name('active_event').gem_dir + '/db/migrate/.', 'db/migrate_domain'
    cp_r Gem::Specification.find_by_name('active_domain').gem_dir + '/db/migrate/.', 'db/migrate_domain'
    Rake::Task[:'db:migrate'].invoke
  end

  desc 'Migrates the projection database (for use in multi project setup)'
  task :setup_projection do
    Rake::Task[:'db:configuration'].invoke('projection')
    cp_r Gem::Specification.find_by_name('active_projection').gem_dir + '/db/migrate/.', 'db/migrate'
    Rake::Task[:'db:migrate'].invoke
  end

  desc 'Migrates the domain and the projection database (for use in single project setup)'
  task :setup do
    Rake::Task[:'db:setup_domain'].invoke
    Rake::Task[:'db:environment'].reenable
    Rake::Task[:'db:configure_connection'].reenable
    Rake::Task[:'db:configuration'].reenable
    Rake::Task[:'db:migrate'].reenable
    Rake::Task[:'db:setup_projection'].invoke
  end
end