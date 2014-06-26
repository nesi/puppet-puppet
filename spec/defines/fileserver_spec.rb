require 'spec_helper'
describe 'puppet::fileserver', :type => :define do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystemrelease => '6',
        :concat_basedir         => '/dne',
        :fqdn                   => 'test.example.org',
        :environment            => 'production',
      }
    end
    let :title do
      'test'
    end
    let :pre_condition do
      "include puppet\nclass { 'apache': }\nclass { 'apache::mod::passenger': passenger_high_performance => 'on', passenger_max_pool_size => 12, passenger_pool_idle_time => 1500, passenger_stat_throttle_rate => 120, rack_autodetect => 'off', rails_autodetect => 'off',}\ninclude puppet::master"
    end
    describe 'with minimum parameters' do
      let :params do
        {
          :path         => '/path/to/test',
          :description  => 'this is a test.'
        }
      end
      it { should contain_concat__fragment('fileserver_conf_fragment_test').with(
        'target'  => 'puppet_fileserver_conf',
        'order'   => 'test'
      )}
      it { should contain_concat__fragment('fileserver_conf_fragment_test').with_content(
        %r{^# this is a test.$\s^\[test\]$\s^  path  /path/to/test$\s^  allow \*$}
      )}
    end
    describe 'when ordered' do
      let :params do
        {
          :order        => '6',
          :path         => '/path/to/test',
          :description  => 'this is a test.'
        }
      end
      it { should contain_concat__fragment('fileserver_conf_fragment_test').with(
        'order'   => '6'
      )}
    end
    describe 'with a name' do
      let :params do
        {
          :name         => 'not_a_test',
          :path         => '/path/to/test',
          :description  => 'this is not a test.'
        }
      end
      it { should contain_concat__fragment('fileserver_conf_fragment_not_a_test').with(
        'order'   => 'not_a_test'
      )}
      it { should contain_concat__fragment('fileserver_conf_fragment_not_a_test').with_content(
        %r{^# this is not a test.$\s^\[not_a_test\]$\s^  path  /path/to/test$\s^  allow \*$}
      )}
    end
    describe 'when using an invalid name value' do
      let :params do
        {
          :name         => '%failme',
          :path         => '/path/to/test',
          :description  => 'this is a test.'
        }
      end
      it do
        expect {
          should contain_concat__fragment('fileserver_conf_fragment_%failme')
        }.to raise_error(Puppet::Error, /validate_re\(\): "%failme" does not match/)
      end
    end
  end

  context 'on a RedHat OS' do
    let :facts do
      {
        :osfamily       => 'RedHat',
        :concat_basedir => '/dne',
      }
    end
    let :title do
      'test'
    end
    # No tests.
  end

    context 'on an Unknown OS' do
    let :facts do
      {
        :osfamily       => 'Unknown',
        :concat_basedir => '/dne',
      }
    end
    let :title do
      'test'
    end
    # No tests.
  end

end
