require 'rake/testtask'
require 'rails/test_unit/sub_test_task'

desc 'Runs projection tests'

desc 'Runs test:units, test:functionals, test:generators, test:integration together'
task :test do
  Rails::TestTask.test_creator(Rake.application.top_level_tasks).invoke_rake_task
end

namespace :test do
  Rails::TestTask.new(projections: "test:prepare") do |t|
    t.pattern = "test/projections/**/*_test.rb"
  end
end
