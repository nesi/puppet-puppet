source ENV['GEM_SOURCE'] || "https://rubygems.org"

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion,  :require => false
else
  gem 'puppet',                 :require => false
end

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' and RUBY_VERSION < '1.9'
  gem 'rspec', '~> 2.0'
  gem 'rake', '~> 10.2'
  gem 'metadata-json-lint',     '= 0.0.11'
  gem 'puppetlabs_spec_helper', '= 1.1.1'
  gem 'puppet-lint',            '= 1.1.0'
  gem 'facter',                 '= 1.7.0'
  gem 'rspec-puppet',           '= 2.4.0'
else
  gem 'metadata-json-lint',     '>= 1.1.0'
  gem 'puppetlabs_spec_helper', '>= 0.1.0'
  gem 'puppet-lint',            '>= 1.0.0'
  gem 'facter',                 '>= 1.7.0'
end

# vim:ft=ruby
