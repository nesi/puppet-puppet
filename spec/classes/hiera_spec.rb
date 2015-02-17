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
      it { should contain_concat__fragment('puppet_conf_hiera').with(
        'target'  => 'puppet_conf',
        'order'   => '02',
        'require' => 'Package[hiera]'
      )}
      it { should contain_file('hiera_conf').with(
        'ensure'  => 'file',
        'path'    => '/etc/puppet/hiera.yaml',
        'replace' => false,
        'owner'   => 'puppet',
        'group'   => 'puppet',
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
        'require' => 'Package[hiera]',
        'recurse' => true,
        'owner'   => 'puppet',
        'group'   => 'puppet'
      )}
      it { should contain_concat__fragment('puppet_conf_hiera').with_content(
        %r{^  # The class puppet::hiera creates a minimal hiera config to suppress warnings.$},
        %r{^  hiera_config  = /etc/puppet/hiera.yaml$}
      )}
      it { should contain_file('hiera_conf').with_content(
        %r{^# This is an example file provided by Puppet to suppress warnings.$},
        %r{^# Puppet will make no further changes once the file exists.$},
        %r{^:backends:$\s*^  - yaml$},
        %r{^:yaml:$\s*^  :datadir: /etc/puppet/hieradata},
        %r{^$:hierarchy:$\s*^  - common$}
      )}
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
      it { should_not contain_concat__fragment('puppet_conf_hiera')}
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
      it { should contain_file('etc_hiera_conf').with(
        'target'  => '/some/other/path'
      )}
      it { should contain_concat__fragment('puppet_conf_hiera').with_content(
        %r{^  hiera_config  = /some/other/path$}
      )}
    end
    describe 'with hiera_data_dir => /some/other/path' do
      let :params do
          { :hiera_data_dir => '/some/other/path' }
      end
      it { should contain_file('hiera_data_dir').with(
        'path'    => '/some/other/path'
      )}
      it { should contain_file('hiera_conf').with_content(
        %r{^:yaml:$\s*^  :datadir: /some/other/path}
      )}
    end
    describe 'with different user and group' do
      let :params do
        {
          :user  => 'someone',
          :group => 'someone'
        }
      end
      it { should contain_file('hiera_data_dir').with(
        'owner' => 'someone',
        'group' => 'someone'
      )}
      it { should contain_file('hiera_conf').with(
        'owner' => 'someone',
        'group' => 'someone'
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
      it { should contain_file('hiera_conf').with_content(
        %r{^:backends:$\s*^  - json$}
      )}
    end
  end
end
