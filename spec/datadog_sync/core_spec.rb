require 'spec_helper'

describe DatadogSync::Core do
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:core) do
    DatadogSync::Core.new(
      action: 'backup',
      client: client_double,
      output_dir: tempdir,
      resources: [],
      logger: Logger.new('/dev/null')
    )
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

  describe '#initialize' do
    subject { core }
    it 'makes the subdirectories' do
      expect(FileUtils).to receive(:mkdir_p).with("#{tempdir}/dashboards")
      expect(FileUtils).to receive(:mkdir_p).with("#{tempdir}/monitors")
      subject
    end
  end

  describe '#myclass' do
    subject { core.myclass }
    it { is_expected.to eq 'core' }
  end

  describe '#write' do
    subject { core.write('abc123', "#{tempdir}/dashboards/abc-123-def.json") }
    let(:file_like_object) { double }

    it 'writes a file to abc-123-def.rb' do
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with("#{tempdir}/dashboards/abc-123-def.json", 'w').and_return(file_like_object)
      allow(file_like_object).to receive(:write)
      allow(file_like_object).to receive(:close)

      subject

      expect(file_like_object).to have_received(:write).with('abc123')
    end
  end

  describe '#jsondump' do
    subject { core.jsondump(a: :b) }
    it { is_expected.to eq(%({\n  "a": "b"\n})) }
  end
end
