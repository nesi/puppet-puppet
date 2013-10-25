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
