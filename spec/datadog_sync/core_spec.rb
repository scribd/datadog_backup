require 'spec_helper'

describe DatadogSync::Core do
  let(:client_double) { double }
  let(:core) {
    DatadogSync::Core.new(
      action: 'backup',
      client: client_double,
      output_dir: 'output',
      resources: [],
      logger: Logger.new('/dev/null')
    )
  }

  describe '#action' do
    subject { core.action }
    it { is_expected.to eq 'backup' }
  end

  describe '#action!' do
    it 'is expected to call the #backup method' do
    expect(core).to receive(:backup)

    core.action!
    end
  end

  describe '#client' do
    subject { core.client }
    it { is_expected.to eq client_double }
  end


  describe '#client_with_200' do
    subject { core.client_with_200(:get_all_boards) }

    context 'with 200' do
      before(:example) {
        allow(client_double).to receive(:get_all_boards).and_return(['200', {foo: :bar}])
      }

      it { is_expected.to eq({foo: :bar}) }
    end

    context 'with not 200' do
      before(:example) {
        allow(client_double).to receive(:get_all_boards).and_return(['401', {}])
      }

      it 'raises an error' do
        expect{subject}.to raise_error(RuntimeError)
      end
    end
  end

  describe '#marshall' do
    subject { core.marshall('abc123', 'output/abc-123-def.rb') }
    it 'writes a file to abc-123-def.rb' do
      allow(File).to receive(:open).with('output/abc-123-def.rb', 'w')
      expect_any_instance_of(File).to receive(:write).with('abc123')
      subject
    end
  end
end
