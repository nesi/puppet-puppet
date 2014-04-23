require 'spec_helper'
describe 'puppet::master', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily   => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
      }
    end
    describe 'with default puppet, and apache and mod_passenger' do
      let :pre_condition do 
            "include puppet\nclass { 'apache': }\nclass { 'apache::mod::passenger': passenger_high_performance => 'on', passenger_max_pool_size => 12, passenger_pool_idle_time => 1500, passenger_stat_throttle_rate => 120, rack_autodetect => 'off', rails_autodetect => 'off',}"
          end
      describe "with no parameters" do
        it { should include_class('puppet::params') }
        it { should contain_package('puppetmaster_pkg').with(
            'ensure'  => 'installed',
            'name'    => 'puppetmaster-passenger'
          )
        }
        it { should contain_augeas('puppetmaster_ssl_config').with(
            'require' => 'File[puppet_conf]',
            'context' => '/files/etc/puppet/puppet.conf'
          )
        }
        describe_augeas 'puppetmaster_ssl_config', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should_not execute.with_change}
          it 'master ssl config should be set' do
            aug_get('master/ssl_client_header').should == 'SSL_CLIENT_S_DN'
            aug_get('master/ssl_client_verify_header').should == 'SSL_CLIENT_VERIFY'
          end
          it { should execute.idempotently }
        end
        describe_augeas 'puppet_conf_dedup_master', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should_not execute.with_change}
          it 'without duplicate entries in the master block' do
            should_not aug_get('main/ssl_client_header')
            should_not aug_get('agent/ssl_client_header')
            should_not aug_get('main/ssl_client_verify_header')
            should_not aug_get('agent/ssl_client_verify_header')
            should_not aug_get('main/manifest')
            should_not aug_get('agent/manifest')
            should_not aug_get('main/manifestdir')
            should_not aug_get('agent/manifestdir')
          end
          it { should execute.idempotently }
        end
        describe_augeas 'puppetmaster_manifest_config', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should_not execute.with_change}
          it 'with no manifest or manifestdir entries' do
            should_not aug_get('master/manifest')
            should_not aug_get('master/manifestdir')
          end
          it { should execute.idempotently }
        end
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
      end
      describe "with ensure => absent" do
        let :params do
          {
            :ensure => 'absent',
          }
        end
        it { should include_class('puppet::params') }
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
        it { should include_class('puppet::params') }
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
        it { should include_class('puppet::params') }
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
        it { should include_class('puppet::params') }
        it { should contain_apache__vhost('puppetmaster').with(
            'servername'      => 'some.other.name',
            'ssl_cert'        => '/var/lib/puppet/ssl/certs/some.other.name.pem',
            'ssl_key'         => '/var/lib/puppet/ssl/private_keys/some.other.name.pem',
            'error_log_file'  => 'puppetmaster_some.other.name_error_ssl.log',
            'access_log_file' => 'puppetmaster_some.other.name_access_ssl.log'
          )
        }
      end
    end
  end

  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily   => 'RedHat',
      }
    end
    it do
      expect {
        should include_class('puppet::params')
      }.to raise_error(Puppet::Error, /The NeSI Puppet Puppet module does not support RedHat family of operating systems/)
    end
  end

    context "on an Unknown OS" do
    let :facts do
      {
        :osfamily   => 'Unknown',
      }
    end
    it do
      expect {
        should include_class('puppet::params')
      }.to raise_error(Puppet::Error, /The NeSI Puppet Puppet module does not support Unknown family of operating systems/)
    end
  end

end
