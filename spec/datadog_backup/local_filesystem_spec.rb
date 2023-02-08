# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::LocalFilesystem do
  let(:tempdir) { Dir.mktmpdir }
  let(:resources) do
    DatadogBackup::Resources.new(
      action: 'backup',
      backup_dir: tempdir,
      resources: [DatadogBackup::Dashboards],
      output_format: :json
    )
  end
  let(:resources_yaml) do
    DatadogBackup::Resources.new(
      action: 'backup',
      backup_dir: tempdir,
      resources: [],
      output_format: :yaml
    )
  end
  let(:resources_disable_array_sort) do
    DatadogBackup::Resources.new(
      action: 'backup',
      backup_dir: tempdir,
      resources: [DatadogBackup::Dashboards],
      output_format: :json,
      disable_array_sort: true
    )
  end

  describe '#all_files' do
    subject { resources.all_files }

    before do
      File.new("#{tempdir}/all_files.json", 'w')
    end

    after do
      FileUtils.rm "#{tempdir}/all_files.json"
    end

    it { is_expected.to eq(["#{tempdir}/all_files.json"]) }
  end

  describe '#all_file_ids_for_selected_resources' do
    subject { resources.all_file_ids_for_selected_resources }

    before do
      Dir.mkdir("#{tempdir}/dashboards")
      Dir.mkdir("#{tempdir}/monitors")
      File.new("#{tempdir}/dashboards/all_files.json", 'w')
      File.new("#{tempdir}/monitors/12345.json", 'w')
    end

    after do
      FileUtils.rm "#{tempdir}/dashboards/all_files.json"
      FileUtils.rm "#{tempdir}/monitors/12345.json"
    end

    it { is_expected.to eq(['all_files']) }
  end

  describe '#class_from_id' do
    subject { resources.class_from_id('abc-123-def') }

    before do
      resources.write_file('abc', "#{tempdir}/resources/abc-123-def.json")
    end

    after do
      FileUtils.rm "#{tempdir}/resources/abc-123-def.json"
    end

    it { is_expected.to eq DatadogBackup::Resources }
  end

  describe '#dump' do
    context 'when mode is :json' do
      subject { resources.dump({ a: :b }) }

      it { is_expected.to eq(%({\n  "a": "b"\n})) }
    end

    context 'when mode is :yaml' do
      subject { resources_yaml.dump({ 'a' => 'b' }) }

      it { is_expected.to eq(%(---\na: b\n)) }
    end

    context 'when array sorting is enabled' do
      subject { resources.dump({ a: [ :c, :b ] }) }

      it { is_expected.to eq(%({\n  \"a\": [\n    \"b\",\n    \"c\"\n  ]\n})) }
    end

    context 'when array sorting is disabled' do
      subject { resources_disable_array_sort.dump({ a: [ :c, :b ] }) }

      it { is_expected.to eq(%({\n  \"a\": [\n    \"c\",\n    \"b\"\n  ]\n})) }
    end
  end

  describe '#filename' do
    context 'when mode is :json' do
      subject { resources.filename('abc-123-def') }

      it { is_expected.to eq("#{tempdir}/resources/abc-123-def.json") }
    end

    context 'when mode is :yaml' do
      subject { resources_yaml.filename('abc-123-def') }

      it { is_expected.to eq("#{tempdir}/resources/abc-123-def.yaml") }
    end
  end

  describe '#file_type' do
    subject { resources.file_type("#{tempdir}/file_type.json") }

    before do
      File.new("#{tempdir}/file_type.json", 'w')
    end

    after do
      FileUtils.rm "#{tempdir}/file_type.json"
    end

    it { is_expected.to eq :json }
  end

  describe '#find_file_by_id' do
    subject { resources.find_file_by_id('find_file') }

    before do
      File.new("#{tempdir}/find_file.json", 'w')
    end

    after do
      FileUtils.rm "#{tempdir}/find_file.json"
    end

    it { is_expected.to eq "#{tempdir}/find_file.json" }
  end

  describe '#load_from_file' do
    context 'when mode is :json' do
      subject { resources.load_from_file(%({\n  "a": "b"\n}), :json) }

      it { is_expected.to eq('a' => 'b') }
    end

    context 'when mode is :yaml' do
      subject { resources.load_from_file(%(---\na: b\n), :yaml) }

      it { is_expected.to eq('a' => 'b') }
    end
  end

  describe '#load_from_file_by_id' do
    context 'when the backup is in json but the mode is :yaml' do
      subject { resources_yaml.load_from_file_by_id('abc-123-def') }

      before { resources.write_file(%({"a": "b"}), "#{tempdir}/resources/abc-123-def.json") }

      after { FileUtils.rm "#{tempdir}/resources/abc-123-def.json" }

      it { is_expected.to eq('a' => 'b') }
    end

    context 'when the backup is in yaml but the mode is :json' do
      subject { resources.load_from_file_by_id('abc-123-def') }

      before { resources.write_file(%(---\na: b), "#{tempdir}/resources/abc-123-def.yaml") }

      after { FileUtils.rm "#{tempdir}/resources/abc-123-def.yaml" }

      it { is_expected.to eq('a' => 'b') }
    end

    context 'with Integer as parameter' do
      subject { resources.load_from_file_by_id(12_345) }

      before { resources.write_file(%(---\na: b), "#{tempdir}/resources/12345.yaml") }

      after { FileUtils.rm "#{tempdir}/resources/12345.yaml" }

      it { is_expected.to eq('a' => 'b') }
    end
  end

  describe '#write_file' do
    subject(:write_file) { resources.write_file('abc123', "#{tempdir}/resources/abc-123-def.json") }

    let(:file_like_object) { instance_double(File) }

    it 'writes a file to abc-123-def.json' do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with("#{tempdir}/resources/abc-123-def.json", 'w').and_return(file_like_object)
      allow(file_like_object).to receive(:write)
      allow(file_like_object).to receive(:close)

      write_file

      expect(file_like_object).to have_received(:write).with('abc123')
    end
  end
end
