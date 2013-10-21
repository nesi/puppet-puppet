require 'spec_helper'
describe 'puppet::conf', :type => :class do
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily   => 'Debian',
      }
    end
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
        it 'storeconfigs should be false' do
          aug_get('main/storeconfigs').should == 'false'
        end
        it 'report should be true' do
          aug_get('main/report').should == 'true'
        end
        it 'confdir should be false' do
          aug_get('main/confdir').should == '/etc/puppet'
        end
        it 'vardir should be false' do
          aug_get('main/vardir').should == '/var/lib/puppet'
        end
        it 'ssldir should be false' do
          aug_get('main/ssldir').should == '/var/lib/puppet/ssl'
        end
        it 'vardir should be false' do
          aug_get('main/vardir').should == '/var/lib/puppet'
        end
        it 'rundir should be false' do
          aug_get('main/rundir').should == '/var/run/puppet'
        end
        it 'factpath should be false' do
          aug_get('main/factpath').should == '/var/lib/puppet/lib/facter'
        end
        it 'templatedir should be false' do
          aug_get('main/templatedir').should == '$confdir/templates'
        end
        it { should execute.idempotently }
      end
      describe_augeas 'puppet_agent_conf', :lens => 'Puppet', :target => 'etc/puppet/puppet.conf', :fixtures => 'etc/puppet/debian.puppet.conf' do
        it { should execute.with_change}
        it 'environment should be production' do
          aug_get('agent/environment').should == 'production'
        end
        it 'show_diff should not be matched' do
          should_not aug_get('agent/show_diff')
        end
        it { should execute.idempotently }
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
