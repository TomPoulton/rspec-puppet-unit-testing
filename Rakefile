require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'

# stdlib is a good example of a module you might have a copy of in your modules dir,
# but you wouldn't want to run the tests for stdlib
# as you hope PuppetLabs did that before they released it!
# stdlib isn't actually "installed" in this project, but it won't cause an error
EXCLUDE_MODULES = ['stdlib']

MODULES = (Dir.entries('modules') - ['.', '..'] - EXCLUDE_MODULES).select {|e| File.directory?("modules/#{e}/spec") }

module RSpec
  module Core
    class ModuleTask < ::RSpec::Core::RakeTask
      attr_accessor :module_root
      private
      def files_to_run
        Dir.chdir module_root do FileList[ pattern ].sort.map { |f| shellescape(f) } end
      end
    end
  end
end

desc 'Run all RSpec code examples'
task :rspec do
  MODULES.each do |puppet_module|
    Rake::Task["rspec:#{puppet_module}"].reenable
    Rake::Task["rspec:#{puppet_module}"].invoke
  end
end
task :default => :rspec

namespace :rspec do
  MODULES.each do |puppet_module|
    desc "Run #{puppet_module} RSpec code examples"
    RSpec::Core::ModuleTask.new(puppet_module) do |t|
      module_root = "modules/#{puppet_module}"
      t.module_root = module_root
      t.pattern = 'spec/**/*_spec.rb'
      t.rspec_opts = File.exists?("#{module_root}/spec/spec.opts") ? File.read("#{module_root}/spec/spec.opts").chomp : ''
      t.ruby_opts = "-C#{module_root}"
    end
  end
end
