require 'spec_helper'
describe 'puppet::conf', :type => :class do
  context 'on a Debian OS with Puppet 3.4.3' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :puppetversion  => '3.4.3'
      }
    end
    describe 'with default puppet' do
      let :pre_condition do 
        'include puppet'
      end
      describe 'with no parameters' do
        it { should include_class('puppet::params') }
        it { should contain_augeas('puppet_main_conf').with(
            'require' => 'File[puppet_conf]',
            'context' => '/files/etc/puppet/puppet.conf'
          )
        }
        it { should contain_augeas('puppet_agent_conf').with(
            'require' => 'File[puppet_conf]',
            'context' => '/files/etc/puppet/puppet.conf'
          )
        }
      end
      describe 'augeas working on puppet.conf with no parameters' do
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'pluginsync should be true' do
            aug_get('main/pluginsync').should == 'true'
          end
          it 'report should be true' do
            aug_get('main/report').should == 'true'
          end
          it 'confdir should be set' do
            aug_get('main/confdir').should == '/etc/puppet'
          end
          it 'vardir should be set' do
            aug_get('main/vardir').should == '/var/lib/puppet'
          end
          it 'ssldir should be set' do
            aug_get('main/ssldir').should == '/var/lib/puppet/ssl'
          end
          it 'vardir should be set' do
            aug_get('main/vardir').should == '/var/lib/puppet'
          end
          it 'rundir should be set' do
            aug_get('main/rundir').should == '/var/run/puppet'
          end
          it 'factpath should be set' do
            aug_get('main/factpath').should == '/var/lib/puppet/lib/facter'
          end
          it 'templatedir should be set' do
            aug_get('main/templatedir').should == '/etc/puppet/templates'
          end
          it 'modulepath should be set' do
            aug_get('main/modulepath').should == '$confdir/modules'
          end
          it { should execute.idempotently }
        end
        describe_augeas 'puppet_agent_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'environment should be production' do
            aug_get('agent/environment').should == 'production'
          end
          it 'server should be puppet' do
            aug_get('agent/server').should == 'puppet'
          end
          it 'show_diff should not be matched' do
            should_not aug_get('agent/show_diff')
          end
          it { should execute.idempotently }
        end
      end
      describe 'with environment => test' do
        let :params do
            { :environment => 'test' }
        end
        describe_augeas 'puppet_agent_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'environment should be test' do
            aug_get('agent/environment').should == 'test'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with show_diff => true' do
        let :params do
          { :show_diff => 'true' }
        end
        describe_augeas 'puppet_agent_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'show_diff should be true' do
            aug_get('agent/show_diff').should == 'true'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with pluginsync => false' do
        let :params do
            { :pluginsync => 'false' }
        end
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'pluginsync should be false' do
            aug_get('main/pluginsync').should == 'false'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with puppetmaster => puppet.example.org' do
        let :params do
            { :puppetmaster => 'puppet.example.org' }
        end
        describe_augeas 'puppet_agent_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'server should be puppet.example.org' do
            aug_get('agent/server').should == 'puppet.example.org'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with report => false' do
        let :params do
            { :report => 'false' }
        end
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'report should be false' do
            aug_get('main/report').should == 'false'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with var_dir => /some/other/path' do
        let :params do
            { :var_dir => '/some/other/path' }
        end
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'vardir should be /some/other/path' do
            aug_get('main/vardir').should == '/some/other/path'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with ssl_dir => /some/other/path' do
        let :params do
            { :ssl_dir => '/some/other/path' }
        end
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'ssldir should be /some/other/path' do
            aug_get('main/ssldir').should == '/some/other/path'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with run_dir => /some/other/path' do
        let :params do
            { :run_dir => '/some/other/path' }
        end
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'rundir should be /some/other/path' do
            aug_get('main/rundir').should == '/some/other/path'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with template_dir => /some/other/path' do
        let :params do
            { :template_dir => '/some/other/path' }
        end
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'templatedir should be /some/other/path' do
            aug_get('main/templatedir').should == '/some/other/path'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with fact_path => /some/other/path' do
        let :params do
            { :fact_path => '/some/other/path' }
        end
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'factpath should be /some/other/path' do
            aug_get('main/factpath').should == '/some/other/path'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with module_path => /some/other/path' do
        let :params do
            { :module_path => '/some/other/path' }
        end
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'modulepath should be /some/other/path' do
            aug_get('main/modulepath').should == '/some/other/path'
          end
          it { should execute.idempotently }
        end
      end
    end
    describe 'with puppet environments' do
      let :pre_condition do 
        'class {\'puppet\': environments => true, }'
      end
      describe 'with no parameters' do
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'modulepath should be set' do
            aug_get('main/modulepath').should == '$confdir/environments/production/modules:$confdir/modules'
          end
          it { should execute.idempotently }
        end
      end
      describe 'with module_path => /some/other/path' do
        let :params do
            { :module_path => '/some/other/path' }
        end
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'modulepath should be /some/other/path' do
            aug_get('main/modulepath').should == '/some/other/path'
          end
          it { should execute.idempotently }
        end
      end
    end
  end

  context 'on a Debian OS with Puppet 3.5.1' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :puppetversion  => '3.5.1'
      }
    end
    describe 'with default puppet' do
      let :pre_condition do 
        'include puppet'
      end
      describe 'with no parameters' do
        it { should include_class('puppet::params') }
        it { should contain_augeas('puppet_main_conf').with(
            'require' => 'File[puppet_conf]',
            'context' => '/files/etc/puppet/puppet.conf'
          )
        }
        it { should contain_augeas('puppet_agent_conf').with(
            'require' => 'File[puppet_conf]',
            'context' => '/files/etc/puppet/puppet.conf'
          )
        }
      end
      describe 'augeas working on puppet.conf with no parameters' do
        describe_augeas 'puppet_main_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
          it { should execute.with_change}
          it 'pluginsync should be true' do
            aug_get('main/pluginsync').should == 'true'
          end
          it 'report should be true' do
            aug_get('main/report').should == 'true'
          end
          it 'confdir should be set' do
            aug_get('main/confdir').should == '/etc/puppet'
          end
          it 'vardir should be set' do
            aug_get('main/vardir').should == '/var/lib/puppet'
          end
          it 'ssldir should be set' do
            aug_get('main/ssldir').should == '/var/lib/puppet/ssl'
          end
          it 'vardir should be set' do
            aug_get('main/vardir').should == '/var/lib/puppet'
          end
          it 'rundir should be set' do
            aug_get('main/rundir').should == '/var/run/puppet'
          end
          it 'factpath should be set' do
            aug_get('main/factpath').should == '/var/lib/puppet/lib/facter'
          end
          it 'templatedir should be set' do
            aug_get('main/templatedir').should == '/etc/puppet/templates'
          end
          it 'modulepath should be set' do
            aug_get('main/modulepath').should == '$basemodulepath'
          end
          it { should execute.idempotently }
        end
      end
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
