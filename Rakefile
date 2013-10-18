require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec-system/rake_task'
require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]

desc "Run puppet in noop mode and check for syntax errors."
task :validate do
  if ENV['PUPPET_GEM_VERSION'] == '~> 2.6.0'
    parse_command = 'puppet --parseonly --ignoreimport'
  else
    parse_command = 'puppet parser validate --noop'
  end
  Dir['manifests/**/*.pp'].each do |path|
   sh "#{parse_command} #{path}"
  end
end
