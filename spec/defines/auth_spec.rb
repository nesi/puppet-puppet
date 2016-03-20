require 'spec_helper'
describe 'puppet::auth', :type => :define do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
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
          :order    => 'Q001',
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with(
        'target'  => 'puppet_auth_conf',
        'order'   => 'Q001'
      )}
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^# Q001$}
      )}
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^path test$}
      )}
    end
    describe 'with a description' do
      let :params do
        {
          :order    => 'Q001',
          :description  => 'this is a test.'
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^# Q001: this is a test.$}
      )}
    end
    describe 'with a path' do
      let :params do
        {
          :order => 'Q001',
          :path  => '/path/to/file'
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^path /path/to/file$}
      )}
    end
    describe 'when it is a regex' do
      let :params do
        {
          :order    => 'Q001',
          :is_regex => true
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^path ~ test$}
      )}
    end
    describe 'when given an environment' do
      let :params do
        {
          :order        => 'Q001',
          :environments => 'test'
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  environment test$}
      )}
    end
    describe 'when given a list of environments' do
      let :params do
        {
          :order        => 'Q001',
          :environments => ['test','dev','broken']
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  environment test, dev, broken$}
      )}
    end
    describe 'when given a method' do
      let :params do
        {
          :order   => 'Q001',
          :methods => 'find'
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  method      find$}
      )}
    end
    describe 'when given a list of methods' do
      let :params do
        {
          :order   => 'Q001',
          :methods => ['find','save','search']
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  method      find, save, search$}
      )}
    end
    describe 'when setting auth' do
      let :params do
        {
          :order => 'Q001',
          :auth  => 'any'
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  auth        any$}
      )}
    end
    describe 'when setting an invalid auth' do
      let :params do
        {
          :order => 'Q001',
          :auth  => 'trustme'
        }
      end
      it do
        expect {
          should contain_concat__fragment('puppet_auth_conf_Q001')
        }.to raise_error(Puppet::Error, /validate_re\(\): "trustme" does not match \["\^yes\$", "\^no\$", "\^on\$", "\^off\$", "\^any\$"\]/)
      end
    end
    describe 'when given an allow pattern' do
      let :params do
        {
          :order  => 'Q001',
          :allows => 'node.example.org'
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  allow       node.example.org$}
      )}
    end
    describe 'when given a list of allow patterns' do
      let :params do
        {
          :order  => 'Q001',
          :allows => ['node1.example.org','node2.example.org','node3.example.org']
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  allow       node1.example.org, node2.example.org, node3.example.org$}
      )}
    end
    describe 'when given a deny pattern' do
      let :params do
        {
          :order  => 'Q001',
          :denys  => 'node.example.org'
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  deny        node.example.org$}
      )}
    end
    describe 'when given a list of deny patterns' do
      let :params do
        {
          :order  => 'Q001',
          :denys  => ['node1.example.org','node2.example.org','node3.example.org']
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  deny        node1.example.org, node2.example.org, node3.example.org$}
      )}
    end
    describe 'when given an allow_ip pattern' do
      let :params do
        {
          :order      => 'Q001',
          :allow_ips  => '10.0.0.0/24'
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  allow_ip    10.0.0.0/24$}
      )}
    end
    describe 'when given a list of allow_ip patterns' do
      let :params do
        {
          :order      => 'Q001',
          :allow_ips  => ['10.0.0.0/24','192.168.0.1','192.168.22.*']
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  allow_ip    10.0.0.0/24, 192.168.0.1, 192.168.22.*$}
      )}
    end
    describe 'when given a deny_ip pattern' do
      let :params do
        {
          :order      => 'Q001',
          :deny_ips   => '10.0.0.0/24'
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  deny_ip     10.0.0.0/24$}
      )}
    end
    describe 'when given a list of deny_ip patterns' do
      let :params do
        {
          :order      => 'Q001',
          :deny_ips   => ['10.0.0.0/24','192.168.0.1','192.168.22.*']
        }
      end
      it { should contain_concat__fragment('puppet_auth_conf_Q001').with_content(
        %r{^  deny_ip     10.0.0.0/24, 192.168.0.1, 192.168.22.*$}
      )}
    end
    describe 'when using an order value that already exists' do
      let :params do
        {
          :order => 'Q100',
        }
      end
      it do
        expect {
          should contain_concat__fragment('puppet_auth_conf_Q001')
        }.to raise_error(Puppet::Error, /Duplicate declaration: Concat::Fragment\[puppet_auth_conf_Q100\] is already declared/)
      end
    end
    describe 'when using an invalid order value' do
      let :params do
        {
          :order => 'failme',
        }
      end
      it do
        expect {
          should contain_concat__fragment('puppet_auth_conf_failme')
        }.to raise_error(Puppet::Error, /validate_re\(\): "failme" does not match/)
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
