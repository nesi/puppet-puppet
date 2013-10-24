require 'spec_helper'
describe 'puppet', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily   => 'Debian',
      }
    end
    describe "with no parameters" do
      it { should include_class('puppet::params') }
      it { should contain_package('puppet').with(
          'ensure'  => 'installed',
          'name'    => 'puppet'
        )
      }
      it { should contain_file('puppet_user_home').with(
          'ensure'  => 'directory',
          'path'    => '/var/lib/puppet',
          'require' => 'Package[puppet]'
        )
      }
      it { should contain_group('puppet_group').with(
          'ensure'      => 'present',
          'name'        => 'puppet'
        )
      }
      it { should contain_user('puppet_user').with(
          'ensure'      => 'present',
          'name'        => 'puppet',
          'gid'         => 'puppet',
          'comment'     => 'Puppet configuration management daemon',
          'shell'       => '/bin/false',
          'home'        => '/var/lib/puppet',
          'managehome'  => false,
          'require'     => 'Package[puppet]'
        )
      }
      it { should contain_file('puppet_conf_dir').with(
          'ensure'  => 'directory',
          'path'    => '/etc/puppet',
          'ignore'  => '.git',
          'require' => 'Package[puppet]'
        )
      }
      it { should contain_file('puppet_conf').with(
          'ensure'  => 'file',
          'path'    => '/etc/puppet/puppet.conf',
          'require' => 'File[puppet_conf_dir]'
        )
      }
      it { should contain_file('puppet_environments_dir').with(
          'ensure'  => 'absent',
          'path'    => '/etc/puppet/environments',
          'require' => 'File[puppet_conf_dir]'
        )
      }
      it { should contain_augeas('puppet_conf_firstline').with(
          'require' => 'File[puppet_conf]',
          'context' => '/files/etc/puppet/puppet.conf'
        )
      }
    end
    describe 'augeas working on puppet.conf with no parameters' do
      describe_augeas 'puppet_conf_firstline', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
        it { should execute.with_change}
        it 'first line should match comment' do
          aug_get('#comment[1]').should == 'This file is managed by Puppet, modifications may be overwritten.'
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
      it { should contain_package('puppet').with(
          'ensure'  => 'absent'
        )
      }
      it { should contain_file('puppet_user_home').with(
          'ensure'  => 'absent'
        )
      }
      it { should contain_group('puppet_group').with(
          'ensure'  => 'absent'
        )
      }
      it { should contain_user('puppet_user').with(
          'ensure'  => 'absent'
        )
      }
      it { should contain_file('puppet_conf_dir').with(
          'ensure'  => 'absent'
        )
      }
      it { should contain_file('puppet_conf').with(
          'ensure'  => 'absent'
        )
      }
      it { should contain_file('puppet_environments_dir').with(
          'ensure'  => 'absent'
        )
      }
    end
    describe "with ensure => 2.7.18" do
    # Only needs to check the ensure metaparameter is set correctly
      let :params do
        {
          :ensure => '2.7.18',
        }
      end
      it { should include_class('puppet::params') }
      it { should contain_package('puppet').with(
          'ensure'  => '2.7.18'
        )
      }
      it { should contain_file('puppet_user_home').with(
          'ensure'  => 'directory'
        )
      }
      it { should contain_group('puppet_group').with(
          'ensure'      => 'present'
        )
      }
      it { should contain_user('puppet_user').with(
          'ensure'      => 'present'
        )
      }
      it { should contain_file('puppet_conf_dir').with(
          'ensure'  => 'directory'
        )
      }
      it { should contain_file('puppet_conf').with(
          'ensure'  => 'file'
        )
      }
      it { should contain_file('puppet_environments_dir').with(
          'ensure'  => 'absent'
        )
      }
    end
    describe "with ensure => 3.3.1-1puppetlabs1" do
    # checking a complex version string
    # Only needs to check the ensure metaparameter is set correctly
      let :params do
        {
          :ensure => '3.3.1-1puppetlabs1',
        }
      end
      it { should include_class('puppet::params') }
      it { should contain_package('puppet').with(
          'ensure'  => '3.3.1-1puppetlabs1'
        )
      }
      it { should contain_file('puppet_user_home').with(
          'ensure'  => 'directory'
        )
      }
      it { should contain_group('puppet_group').with(
          'ensure'      => 'present'
        )
      }
      it { should contain_user('puppet_user').with(
          'ensure'      => 'present'
        )
      }
      it { should contain_file('puppet_conf_dir').with(
          'ensure'  => 'directory'
        )
      }
      it { should contain_file('puppet_conf').with(
          'ensure'  => 'file'
        )
      }
      it { should contain_file('puppet_environments_dir').with(
          'ensure'  => 'absent'
        )
      }
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
