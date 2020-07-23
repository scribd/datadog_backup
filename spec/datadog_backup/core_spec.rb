require 'spec_helper'

describe DatadogBackup::Core do
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

  describe '#all_files!' do
    before(:example) {
      core.write('{"text": "all_files"}', "#{tempdir}/core/all_files.json")
    }

    after(:example) {
      FileUtils.rm "#{tempdir}/core/all_files.json"
    }

    subject { core.all_files! }
    it { is_expected.to eq(["#{tempdir}/core/all_files.json"] ) }

  end

  describe '#diff' do
    before(:example) do
      core.write('{"text": "diff1"}', "#{tempdir}/core/diff.json")
      allow(core).to receive(:get_by_id).and_return({"text" => "diff2"})
    end
    subject { core.diff('diff') }
    it { is_expected.to eq [["~", "text", "diff2", "diff1"]] }
  end

  describe '#diffs' do
    before(:example) do
      core.write('{"text": "diff"}', "#{tempdir}/core/diffs1.json")
      core.write('{"text": "diff"}', "#{tempdir}/core/diffs2.json")
      core.write('{"text": "diff"}', "#{tempdir}/core/diffs3.json")
      allow(core).to receive(:get_by_id).and_return({"text" => "diff2"})
    end
    subject { core.diffs }
    it { is_expected.to eq({
                              'diffs1' => [["~", "text", "diff2", "diff"]],
                              'diffs2' => [["~", "text", "diff2", "diff"]],
                              'diffs3' => [["~", "text", "diff2", "diff"]]
                            }) }

  end

  describe '#execute!' do
    subject { core.execute! }

    it 'is expected to call the #backup method' do
      expect(core).to receive(:backup).and_return({})

      subject
    end
  end

  describe '#client' do
    subject { core.client }
    it { is_expected.to eq client_double }
  end

  describe '#client_with_200' do
    subject { core.client_with_200(:get_all_boards) }

    context 'with 200' do
      before(:example) do
        allow(client_double).to receive(:get_all_boards).and_return(['200', { foo: :bar }])
      end

      it { is_expected.to eq({ foo: :bar }) }
    end

    context 'with not 200' do
      before(:example) do
        allow(client_double).to receive(:get_all_boards).and_return(['401', {}])
      end

      it 'raises an error' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#dump' do
    context ':json' do
      subject { core.dump(a: :b) }
      it { is_expected.to eq(%({\n  "a": "b"\n})) }
    end

    context ':yaml' do
      subject { core_yaml.dump("a" => "b") }
      it { is_expected.to eq(%(---\na: b\n)) }
    end
  end

  describe '#find_file!' do
    before(:example) {
      core.write('{"text": "find_file"}', "#{tempdir}/core/find_file.json")
    }

    after(:example) {
      FileUtils.rm "#{tempdir}/core/find_file.json"
    }

    subject { core.find_file!('find_file') }
    it { is_expected.to eq "#{tempdir}/core/find_file.json" }

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

  describe '#class_from_id' do
    before(:example) { core.write(%({"a": "b"}), "#{tempdir}/core/abc-123-def.json") }
    subject { core.class_from_id('abc-123-def') }
    it { is_expected.to eq DatadogBackup::Core }
  end

  describe '#initialize' do
    subject { core }
    it 'makes the subdirectories' do
      expect(FileUtils).to receive(:mkdir_p).with("#{tempdir}/core")
      subject
    end
  end

  describe '#load' do
    context ':json' do
      subject { core.load(%({\n  "a": "b"\n})) }
      it { is_expected.to eq( "a" => "b" ) }
    end

    context ':yaml' do
      subject { core_yaml.load(%(---\na: b\n)) }
      it { is_expected.to eq("a" => "b") }
    end
  end

  describe '#load_by_id' do
    context 'written in json read in json mode' do
      before(:example) { core.write(%({"a": "b"}), "#{tempdir}/core/abc-123-def.json") }

      subject { core.load_by_id('abc-123-def') }
      it { is_expected.to eq("a" => "b") }
    end
    context 'written in yaml read in json mode' do
      before(:example) { core_yaml.write(%({"a": "b"}), "#{tempdir}/core/abc-123-def.yaml") }

      subject { core.load_by_id('abc-123-def') }
      it { is_expected.to eq("a" => "b") }
    end
  end

  describe '#myclass' do
    subject { core.myclass }
    it { is_expected.to eq 'core' }
  end

  describe '#write' do
    subject { core.write('abc123', "#{tempdir}/core/abc-123-def.json") }
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
