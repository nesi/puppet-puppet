require 'spec_helper'
describe 'puppet::master', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
        :environment            => 'production',
      }
    end
    describe 'with default puppet, and apache and mod_passenger' do
      let :pre_condition do 
            "include puppet\nclass { 'apache': }\nclass { 'apache::mod::passenger': passenger_high_performance => 'on', passenger_max_pool_size => 12, passenger_pool_idle_time => 1500, passenger_stat_throttle_rate => 120, rack_autodetect => 'off', rails_autodetect => 'off',}"
          end
      describe "with no parameters" do
        it { should contain_class('puppet::params') }
        it { should contain_package('puppetmaster_pkg').with(
            'ensure'  => 'installed',
            'name'    => 'puppetmaster-passenger'
          )
        }
        it { should_not contain_file('environment_dir')}
        # only testing parameters that change
        it { should contain_apache__vhost('puppetmaster').with(
            'servername'    => 'test.example.org',
            'docroot'       => '/usr/share/puppet/rack/puppetmasterd/public',
            'ssl_certs_dir' => '/var/lib/puppet/ssl',
            'ssl_cert'      => '/var/lib/puppet/ssl/certs/test.example.org.pem',
            'ssl_key'       => '/var/lib/puppet/ssl/private_keys/test.example.org.pem',
            'ssl_ca'        => '/var/lib/puppet/ssl/certs/ca.pem',
            'ssl_chain'     => '/var/lib/puppet/ssl/certs/ca.pem',
            'error_log_file'  => 'puppetmaster_test.example.org_error_ssl.log',
            'access_log_file' => 'puppetmaster_test.example.org_access_ssl.log'
          )
        }
        it { should contain_exec('puppet_wipe_pkg_ssl').with(
          'command'     => 'rm -rf /var/lib/puppet/ssl',
          'path'        => ['/bin'],
          'refreshonly' => true,
          'before'      => 'File[puppet_ssl_dir]',
          'subscribe'   => 'Package[puppetmaster_pkg]'
        )}
        it { should contain_exec('puppetmaster_generate_certs').with(
          'command' => 'puppet cert list -a',
          'creates' => '/var/lib/puppet/ssl/certs',
          'path'    => ['/usr/bin'],
          'before'  => ['Service[puppet]','Service[httpd]'],
          'require' => ['File[puppet_ssl_dir]','Exec[puppet_wipe_pkg_ssl]'],
          'notify'  => 'Service[httpd]'
        )}
        it { should contain_exec('puppetmaster_generate_master_certs').with(
          'command'     => "timeout 30 puppet master --no-daemonize || echo 'Timed out is expected.'",
          'creates'     => '/var/lib/puppet/ssl/certs/test.example.org.pem',
          'path'        => ['/usr/bin', '/bin'],
          'before'      => ['Service[puppet]','Service[httpd]'],
          'require'     => 'Exec[puppetmaster_generate_certs]',
          'notify'      => 'Service[httpd]'
        )}
        it { should contain_exec('puppet_wipe_pkg_site_files').with(
          'command'     => "rm /etc/apache2/sites-available/puppetmaster* /etc/apache2/sites-enabled/puppetmaster*",
          'path'        => ['/bin'],
          'subscribe'   => 'Package[puppetmaster_pkg]',
          'refreshonly' => true,
          'before'      => 'Apache::Vhost[puppetmaster]',
          'notify'      => 'Service[httpd]'
        )}
        it { should contain_concat__fragment('puppet_conf_master').with(
          'target'  => 'puppet_conf',
          'order'   => '30'
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^\[master\]$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  # These ssl_client settings are required for running$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  # puppetmaster under mod_passenger$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  ssl_client_header         = SSL_CLIENT_S_DN$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  ssl_client_verify_header  = SSL_CLIENT_VERIFY$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').without_content(
          %r{^  manifest                  = }
        )}
        it { should contain_concat__fragment('puppet_conf_master').without_content(
          %r{^  reports                   = }
        )}
        it { should contain_concat__fragment('puppet_conf_master').without_content(
          %r{^  reporturl                 = }
        )}
        it { should contain_concat__fragment('puppet_conf_master').without_content(
          %r{^  storeconfigs              = true$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').without_content(
          %r{^  storeconfigs_backend      = }
        )}
        it { should contain_concat__fragment('puppet_conf_master').without_content(
          %r{^  autosign = }
        )}
        it { should contain_concat__fragment('puppet_conf_environments').without_content(
          %r{^  environmentpath =}
        )}
        it { should contain_concat__fragment('puppet_conf_environments').without_content(
          %r{^  basemodulepath =}
        )}
        it { should contain_concat__fragment('puppet_conf_environments').without_content(
          %r{^  default_manifest =}
        )}
        it { should contain_concat('puppet_auth_conf').with(
          'path'    => '/etc/puppet/auth.conf',
          'notify'  => 'Service[httpd]',
          'require' => 'Package[puppetmaster_pkg]'
        )}
        it { should contain_concat__fragment('auth_conf_boilerplate').with(
          'target'  => 'puppet_auth_conf',
          'order'   => 'A000'
        )}
        it { should contain_concat__fragment('auth_conf_boilerplate').with_content(
          %r{^# This file is managed by Puppet, changes may be overwitten$}
        )}
        it { should contain_concat__fragment('auth_conf_boilerplate').with_content(
          %r{^### A000: Blocks A to L contain authenticated ACLs - these rules apply only when$\s^### the client has a valid certificate and is thus authenticated$}
        )}
        # The content of these is static, just testing they exist.
        it { should contain_puppet__auth('pm_retrieve_catalog') }
        it { should contain_puppet__auth('pm_retrieve_node_definitions') }
        it { should contain_puppet__auth('pm_allow_store_reports') }
        it { should contain_puppet__auth('pm_allow_file_access') }
        it { should contain_puppet__auth__header('unauthenticated') }
        it { should contain_puppet__auth('pm_allow_ca_cert_access') }
        it { should contain_puppet__auth('pm_allow_ca_cert_retrieval') }
        it { should contain_puppet__auth('pm_allow_ca_cert_request') }
        it { should contain_puppet__auth__header('unknown') }
        it { should contain_puppet__auth('pm_v2_environments') }
        it { should contain_puppet__auth__header('defaults') }
        it { should contain_puppet__auth('pm_default_policy') }
        it { should contain_concat('puppet_fileserver_conf').with(
          'path'    => '/etc/puppet/fileserver.conf',
          'notify'  => 'Service[httpd]',
          'require' => 'Package[puppetmaster_pkg]'
        )}
        it { should contain_concat__fragment('fileserver_conf_boilerplate').with(
          'target'  => 'puppet_fileserver_conf',
          'order'   => '0'
        )}
        it { should contain_concat__fragment('fileserver_conf_boilerplate').with_content(
          %r{^# This file is managed by Puppet, changes may be overwitten$}
        )}
        it { should contain_concat__fragment('fileserver_conf_boilerplate').with_content(
          %r{^### Fileserver mount point defintions:$}
        )}
      end
      describe "with ensure => absent" do
        let :params do
          {
            :ensure => 'absent',
          }
        end
        it { should contain_class('puppet::params') }
        it { should contain_package('puppetmaster_pkg').with(
            'ensure'  => 'absent'
          )
        }
      end
      describe "with puppetmaster_package => not_puppetmaster" do
        let :params do
          {
            :puppetmaster_package => 'not_puppetmaster',
          }
        end
        it { should contain_class('puppet::params') }
        it { should contain_package('puppetmaster_pkg').with(
            'name'  => 'not_puppetmaster'
          )
        }
      end
      describe "with puppetmaster_docroot => /some/other/path" do
        let :params do
          {
            :puppetmaster_docroot => '/some/other/path',
          }
        end
        it { should contain_class('puppet::params') }
        it { should contain_apache__vhost('puppetmaster').with(
            'docroot'       => '/some/other/path'
          )
        }
      end
      describe "with servername => some.other.name" do
        let :params do
          {
            :servername => 'some.other.name',
          }
        end
        it { should contain_class('puppet::params') }
        it { should contain_apache__vhost('puppetmaster').with(
            'servername'      => 'some.other.name',
            'ssl_cert'        => '/var/lib/puppet/ssl/certs/some.other.name.pem',
            'ssl_key'         => '/var/lib/puppet/ssl/private_keys/some.other.name.pem',
            'error_log_file'  => 'puppetmaster_some.other.name_error_ssl.log',
            'access_log_file' => 'puppetmaster_some.other.name_access_ssl.log'
          )
        }
        it { should contain_exec('puppetmaster_generate_master_certs').with(
          'creates'     => '/var/lib/puppet/ssl/certs/some.other.name.pem'
        )}
      end
      describe 'with a manifest file' do
        let :params do
            { :manifest => '/etc/puppet/test/test.pp' }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  manifest                  = /etc/puppet/test/test.pp$}
        )}
      end
      describe 'with a report handler string' do
        let :params do {
          :report_handlers => 'store',
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reports                   = store$}
        )}
      end
      describe 'with a list of report handlers' do
        let :params do {
          :report_handlers => ['store','log','tagmail'],
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reports                   = store, log, tagmail$}
        )}
      end
      describe 'when setting autosign' do
        let :params do {
          :autosign => '/path/to/autosign/script.sh',
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  autosign = /path/to/autosign/script.sh$}
        )}
      end
      describe 'with a list of report handlers, including http' do
        let :params do {
          :report_handlers => ['store','log','http'],
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reports                   = store, log, http$}
        )}
        # There should be a check for a warning here. Not yet supported by rspec-puppet
      end
      describe 'with a list of report handlers, including http, and set report url' do
        let :params do {
          :report_handlers  => ['store','log','http'],
          :reporturl        => 'http://reports.example.org:3000',
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reports                   = store, log, http$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reporturl                 = http://reports.example.org:3000$}
        )}
      end
      describe 'with a report handler, without http, and set report url' do
        let :params do {
          :report_handlers  => 'store',
          :reporturl        => 'http://reports.example.org:3000',
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reports                   = store, http$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reporturl                 = http://reports.example.org:3000$}
        )}
      end
      describe 'with a list of report handlers, without http, and set report url' do
        let :params do {
          :report_handlers  => ['store','tagmail'],
          :reporturl        => 'http://reports.example.org:3000',
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reports                   = store, tagmail, http$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reporturl                 = http://reports.example.org:3000$}
        )}
      end
      describe 'with report url, and missing report handers' do
        let :params do {
          :reporturl        => 'http://reports.example.org:3000',
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reports                   = http$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  reporturl                 = http://reports.example.org:3000$}
        )}
      end
      describe 'when storeconfigs is true' do
        let :params do {
          :storeconfigs => true,
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  storeconfigs              = true$}
        )}
        it { should_not contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  storeconfigs_backend      = }
        )}
      end
      describe 'when storeconfigs is true and a backend provided' do
        let :params do {
          :storeconfigs         => true,
          :storeconfigs_backend => 'active_record',
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  storeconfigs              = true$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  storeconfigs_backend      = active_record$}
        )}
      end
      describe 'when only a storeconfigs backend provided' do
        let :params do {
          :storeconfigs_backend => 'active_record',
        }
        end
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  storeconfigs              = true$}
        )}
        it { should contain_concat__fragment('puppet_conf_master').with_content(
          %r{^  storeconfigs_backend      = active_record$}
        )}
      end
      describe 'when setting up directory environments' do
        let :params do
          {
            :environmentpath => '$confdir/environments',
            :default_manifest => '$confdir/manifest/default.pp',
            :basemodulepaths  => ['$confdir/library','$confdir/modules']
          }
        end
        it { should contain_file('environment_dir').with(
          'ensure'  => 'directory',
          'path'    => '/etc/puppet/environments',
          'require' => 'Package[puppetmaster_pkg]'
        ) }
        it { should contain_concat__fragment('puppet_conf_environments').with_content(
          %r{^  environmentpath = \$confdir/environments$}
        )}
        it { should contain_concat__fragment('puppet_conf_environments').with_content(
          %r{^  basemodulepath = \$confdir/library:\$confdir/modules:/opt/puppet/share/puppet/modules$}
        )}
        it { should contain_concat__fragment('puppet_conf_environments').with_content(
          %r{^  default_manifest = \$confdir/manifest/default.pp$}
        )}
      end
    end
  end
end
