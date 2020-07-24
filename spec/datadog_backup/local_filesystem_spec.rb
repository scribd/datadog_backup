require 'spec_helper'

describe DatadogBackup::LocalFilesystem do
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:core) do
    DatadogBackup::Core.new(
      action: 'backup',
      client: client_double,
      backup_dir: tempdir,
      resources: [],
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
    before(:example) {
      File.new("#{tempdir}/all_files.json", 'w')
    }
    
    after(:example) {
      FileUtils.rm "#{tempdir}/all_files.json"
    }
    
    subject { core.all_files }
    it { is_expected.to eq(["#{tempdir}/all_files.json"] ) }
    
  end
  
  describe '#class_from_id' do
    before(:example) do
      core.write_file('abc', "#{tempdir}/core/abc-123-def.json") 
    end

    after(:example) do
      FileUtils.rm "#{tempdir}/core/abc-123-def.json"
    end
    subject { core.class_from_id('abc-123-def') }
    it { is_expected.to eq DatadogBackup::Core }
  end

  describe '#dump' do
    context ':json' do
      subject { core.dump({a: :b}) }
      it { is_expected.to eq(%({\n  "a": "b"\n})) }
    end

    context ':yaml' do
      subject { core_yaml.dump({"a" => "b"}) }
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
    before(:example) {
      File.new("#{tempdir}/file_type.json", 'w')
    }
    
    after(:example) {
      FileUtils.rm "#{tempdir}/file_type.json"
    }
    
    subject { core.file_type("#{tempdir}/file_type.json") }
    it { is_expected.to eq :json }
  end
  
  
  describe '#find_file_by_id' do
    before(:example) {
      File.new("#{tempdir}/find_file.json", 'w')
    }
    
    after(:example) {
      FileUtils.rm "#{tempdir}/find_file.json"
    }
    
    subject { core.find_file_by_id('find_file') }
    it { is_expected.to eq "#{tempdir}/find_file.json" }
    
  end

  describe '#load_from_file' do
    context ':json' do
      subject { core.load_from_file(%({\n  "a": "b"\n}), :json) }
      it { is_expected.to eq( "a" => "b" ) }
    end

    context ':yaml' do
      subject { core.load_from_file(%(---\na: b\n), :yaml) }
      it { is_expected.to eq("a" => "b") }
    end
  end

  describe '#load_from_file_by_id' do
    context 'written in json read in yaml mode' do
      before(:example) { core.write_file(%({"a": "b"}), "#{tempdir}/core/abc-123-def.json") }
      after(:example) { FileUtils.rm "#{tempdir}/core/abc-123-def.json" }

      subject { core_yaml.load_from_file_by_id('abc-123-def') }
      it { is_expected.to eq("a" => "b") }
    end
    context 'written in yaml read in json mode' do
      before(:example) { core.write_file(%(---\na: b), "#{tempdir}/core/abc-123-def.yaml") }
      after(:example) { FileUtils.rm "#{tempdir}/core/abc-123-def.yaml" }

      subject { core.load_from_file_by_id('abc-123-def') }
      it { is_expected.to eq("a" => "b") }
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
