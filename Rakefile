begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

require 'rubocop/rake_task'
desc 'Run RuboCop style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

# task spec: [:rubocop]

require 'rdoc/task'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Requests'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'engine_cart/rake_task'
load 'rails/tasks/statistics.rake'

task ci: ['engine_cart:generate'] do
  Rake::Task['spec'].invoke
end

Bundler::GemHelper.install_tasks

task clean: 'engine_cart:clean'
task default: [:ci]
