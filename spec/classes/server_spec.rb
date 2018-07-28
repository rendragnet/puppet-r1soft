override_facts = {}

require 'spec_helper'
describe 'r1soft::server' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(override_facts)
        end

        context 'with default values for all parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('r1soft::server') }

          # The main package
          it { is_expected.to contain_package('serverbackup-enterprise').with_ensure('installed') }

          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to contain_package('serverbackup-enterprise').that_requires('Yumrepo[r1soft]') }
          when 'Debian'
            it { is_expected.to contain_package('serverbackup-enterprise').that_requires('Apt::Source[r1soft]') }
            it { is_expected.to contain_package('serverbackup-enterprise').that_requires('Exec[apt_update]') }
          end

          # Files and configurations
          it { is_expected.to contain_exec('r1soft-set-user') }
          it { is_expected.to contain_exec('r1soft-set-user').with_creates('/usr/sbin/r1soft/data/passwordset') }
          it { is_expected.to contain_exec('r1soft-set-user').that_requires('Package[serverbackup-enterprise]') }
          it { is_expected.to contain_exec('r1soft-set-user').that_requires('File[/usr/sbin/r1soft/data/]') }

          it { is_expected.to contain_file('/usr/sbin/r1soft/conf/server.properties') }
          it { is_expected.to contain_file('/usr/sbin/r1soft/conf/server.properties').that_requires('Package[serverbackup-enterprise]') }

          it { is_expected.to contain_file('/usr/sbin/r1soft/conf/web.properties') }
          it { is_expected.to contain_file('/usr/sbin/r1soft/conf/web.properties').that_requires('Package[serverbackup-enterprise]') }

          it { is_expected.to contain_file('/usr/sbin/r1soft/data/') }
          it { is_expected.to contain_file('/usr/sbin/r1soft/data/').with_ensure('directory') }
          it { is_expected.to contain_file('/usr/sbin/r1soft/data/').that_requires('Package[serverbackup-enterprise]') }

          it { is_expected.to contain_service('cdp-server') }
          it { is_expected.to contain_service('cdp-server').with_ensure('running') }
          it { is_expected.to contain_service('cdp-server').with_enable('true') }

          # Deprecation notice
          it { is_expected.to contain_notify('manage_properties_templates is deprecated and will be removed in 1.2.0. Please use r1soft::config instead.') }
        end

        context 'disable manage_properties_templates' do
          let(:params) do
            {
              manage_properties_templates: false
            }
          end

          it { is_expected.to contain_file('/usr/sbin/r1soft/conf/api.properties') }
          it { is_expected.to contain_file('/usr/sbin/r1soft/conf/api.properties').that_requires('Package[serverbackup-enterprise]') }
          it { is_expected.not_to contain_notify('manage_properties_templates is deprecated and will be removed in 1.2.0. Please use r1soft::config instead.') }
        end
      end
    end
  end
end
