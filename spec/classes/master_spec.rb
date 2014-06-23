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
        it { should contain_class('puppet::params') }
        it { should contain_package('puppetmaster_pkg').with(
            'ensure'  => 'installed',
            'name'    => 'puppetmaster-passenger'
          )
        }
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
      end
      describe 'with a manifest file and without fixing manifestdir' do
        let :params do
            { :manifest => '/etc/puppet/test/test.pp' }
        end

      end
      describe 'with a manifest directory and without fixing manifestdir' do
        let :params do
            { :manifest => '/etc/puppet/test/test' }
        end

      end
      describe 'with a manifest file and with fixing manifestdir' do
        let :params do {
          :manifest         => '/etc/puppet/test/test.pp',
          :fix_manifestdir => true,
        }
        end
 
      end
      describe 'with a manifest directory and with fixing manifestdir' do
        let :params do {
          :manifest         => '/etc/puppet/test/test',
          :fix_manifestdir => true,
        }
        end

      end
      describe 'with a report handler string' do
        let :params do {
          :report_handlers => 'store',
        }
        end

      end
      describe 'with a list of report handlers' do
        let :params do {
          :report_handlers => ['store','log','tagmail'],
        }
        end

      end
      describe 'with a list of report handlers, including http' do
        let :params do {
          :report_handlers => ['store','log','http'],
        }
        end

      end
      describe 'with a list of report handlers, including http, and set report url' do
        let :params do {
          :report_handlers  => ['store','log','http'],
          :reporturl        => 'http://reports.example.org:3000',
        }
        end

      end
      describe 'with a list of report handlers, without http, and set report url' do
        let :params do {
          :report_handlers  => ['store','tagmail'],
          :reporturl        => 'http://reports.example.org:3000',
        }
        end

      end
      describe 'with report url, and missing report handers' do
        let :params do {
          :reporturl        => 'http://reports.example.org:3000',
        }
        end

      end
      describe 'when storeconfigs is true' do
        let :params do {
          :storeconfigs => true,
        }
        end

      end
      describe 'when storeconfigs is true and a backend provided' do
        let :params do {
          :storeconfigs         => true,
          :storeconfigs_backend => 'active_record',
        }
        end

      end
      describe 'when only a storeconfigs backend provided' do
        let :params do {
          :storeconfigs_backend => 'active_record',
        }
        end

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
        should contain_class('puppet::params')
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
        should contain_class('puppet::params')
      }.to raise_error(Puppet::Error, /The NeSI Puppet Puppet module does not support Unknown family of operating systems/)
    end
  end

end
