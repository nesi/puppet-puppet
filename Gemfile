source 'https://rubygems.org'

group :development, :test do
  gem 'rake', '10.1.1',           :require => false
  gem 'rspec-puppet', '>=1.0.0',  :require => false
  gem 'puppetlabs_spec_helper',   :require => false
  gem 'puppet-lint',              :require => false
  gem 'rspec', '~> 2.11',         :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion,  :require => false
else
  gem 'puppet',                 :require => false
end

# vim:ft=ruby