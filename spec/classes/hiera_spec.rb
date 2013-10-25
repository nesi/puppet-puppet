require 'spec_helper'
describe 'puppet::hiera', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily   => 'Debian',
      }
    end
    describe "with no parameters" do
      it { should include_class('puppet::params') }
      it { should contain_package('hiera').with(
        'ensure'  => 'installed',
        'name'    => 'hiera',
        'require' => 'Package[puppet]'
      )}
      it { should contain_augeas('puppet_conf_hiera_config').with(
        'context' => '/files/etc/puppet/puppet.conf'
      )}
      it { should contain_file('hiera_conf').with(
        'ensure'  => 'file',
        'path'    => '/etc/puppet/hiera.yaml',
        'replace' => false,
        'require' => 'Package[hiera]'
      )}
      it { should contain_file('etc_hiera_conf').with(
        'ensure'  => 'link',
        'path'    => '/etc/hiera.yaml',
        'target'  => '/etc/puppet/hiera.yaml',
        'require' => 'File[hiera_conf]'
      )}
      it { should contain_file('hiera_datadir').with(
        'ensure'  => 'directory',
        'path'    => '/etc/puppet/hieradata',
        'require' => 'Package[hiera]'
      )}
      it { should contain_file('hiera_conf').with_content(/^  - yaml$/)}
      it { should contain_file('hiera_conf').with_content(/^:yaml:$/)}
      describe_augeas 'puppet_conf_hiera_config', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
        it { should execute.with_change}
        it 'hiera_config should be set' do
          aug_get('master/hiera_config').should == '/etc/puppet/hiera.yaml'
        end
        it { should execute.idempotently }
      end
    end
    describe "with ensure => absent" do
      let :params do
        {
          :ensure => 'absent',
        }
      end
      it { should include_class('puppet::params') }
      it { should contain_package('hiera').with(
        'ensure'  => 'absent'
      )}
      it { should contain_augeas('puppet_conf_hiera_config') }
      it { should contain_file('hiera_conf').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('etc_hiera_conf').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('hiera_datadir').with(
        'ensure'  => 'absent'
      )}
      describe_augeas 'puppet_conf_hiera_config', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
        it { should_not execute.with_change}
        it 'hiera_conf should not be matched' do
          should_not aug_get('master/hiera_conf')
        end
      end
    end
    describe 'with hiera_config_file => /some/other/path' do
      let :params do
          { :hiera_config_file => '/some/other/path' }
      end
      it { should contain_file('hiera_conf').with(
        'path'    => '/some/other/path'
      )}
      describe_augeas 'puppet_conf_hiera_config', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
        it { should execute.with_change}
        it 'hiera_config_file should be /some/other/path' do
          aug_get('master/hiera_config').should == '/some/other/path'
        end
        it { should execute.idempotently }
      end
    end
    describe 'with hiera_datadir => /some/other/path' do
      let :params do
          { :hiera_datadir => '/some/other/path' }
      end
      it { should contain_file('hiera_datadir').with(
        'path'    => '/some/other/path'
      )}
    end
    describe 'with hiera_config_source => /some/other/path' do
      let :params do
          { :hiera_config_source => '/some/other/path' }
      end
      it { should contain_file('hiera_conf').with(
        'source'    => '/some/other/path'
      )}
    end
    describe 'with hiera_backend => json' do
      let :params do
          { :hiera_backend => 'json' }
      end
      it { should contain_file('hiera_conf').with_content(/^  - json$/)}
      it { should contain_file('hiera_conf').with_content(/^:json:$/)}
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
