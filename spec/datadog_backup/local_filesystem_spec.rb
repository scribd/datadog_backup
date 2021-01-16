# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::LocalFilesystem do
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:core) do
    DatadogBackup::Core.new(
      action: 'backup',
      client: client_double,
      backup_dir: tempdir,
      resources: [DatadogBackup::Dashboards],
      output_format: :json,
      logger: Logger.new('/dev/null')
    )
  end
  let(:core_yaml) do
    DatadogBackup::Core.new(
      action: 'backup',
      client: client_double,
      backup_dir: tempdir,
      resources: [],
      output_format: :yaml,
      logger: Logger.new('/dev/null')
    )
  end

  describe '#all_files' do
    subject { core.all_files }

    before do
      File.new("#{tempdir}/all_files.json", 'w')
    end

    after do
      FileUtils.rm "#{tempdir}/all_files.json"
    end

    it { is_expected.to eq(["#{tempdir}/all_files.json"]) }
  end

  describe '#all_file_ids_for_selected_resources' do
    subject { core.all_file_ids_for_selected_resources }

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
    subject { core.class_from_id('abc-123-def') }

    before do
      core.write_file('abc', "#{tempdir}/core/abc-123-def.json")
    end

    after do
      FileUtils.rm "#{tempdir}/core/abc-123-def.json"
    end

    it { is_expected.to eq DatadogBackup::Core }
  end

  describe '#dump' do
    context ':json' do
      subject { core.dump({ a: :b }) }

      it { is_expected.to eq(%({\n  "a": "b"\n})) }
    end

    context ':yaml' do
      subject { core_yaml.dump({ 'a' => 'b' }) }

      it { is_expected.to eq(%(---\na: b\n)) }
    end
  end

  describe '#filename' do
    context ':json' do
      subject { core.filename('abc-123-def') }

      it { is_expected.to eq("#{tempdir}/core/abc-123-def.json") }
    end

    context ':yaml' do
      subject { core_yaml.filename('abc-123-def') }

      it { is_expected.to eq("#{tempdir}/core/abc-123-def.yaml") }
    end
  end

  describe '#file_type' do
    subject { core.file_type("#{tempdir}/file_type.json") }

    before do
      File.new("#{tempdir}/file_type.json", 'w')
    end

    after do
      FileUtils.rm "#{tempdir}/file_type.json"
    end

    it { is_expected.to eq :json }
  end

  describe '#find_file_by_id' do
    subject { core.find_file_by_id('find_file') }

    before do
      File.new("#{tempdir}/find_file.json", 'w')
    end

    after do
      FileUtils.rm "#{tempdir}/find_file.json"
    end

    it { is_expected.to eq "#{tempdir}/find_file.json" }
  end

  describe '#load_from_file' do
    context ':json' do
      subject { core.load_from_file(%({\n  "a": "b"\n}), :json) }

      it { is_expected.to eq('a' => 'b') }
    end

    context ':yaml' do
      subject { core.load_from_file(%(---\na: b\n), :yaml) }

      it { is_expected.to eq('a' => 'b') }
    end
  end

  describe '#load_from_file_by_id' do
    context 'written in json read in yaml mode' do
      subject { core_yaml.load_from_file_by_id('abc-123-def') }

      before { core.write_file(%({"a": "b"}), "#{tempdir}/core/abc-123-def.json") }

      after { FileUtils.rm "#{tempdir}/core/abc-123-def.json" }

      it { is_expected.to eq('a' => 'b') }
    end

    context 'written in yaml read in json mode' do
      subject { core.load_from_file_by_id('abc-123-def') }

      before { core.write_file(%(---\na: b), "#{tempdir}/core/abc-123-def.yaml") }

      after { FileUtils.rm "#{tempdir}/core/abc-123-def.yaml" }

      it { is_expected.to eq('a' => 'b') }
    end

    context 'Integer as parameter' do
      subject { core.load_from_file_by_id(12_345) }

      before { core.write_file(%(---\na: b), "#{tempdir}/core/12345.yaml") }

      after { FileUtils.rm "#{tempdir}/core/12345.yaml" }

      it { is_expected.to eq('a' => 'b') }
    end
  end

  describe '#write_file' do
    subject { core.write_file('abc123', "#{tempdir}/core/abc-123-def.json") }

    let(:file_like_object) { double }

    it 'writes a file to abc-123-def.json' do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with("#{tempdir}/core/abc-123-def.json", 'w').and_return(file_like_object)
      allow(file_like_object).to receive(:write)
      allow(file_like_object).to receive(:close)

      subject

      expect(file_like_object).to have_received(:write).with('abc123')
    end
  end
end
