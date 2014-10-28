require 'spec_helper'
describe 'puppet::autosign', :type => :define do
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
    let :pre_condition do
      "include puppet\nclass { 'apache': }\nclass { 'apache::mod::passenger': passenger_high_performance => 'on', passenger_max_pool_size => 12, passenger_pool_idle_time => 1500, passenger_stat_throttle_rate => 120, rack_autodetect => 'off', rails_autodetect => 'off',}\ninclude puppet::master"
    end
    describe 'with no parameters' do
      let :title do
        '*.test'
      end
      it { should contain_concat__fragment('autosign_conf_fragment_*.test').with(
        'target'  => 'puppet_autosign_conf',
        'order'   => '*.test',
        'content' => '*.test'
      )}
    end
    describe 'with a bad name' do
      let :title do
        'test'
      end
      it { should raise_error(Puppet::Error, /validate_re\(\): "test" does not match/) }
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
      '*.test'
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
      '*.test'
    end
    # No tests.
  end

end
