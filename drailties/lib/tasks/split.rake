def do_in_parent_dir
  cd '../'
  yield
  cd PROJECT_NAME
end

task :environment do
  PROJECT_NAME = File.basename(pwd)
end

task :create_domain => :create_frontend do
  dir = "#{PROJECT_NAME}_domain"
  app_dir = "#{dir}/app"
  config_dir = "#{dir}/config"
  bin_dir = "#{dir}/bin"
  db_dir = "#{dir}/db"
  do_in_parent_dir do
    mkdir dir unless Dir.exists?(dir)
    mkdir app_dir unless Dir.exists?(app_dir)
    move "#{FRONTEND_DIR}/domain/command_processors", app_dir
    move "#{FRONTEND_DIR}/domain/models", app_dir
    move "#{FRONTEND_DIR}/domain/projections", app_dir
    move "#{FRONTEND_DIR}/domain/validations", app_dir
    remove_dir "#{FRONTEND_DIR}/domain"
    mkdir config_dir unless Dir.exists?(config_dir)
    move "#{FRONTEND_DIR}/config/disco.yml", config_dir
    mkdir bin_dir unless Dir.exists?(bin_dir)
    move "#{FRONTEND_DIR}/bin/domain_server.rb", bin_dir
    mkdir db_dir unless Dir.exists?(db_dir)
    move "#{FRONTEND_DIR}/db/migrate_domain/.", "#{db_dir}/migrate"
    remove_dir "#{FRONTEND_DIR}/db" if Dir["#{FRONTEND_DIR}/db/*"].empty?
    #todo: gemfile and gemspec
  end
end

task :create_projection => :create_frontend do
  dir = "#{PROJECT_NAME}_projection"
  app_dir = "#{dir}/app"
  config_dir = "#{dir}/config"
  bin_dir = "#{dir}/bin"
  db_dir = "#{dir}/db"
  do_in_parent_dir do
    mkdir dir unless Dir.exists?(dir)
    mkdir app_dir unless Dir.exists?(app_dir)
    move "#{FRONTEND_DIR}/app/models", app_dir
    move "#{FRONTEND_DIR}/app/projections", app_dir
    mkdir config_dir unless Dir.exists?(config_dir)
    move "#{FRONTEND_DIR}/config/disco.yml", config_dir
    mkdir bin_dir unless Dir.exists?(bin_dir)
    move "#{FRONTEND_DIR}/bin/projection_servers.rb", bin_dir
    mkdir db_dir unless Dir.exists?(db_dir)
    move "#{FRONTEND_DIR}/db/migrate/.", "#{db_dir}/migrate"
    remove_dir "#{FRONTEND_DIR}/db" if Dir["#{FRONTEND_DIR}/db/*"].empty?
    #todo: gemfile and gemspec
  end
end

task :create_interface => :create_frontend do
  dir = "#{PROJECT_NAME}_interface"
  app_dir = "#{dir}/app"
  lib_dir = "#{dir}/lib"
  do_in_parent_dir do
    mkdir dir unless Dir.exists?(dir)
    mkdir app_dir unless Dir.exists?(app_dir)
    move "#{FRONTEND_DIR}/app/commands", app_dir
    move "#{FRONTEND_DIR}/app/events", app_dir
    move "#{FRONTEND_DIR}/app/validations", app_dir
    mkdir lib_dir unless Dir.exists?(lib_dir)
    temp_dir = "#{lib_dir}/#{PROJECT_NAME}"
    mkdir temp_dir unless Dir.exists?(temp_dir)
    move "#{FRONTEND_DIR}/lib/#{PROJECT_NAME}/domain.rb", temp_dir
    move "#{FRONTEND_DIR}/lib/#{PROJECT_NAME}.rb", "#{lib_dir}/#{dir}.rb"
    #todo: delete first line in this file
    #todo: gemfile and gemspec
  end
end

task :create_frontend => :environment do
  FRONTEND_DIR = "#{PROJECT_NAME}_frontend"
  app_dir = "#{FRONTEND_DIR}/app"
  lib_dir = "#{FRONTEND_DIR}/lib"
  do_in_parent_dir do
    mkdir FRONTEND_DIR unless Dir.exists?(FRONTEND_DIR)
    cp_r "#{PROJECT_NAME}/.", FRONTEND_DIR
    cp_r "#{FRONTEND_DIR}/lib/#{PROJECT_NAME}.rb", "#{lib_dir}/#{FRONTEND_DIR}.rb"
    #todo: delete line 2, 5 and 6 in this file
  end
end


desc 'split this'
task :split => [:create_projection, :create_domain, :create_interface] do
  puts 'done'
end