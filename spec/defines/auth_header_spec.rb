require 'spec_helper'
describe 'puppet::auth::header', :type => :define do
  on_supported_os.each do |os, facts|
    if os != 'redhat-6-x86_64' and os != 'ubuntu-14.04-x86_64' then next end
    context "on #{os}" do
      let(:facts) { facts }
      let :title do
        'test'
      end
      let :pre_condition do
        "include puppet\nclass { 'apache': }\nclass { 'apache::mod::passenger': passenger_high_performance => 'on', passenger_max_pool_size => 12, passenger_pool_idle_time => 1500, passenger_stat_throttle_rate => 120, rack_autodetect => 'off', rails_autodetect => 'off',}\ninclude puppet::master"
      end
      describe 'with minimum parameters' do
        let :params do
          {
            :order    => 'Z',
            :content  => 'this is a test.'
          }
        end
        it { should contain_concat__fragment('puppet_auth_conf_header_Z').with(
          'target'  => 'puppet_auth_conf',
          'order'   => 'Z000'
        )}
        it { should contain_concat__fragment('puppet_auth_conf_header_Z').with_content(
          %r{^### Z000: this is a test.$}
        )}
      end
      describe 'when using an order value that already exists' do
        let :params do
          {
            :order    => 'Q',
            :content  => 'this is a test.'
          }
        end
        it do
          expect {
            should contain_concat__fragment('puppet_auth_conf_header_Q')
          }.to raise_error(Puppet::Error, /Duplicate declaration: Concat::Fragment\[puppet_auth_conf_header_Q\] is already declared/)
        end
      end
      describe 'when using an invalid order value' do
        let :params do
          {
            :order    => 'failme',
            :content  => 'this is a test.'
          }
        end
        it do
          expect {
            should contain_concat__fragment('puppet_auth_conf_header_failme')
          }.to raise_error(Puppet::Error, /validate_re\(\): "failme" does not match/)
        end
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
      'test'
    end
    let :pre_condition do
      "include puppet\nclass { 'apache': }\nclass { 'apache::mod::passenger': passenger_high_performance => 'on', passenger_max_pool_size => 12, passenger_pool_idle_time => 1500, passenger_stat_throttle_rate => 120, rack_autodetect => 'off', rails_autodetect => 'off',}\ninclude puppet::master"
    end
    it { should raise_error(Puppet::Error, /The NeSI Puppet Puppet module does not support Unknown family of operating systems/) }
  end
end