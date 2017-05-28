override_facts = {}

require 'spec_helper'
describe 'r1soft' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts.merge(override_facts)
        end

        context 'with default values for all parameters' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('r1soft') }

          case facts[:osfamily]
          when 'RedHat'
            it { is_expected.to contain_yumrepo('r1soft') }
          when 'Debian'
            it { is_expected.to contain_apt__source('r1soft') }
          end
        end
      end
    end
  end
end
