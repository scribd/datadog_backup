# frozen_string_literal: true

describe 'DatadogBackup' do
  describe 'Resources' do
    describe 'LocalFilesystem' do
      describe 'ClassMethods' do
        let(:resources) do
          DatadogBackup::Resources
        end

        before(:context) do
          Dir.mkdir("#{$options[:backup_dir]}/dashboards")
          Dir.mkdir("#{$options[:backup_dir]}/monitors")
          Dir.mkdir("#{$options[:backup_dir]}/synthetics")
          File.write("#{$options[:backup_dir]}/dashboards/abc-123-def.json", '{"id": "abc-123-def", "file_type": "json"}')
          File.write("#{$options[:backup_dir]}/dashboards/ghi-456-jkl.yaml", "---\nid: ghi-456-jkl\nfile_type: yaml\n")
          File.write("#{$options[:backup_dir]}/monitors/12345.json", '{"id":12345, "file_type": "json"}')
          File.write("#{$options[:backup_dir]}/monitors/67890.yaml", "---\nid: 67890\nfile_type: yaml\n")
        end

        after(:context) do
          FileUtils.rm "#{$options[:backup_dir]}/dashboards/abc-123-def.json"
          FileUtils.rm "#{$options[:backup_dir]}/dashboards/ghi-456-jkl.yaml"
          FileUtils.rm "#{$options[:backup_dir]}/monitors/12345.json"
          FileUtils.rm "#{$options[:backup_dir]}/monitors/67890.yaml"
        end

        describe '.all_files' do
          subject { resources.all_files }

          it {
            expect(subject).to contain_exactly(
              "#{$options[:backup_dir]}/dashboards/abc-123-def.json",
              "#{$options[:backup_dir]}/dashboards/ghi-456-jkl.yaml",
              "#{$options[:backup_dir]}/monitors/12345.json",
              "#{$options[:backup_dir]}/monitors/67890.yaml"
            )
          }
        end

        describe '.all_file_ids' do
          subject { resources.all_file_ids }

          it { is_expected.to contain_exactly('abc-123-def', 'ghi-456-jkl', '12345', '67890') }
        end

        describe '.all_file_ids_for_selected_resources' do
          subject { resources.all_file_ids_for_selected_resources }

          around do |example|
            old_resources = $options[:resources]

            begin
              $options[:resources] = [DatadogBackup::Dashboards]
              example.run
            ensure
              $options[:resources] = old_resources
            end
          end

          specify do
            expect(subject).to contain_exactly('abc-123-def', 'ghi-456-jkl')
          end
        end

        describe '.class_from_id' do
          subject { resources.class_from_id('abc-123-def') }

          it { is_expected.to eq DatadogBackup::Dashboards }
        end

        describe '.find_file_by_id' do
          subject { resources.find_file_by_id('abc-123-def') }

          it { is_expected.to eq "#{$options[:backup_dir]}/dashboards/abc-123-def.json" }
        end

        describe '.load_from_file_by_id' do
          context 'when the mode is :yaml but the backup is json' do
            subject { resources.load_from_file_by_id('abc-123-def') }

            around do |example|
              old_resources = $options[:output_format]

              begin
                $options[:output_format] = :yaml
                example.run
              ensure
                $options[:output_format] = old_resources
              end
            end

            it { is_expected.to eq({ 'id' => 'abc-123-def', 'file_type' => 'json' }) }
          end

          context 'when the mode is :json but the backup is yaml' do
            subject { resources.load_from_file_by_id('ghi-456-jkl') }

            it { is_expected.to eq({ 'id' => 'ghi-456-jkl', 'file_type' => 'yaml' }) }
          end

          context 'with Integer as parameter' do
            subject { resources.load_from_file_by_id(12_345) }

            it { is_expected.to eq({ 'id' => 12_345, 'file_type' => 'json' }) }
          end
        end

        describe '.mydir' do
          context 'when the resource is DatadogBackup::Dashboards' do
            subject { DatadogBackup::Dashboards.mydir }

            it { is_expected.to eq "#{$options[:backup_dir]}/dashboards" }
          end

          context 'when the resource is DatadogBackup::Monitors' do
            subject { DatadogBackup::Monitors.mydir }

            it { is_expected.to eq "#{$options[:backup_dir]}/monitors" }
          end

          context 'when the resource is DatadogBackup::Synthetics' do
            subject { DatadogBackup::Synthetics.mydir }

            it { is_expected.to eq "#{$options[:backup_dir]}/synthetics" }
          end
        end

        describe '.purge' do
          context 'when the resource is DatadogBackup::Dashboards' do
            subject(:purge) { DatadogBackup::Dashboards.purge }

            specify do
              allow(FileUtils).to receive(:rm)
              purge
              expect(FileUtils).to have_received(:rm).with([
                                                             "#{$options[:backup_dir]}/dashboards/abc-123-def.json",
                                                             "#{$options[:backup_dir]}/dashboards/ghi-456-jkl.yaml"
                                                           ])
            end
          end
        end
      end
    end
  end
end
