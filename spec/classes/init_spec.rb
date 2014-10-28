require 'spec_helper'
describe 'puppet', :type => :class do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :concat_basedir => '/dne',
        :environment    => 'test',
      }
    end
    describe 'with no parameters' do
      it { should contain_class('puppet::params') }
      it { should contain_package('puppet').with(
        'ensure'  => 'installed',
        'name'    => 'puppet'
      )}
      it { should contain_group('puppet_group').with(
        'ensure'      => 'present',
        'name'        => 'puppet'
      )}
      it { should contain_user('puppet_user').with(
        'ensure'      => 'present',
        'name'        => 'puppet',
        'gid'         => 'puppet',
        'comment'     => 'Puppet configuration management daemon',
        'shell'       => '/bin/false',
        'home'        => '/var/lib/puppet',
        'managehome'  => false,
        'require'     => 'Package[puppet]'
      )}
      it { should contain_file('puppet_conf_dir').with(
        'ensure'  => 'directory',
        'path'    => '/etc/puppet',
        'ignore'  => '.git',
        'require' => 'Package[puppet]'
      )}
      it { should contain_file('puppet_log_dir').with(
        'ensure'  => 'directory',
        'path'    => '/var/log/puppet',
        'require' => 'Package[puppet]'
      )}
      it { should contain_file('puppet_ssl_dir').with(
        'ensure'  => 'directory',
        'path'    => '/var/lib/puppet/ssl',
        'require' => 'Package[puppet]'
      )}
      it { should contain_file('puppet_app_dir').with(
        'ensure'  => 'directory',
        'path'    => '/usr/share/puppet',
        'force'   => true,
        'require' => 'Package[puppet]'
      )}
      it { should contain_file('puppet_var_dir').with(
        'ensure'  => 'directory',
        'path'    => '/var/lib/puppet',
        'force'   => true,
        'require' => 'Package[puppet]'
      )}
      it { should contain_file('puppet_run_dir').with(
        'ensure'  => 'directory',
        'path'    => '/var/run/puppet',
        'force'   => true,
        'require' => 'Package[puppet]'
      )}
      it { should contain_concat('puppet_conf').with(
        'ensure'  => 'present',
        'path'    => '/etc/puppet/puppet.conf',
        'require' => 'File[puppet_conf_dir]'
      )}
      it { should contain_concat__fragment('puppet_conf_base').with(
        'target'  => 'puppet_conf',
        'order'   => '00'
      )}
      it { should_not contain_concat__fragment('puppet_conf_agent')}
      it { should contain_service('puppet_agent').with(
        'ensure'      => 'stopped',
        'name'        => 'puppet',
        'enable'      => true,
        'hasrestart'  => true,
        'hasstatus'   => true,
        'require'     => 'Concat[puppet_conf]'
      )}
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^# This file is managed by Puppet, changes may be overwritten$\s*^# These settings are set with the puppet base class$\s*^\[main\]$}
      )}
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  logdir        = /var/log/puppet$}
      )}
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  vardir        = /var/lib/puppet$}
      )}
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  ssldir        = /var/lib/puppet/ssl$}
      )}
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  rundir        = /var/run/puppet$}
      )}
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  factpath      = \$vardir/lib/facter:\$vardir/facts$}
      )}
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  server        = puppet$}
      )}
      it { should contain_concat__fragment('puppet_conf_base').without_content(
        %r{^  modulepath    = }
      )}
      it { should contain_concat__fragment('puppet_conf_base').without_content(
        %r{^  # Setting templatedir is depreciated since version 3.6.0$\s*^templatedir   = }
      )}
      it { should_not contain_concat__fragment('puppet_conf_agent') }
    end
    describe 'with ensure => absent' do
      let :params do
        {
          :ensure => 'absent',
        }
      end
      it { should contain_class('puppet::params') }
      it { should contain_package('puppet').with(
        'ensure'  => 'absent'
      )}
      it { should contain_group('puppet_group').with(
        'ensure'  => 'absent'
      )}
      it { should contain_user('puppet_user').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('puppet_conf_dir').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('puppet_log_dir').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('puppet_ssl_dir').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('puppet_app_dir').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('puppet_var_dir').with(
        'ensure'  => 'absent'
      )}
      it { should contain_file('puppet_run_dir').with(
        'ensure'  => 'absent'
      )}
      it { should contain_concat('puppet_conf').with(
        'ensure'  => 'absent'
      )}
    end
    describe 'with ensure => 2.7.18' do
    # Only needs to check the ensure metaparameter is set correctly
      let :params do
        {
          :ensure => '2.7.18',
        }
      end
      it { should contain_class('puppet::params') }
      it { should contain_package('puppet').with(
        'ensure'  => '2.7.18'
      )}
      it { should contain_group('puppet_group').with(
        'ensure'      => 'present'
      )}
      it { should contain_user('puppet_user').with(
        'ensure'      => 'present'
      )}
      it { should contain_file('puppet_conf_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_log_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_ssl_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_app_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_var_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_run_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_concat('puppet_conf').with(
        'ensure'  => 'present'
      )}
    end
    describe 'with ensure => 3.3.1-1puppetlabs1' do
    # checking a complex version string
    # Only needs to check the ensure metaparameter is set correctly
      let :params do
        {
          :ensure => '3.3.1-1puppetlabs1',
        }
      end
      it { should contain_class('puppet::params') }
      it { should contain_package('puppet').with(
        'ensure'  => '3.3.1-1puppetlabs1'
      )}
      it { should contain_group('puppet_group').with(
        'ensure'      => 'present'
      )}
      it { should contain_user('puppet_user').with(
        'ensure'      => 'present'
      )}
      it { should contain_file('puppet_conf_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_log_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_ssl_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_app_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_var_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_file('puppet_run_dir').with(
        'ensure'  => 'directory'
      )}
      it { should contain_concat('puppet_conf').with(
        'ensure'  => 'present'
      )}
    end
    describe 'with puppet_package => puppet_custom' do
      let :params do
        {
          :puppet_package => 'puppet_custom',
        }
      end
      it { should contain_package('puppet').with(
        'name'  => 'puppet_custom'
      )}
    end
    describe 'with user => not_puppet' do
      let :params do
        {
          :user => 'not_puppet',
        }
      end
      it { should contain_user('puppet_user').with(
        'name'  => 'not_puppet'
      )}
    end
    describe 'with gid => not_puppet' do
      let :params do
        {
          :gid => 'not_puppet',
        }
      end
      it { should contain_group('puppet_group').with(
        'name'  => 'not_puppet'
      )}
      it { should contain_user('puppet_user').with(
        'gid'  => 'not_puppet'
      )}
    end
    describe 'with user_home => /some/other/path' do
      let :params do
        {
          :user_home => '/some/other/path',
        }
      end
      it { should contain_user('puppet_user').with(
        'home'  => '/some/other/path'
      )}
    end
    describe 'with a custom conf_dir' do
      let :params do
        {
          :conf_dir => '/some/other/path',
        }
      end
      it { should contain_file('puppet_conf_dir').with(
        'path'  => '/some/other/path'
      )}
      it { should contain_concat('puppet_conf').with(
        'path'    => '/some/other/path/puppet.conf'
      )}
    end
    describe 'with a custom ssl_dir' do
      let :params do
        {
          :ssl_dir => '/some/other/path',
        }
      end
      it { should contain_file('puppet_ssl_dir').with(
        'path'  => '/some/other/path'
      )}
    end
    describe 'with a custom log_dir' do
      let :params do
        {
          :log_dir => '/some/other/path',
        }
      end
      it { should contain_file('puppet_log_dir').with(
        'path'  => '/some/other/path'
      )}
    end
    describe 'with a single fact path string' do
      let :params do
        {
          :fact_paths => '/some/other/path',
        }
      end
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  factpath      = /some/other/path$}
      )}
    end
    describe 'with a list of fact paths' do
      let :params do
        {
          :fact_paths => ['/some/other/path','/this/path/too','/and/here'],
        }
      end
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  factpath      = /some/other/path:/this/path/too:/and/here$}
      )}
    end
    describe 'with a custom module path' do
      let :params do
        {
          :module_paths => '/some/other/path',
        }
      end
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  modulepath    = /some/other/path$}
      )}
    end
    describe 'with a list of module paths' do
      let :params do
        {
          :module_paths => ['/some/other/path','/this/path/too','/and/here'],
        }
      end
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  modulepath    = /some/other/path:/this/path/too:/and/here$}
      )}
    end
    describe 'with a custom template directory' do
      let :params do
        {
          :templatedir => '/some/other/path',
        }
      end
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  # Setting templatedir is depreciated since version 3.6.0$\s*^  templatedir   = /some/other/path$}
      )}
    end
    describe 'with a custom puppet server' do
      let :params do
        {
          :server => 'puppet.example.org',
        }
      end
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  server        = puppet.example.org$}
      )}
    end
    describe 'with a list of alternative DNS names' do
      let :params do
        {
          :dns_alt_names => ['puppet.example.org','devops.local'],
        }
      end
      it { should contain_concat__fragment('puppet_conf_base').with_content(
        %r{^  dns_alt_names = puppet.example.org,devops.local$}
      )}
    end
    describe 'with the puppet agent enabled and no other parameters' do
      let :params do
        {
          :agent => 'running',
        }
      end
      it { should contain_concat__fragment('puppet_conf_agent').with(
        'target'  => 'puppet_conf',
        'order'   => '20'
      )}
      it { should contain_service('puppet_agent').with(
        'ensure'      => 'running',
        'name'        => 'puppet',
        'enable'      => true,
        'hasrestart'  => true,
        'hasstatus'   => true,
        'require'     => 'Concat[puppet_conf]'
      )}
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^# These are set by the puppet base class when the puppet agent is running$\s*^\[agent\]$}
      )}
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  environment   = test$}
      )}
    end
    describe 'with the puppet agent enabled and reports enabled' do
      let :params do
        {
          :agent  => 'running',
          :report => true,
        }
      end
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report        = true$}
      )}
    end
    describe 'with the puppet agent enabled, reports enabled, and a report server' do
      let :params do
        {
          :agent          => 'running',
          :report         => true,
          :report_server  => 'http://reports.example.org',
        }
      end
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report        = true$}
      )}
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report_server = http://reports.example.org$}
      )}
    end
    describe 'with the puppet agent enabled and a report server, but not enabling reports' do
      let :params do
        {
          :agent          => 'running',
          :report_server  => 'http://reports.example.org',
        }
      end
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report        = true$}
      )}
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report_server = http://reports.example.org$}
      )}
    end
    describe 'with the puppet agent enabled, reports enabled, and a report server with port' do
      let :params do
        {
          :agent          => 'running',
          :report         => true,
          :report_server  => 'http://reports.example.org',
          :report_port    => '3000',
        }
      end
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report        = true$}
      )}
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report_server = http://reports.example.org$}
      )}
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report_port   = 3000$}
      )}
    end
    describe 'with the puppet agent enabled, giving a report server port, but no report server' do
      let :params do
        {
          :agent          => 'running',
          :report         => true,
          :report_port    => '3000',
        }
      end
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report        = true$}
      )}
      it { should_not contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report_server = }
      )}
      it { should_not contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report_port   = }
      )}
    end
    describe 'with the puppet agent enabled, giving a report server port, but no report server and not enabling reports' do
      let :params do
        {
          :agent          => 'running',
          :report_port    => '3000',
        }
      end
      it { should_not contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report        = }
      )}
      it { should_not contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report_server = }
      )}
      it { should_not contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  report_port   = }
      )}
    end
    describe 'with the puppet agent enabled and pluginsync enabled' do
      let :params do
        {
          :agent      => 'running',
          :pluginsync => true,
        }
      end
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  pluginsync    = true$}
      )}
    end
    describe 'with the puppet agent enabled and show diffs enabled' do
      let :params do
        {
          :agent    => 'running',
          :showdiff => true,
        }
      end
      it { should contain_concat__fragment('puppet_conf_agent').with_content(
        %r{^  showdiff      = true$}
      )}
    end
  end

  context 'on a RedHat OS' do
    let :facts do
      {
        :osfamily       => 'RedHat',
        :concat_basedir => '/dne',
      }
    end
    it { should raise_error(Puppet::Error, /The NeSI Puppet Puppet module does not support RedHat family of operating systems/) }
  end

    context 'on an Unknown OS' do
    let :facts do
      {
        :osfamily       => 'Unknown',
        :concat_basedir => '/dne',
      }
    end
    it { should raise_error(Puppet::Error, /The NeSI Puppet Puppet module does not support Unknown family of operating systems/) }
  end

end
