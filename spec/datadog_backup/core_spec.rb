require 'spec_helper'

describe DatadogBackup::Core do
  let(:api_service_double) { double(Dogapi::APIService) }
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:core) do
    DatadogBackup::Core.new(
      action: 'backup',
      api_service: api_service_double,
      client: client_double,
      backup_dir: tempdir,
      diff_format: nil,
      resources: [],
      output_format: :json,
      logger: Logger.new('/dev/null')
    )
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

  describe '#diff' do
    before(:example) do
      allow(core).to receive(:get_by_id).and_return({ 'text' => 'diff1', 'extra' => 'diff1' })
      core.write_file('{"text": "diff2", "extra": "diff2"}', "#{tempdir}/core/diff.json")
    end

    context 'without banlist' do
      subject { core.diff('diff') }
      it {
        is_expected.to eq <<~EOF
           ---
          -extra: diff1
          -text: diff1
          +extra: diff2
          +text: diff2
        EOF
      }
    end

    context 'with banlist' do
      subject { core.diff('diff', ['extra']) }
      it {
        is_expected.to eq <<~EOF
           ---
          -text: diff1
          +text: diff2
        EOF
      }
    end
  end

  describe '#except' do
    subject { core.except({ a: :b, b: :c }, [:b]) }
    it { is_expected.to eq({ a: :b }) }
  end

  describe '#initialize' do
    subject { core }
    it 'makes the subdirectories' do
      expect(FileUtils).to receive(:mkdir_p).with("#{tempdir}/core")
      subject
    end
  end

  describe '#myclass' do
    subject { core.myclass }
    it { is_expected.to eq 'core' }
  end

  describe '#update' do
    subject { core.update_with_200('abc-123-def', '{"a": "b"}') }
    example 'it calls Dogapi::APIService.request' do
      stub_const('Dogapi::APIService::API_VERSION', 'v1')
      allow(core).to receive(:api_service).and_return(api_service_double)
      allow(core).to receive(:api_version).and_return('v1')
      allow(core).to receive(:api_resource_name).and_return('dashboard')
      expect(api_service_double).to receive(:request).with(Net::HTTP::Put, '/api/v1/dashboard/abc-123-def', nil, '{"a": "b"}', true).and_return(%w[200 Created])
      subject
    end
  end
end
