require 'spec_helper'
describe 'puppet::autosign', :type => :define do
  on_supported_os.each do |os, facts|
    if os != 'redhat-6-x86_64' and os != 'ubuntu-14.04-x86_64' then next end
    context "on #{os}" do
      let(:facts) { facts }
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
          'content' => "*.test\n"
        )}
      end
      describe 'with a bad name' do
        let :title do
          'test'
        end
        it { should raise_error(Puppet::Error, /validate_re\(\): "test" does not match/) }
      end
    end
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
    let :pre_condition do
      "include puppet\nclass { 'apache': }\nclass { 'apache::mod::passenger': passenger_high_performance => 'on', passenger_max_pool_size => 12, passenger_pool_idle_time => 1500, passenger_stat_throttle_rate => 120, rack_autodetect => 'off', rails_autodetect => 'off',}\ninclude puppet::master"
    end
    it { should raise_error(Puppet::Error, /The NeSI Puppet Puppet module does not support Unknown family of operating systems/) }
  end
end
