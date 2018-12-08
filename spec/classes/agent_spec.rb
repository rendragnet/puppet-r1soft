override_facts = {}

require 'spec_helper'
describe 'r1soft::agent' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(override_facts)
        end

        context 'with default values for all parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('r1soft::agent') }

          # The main package
          it { is_expected.to contain_package('serverbackup-enterprise-agent').with_ensure('installed') }
          it { is_expected.to contain_service('cdp-agent').with_ensure('running') }
          it { is_expected.to contain_exec('r1soft-get-module') }

          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to contain_package('kernel-devel') }
          end
        end

        context 'with service not running' do
          let(:params) do
            {
              service_ensure: 'stopped'
            }
          end

          it { is_expected.to contain_service('cdp-agent').with_ensure('stopped') }
        end

        context 'with package absent' do
          let(:params) do
            {
              package_ensure: 'absent'
            }
          end

          it { is_expected.to contain_package('serverbackup-enterprise-agent').with_ensure('absent') }
        end
      end
    end
  end
end
