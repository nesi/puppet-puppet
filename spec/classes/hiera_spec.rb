require 'spec_helper'
describe 'puppet::hiera', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily       => 'Debian',
        :concat_basedir => '/dne',
      }
    end
    let :pre_condition do
      'include puppet'
    end
    describe "with no parameters" do
      it { should contain_class('puppet::params') }
      it { should contain_package('hiera').with(
        'ensure'  => 'installed',
        'name'    => 'hiera',
        'require' => 'Package[puppet]'
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
      it { should contain_file('hiera_data_dir').with(
        'ensure'  => 'directory',
        'path'    => '/etc/puppet/hieradata',
        'require' => 'Package[hiera]'
      )}
      it { should contain_file('hiera_conf').with_content(/^  - yaml$/)}
      it { should contain_file('hiera_conf').with_content(/^:yaml:$/)}
    end
    describe "with ensure => absent" do
      let :params do
        {
          :ensure => 'absent',
        }
      end
      it { should contain_class('puppet::params') }
      it { should contain_package('hiera').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('hiera_conf').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('etc_hiera_conf').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('hiera_data_dir').with(
        'ensure'  => 'absent'
      )}
    end
    describe 'with hiera_conf_path => /some/other/path' do
      let :params do
          { :hiera_conf_path => '/some/other/path' }
      end
      it { should contain_file('hiera_conf').with(
        'path'    => '/some/other/path'
      )}
    end
    describe 'with hiera_data_dir => /some/other/path' do
      let :params do
          { :hiera_data_dir => '/some/other/path' }
      end
      it { should contain_file('hiera_data_dir').with(
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
        :osfamily       => 'RedHat',
        :concat_basedir => '/dne',
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
        :osfamily       => 'Unknown',
        :concat_basedir => '/dne',
      }
    end
    it do
      expect {
        should contain_class('puppet::params')
      }.to raise_error(Puppet::Error, /The NeSI Puppet Puppet module does not support Unknown family of operating systems/)
    end
  end

end
