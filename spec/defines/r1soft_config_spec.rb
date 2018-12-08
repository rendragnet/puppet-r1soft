require 'spec_helper'
describe 'r1soft::config' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'r1soft::config without parameters' do
          let(:pre_condition) do
            'class { "::r1soft::server": }'
          end

          let(:title) do
            'foobar'
          end

          it 'fails' do
            expect { subject.call } .to raise_error(/value can't be empty/)
          end
        end

        context 'r1soft::config with manage_properties set to true' do
          let(:pre_condition) do
            'class { "::r1soft::server": manage_properties_templates => true }'
          end

          let(:title) do
            'foobar'
          end

          let(:params) do
            {
              value: 'bar'
            }
          end

          it 'fails' do
            expect { subject.call } .to raise_error(/You can't use manage_properties together with r1soft::config/)
          end
        end

        context 'r1soft::config with manage_properties set to false' do
          let(:pre_condition) do
            'class { "::r1soft::server": manage_properties_templates => false }'
          end

          let(:title) do
            'foobar'
          end

          let(:params) do
            {
              value: 'bar'
            }
          end

          it { is_expected.to contain_r1soft__config('foobar').with_value('bar') }
          it { is_expected.to contain_r1soft__config('foobar').with_target('server') }
          it { is_expected.to contain_file_line('r1soft-config-set-server-foobar') }
          it { is_expected.to contain_file_line('r1soft-config-set-server-foobar').with_path('/usr/sbin/r1soft/conf/server.properties') }
          it { is_expected.to contain_file_line('r1soft-config-set-server-foobar').with_ensure('present') }
          it { is_expected.to contain_file_line('r1soft-config-set-server-foobar').with_line('foobar=bar') }
        end

        context 'r1soft::config manage web.properties' do
          let(:pre_condition) do
            'class { "::r1soft::server": manage_properties_templates => false }'
          end

          let(:title) do
            'foobar'
          end

          let(:params) do
            {
              value: 'bar',
              target: 'web'
            }
          end

          it { is_expected.to contain_r1soft__config('foobar').with_value('bar') }
          it { is_expected.to contain_r1soft__config('foobar').with_target('web') }
          it { is_expected.to contain_file_line('r1soft-config-set-web-foobar') }
          it { is_expected.to contain_file_line('r1soft-config-set-web-foobar').with_path('/usr/sbin/r1soft/conf/web.properties') }
          it { is_expected.to contain_file_line('r1soft-config-set-web-foobar').with_ensure('present') }
          it { is_expected.to contain_file_line('r1soft-config-set-web-foobar').with_line('foobar=bar') }
        end

        context 'r1soft::config manage api.properties' do
          let(:pre_condition) do
            'class { "::r1soft::server": manage_properties_templates => false }'
          end

          let(:title) do
            'foobar'
          end

          let(:params) do
            {
              value: 'bar',
              target: 'api'
            }
          end

          it { is_expected.to contain_r1soft__config('foobar').with_value('bar') }
          it { is_expected.to contain_r1soft__config('foobar').with_target('api') }
          it { is_expected.to contain_file_line('r1soft-config-set-api-foobar') }
          it { is_expected.to contain_file_line('r1soft-config-set-api-foobar').with_path('/usr/sbin/r1soft/conf/api.properties') }
          it { is_expected.to contain_file_line('r1soft-config-set-api-foobar').with_ensure('present') }
          it { is_expected.to contain_file_line('r1soft-config-set-api-foobar').with_line('foobar=bar') }
        end
      end
    end
  end
end
