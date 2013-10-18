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
      it { should contain_file('puppet_user_home').with(
          'ensure'  => 'directory'
        )
      }
      it { should contain_user('puppet_user').with(
          'ensure'  => 'present'
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
    end
    describe "with ensure => absent" do
      let :params do
        {
          :ensure => 'absent',
        }
      end
      it { should include_class('puppet::params') }
      it { should contain_file('puppet_user_home').with(
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
