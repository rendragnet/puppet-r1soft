require 'spec_helper'
describe 'r1soft::agent::key' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'r1soft::agent::key default' do
          let(:pre_condition) do
            'class { "::r1soft::agent": }'
          end

          let(:title) do
            '10.10.10.10'
          end

          it { is_expected.to contain_exec('r1soft-get-key-10.10.10.10') }
          it { is_expected.to contain_exec('r1soft-get-key-10.10.10.10').with_command(%r{https://10.10.10.10}) }
        end

        context 'r1soft::agent::key absent' do
          let(:pre_condition) do
            'class { "::r1soft::agent": }'
          end

          let(:title) do
            '10.10.10.10'
          end

          let(:params) do
            {
              ensure: 'absent'
            }
          end

          it { is_expected.to contain_exec('r1soft-delete-key-10.10.10.10') }
          it { is_expected.to contain_exec('r1soft-delete-key-10.10.10.10').with_command(/10\.10\.10\.10/) }
        end
      end
    end
  end
end
