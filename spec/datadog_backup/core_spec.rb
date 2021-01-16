# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Core do
  let(:api_service_double) { double(Dogapi::APIService) }
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:core) do
    described_class.new(
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

  describe '#with_200' do
    context 'with 200' do
      subject { core.with_200 { ['200', { foo: :bar }] } }

      it { is_expected.to eq({ foo: :bar }) }
    end

    context 'with not 200' do
      subject { core.with_200 { ['400', 'Error message'] } }

      it 'raises an error' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#diff' do
    subject { core.diff('diff') }

    before do
      allow(core).to receive(:get_by_id).and_return({ 'text' => 'diff1', 'extra' => 'diff1' })
      core.write_file('{"text": "diff2", "extra": "diff2"}', "#{tempdir}/core/diff.json")
    end

    it {
      expect(subject).to eq <<~EOF
         ---
        -extra: diff1
        -text: diff1
        +extra: diff2
        +text: diff2
      EOF
    }
  end

  describe '#except' do
    subject { core.except({ a: :b, b: :c }) }

    it { is_expected.to eq({ a: :b, b: :c }) }
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

  describe '#create' do
    subject { core.create({ 'a' => 'b' }) }

    example 'it calls Dogapi::APIService.request' do
      stub_const('Dogapi::APIService::API_VERSION', 'v1')
      allow(core).to receive(:api_service).and_return(api_service_double)
      allow(core).to receive(:api_version).and_return('v1')
      allow(core).to receive(:api_resource_name).and_return('dashboard')
      expect(api_service_double).to receive(:request).with(Net::HTTP::Post,
                                                           '/api/v1/dashboard',
                                                           nil,
                                                           { 'a' => 'b' },
                                                           true).and_return(['200', { 'id' => 'whatever-id-abc' }])
      subject
    end
  end

  describe '#update' do
    subject { core.update('abc-123-def', { 'a' => 'b' }) }

    example 'it calls Dogapi::APIService.request' do
      stub_const('Dogapi::APIService::API_VERSION', 'v1')
      allow(core).to receive(:api_service).and_return(api_service_double)
      allow(core).to receive(:api_version).and_return('v1')
      allow(core).to receive(:api_resource_name).and_return('dashboard')
      expect(api_service_double).to receive(:request).with(Net::HTTP::Put,
                                                           '/api/v1/dashboard/abc-123-def',
                                                           nil,
                                                           { 'a' => 'b' },
                                                           true).and_return(['200', { 'id' => 'whatever-id-abc' }])
      subject
    end
  end

  describe '#restore' do
    before do
      allow(core).to receive(:api_service).and_return(api_service_double)
      allow(core).to receive(:api_version).and_return('api-version-string')
      allow(core).to receive(:api_resource_name).and_return('api-resource-name-string')
      allow(api_service_double).to receive(:request).with(Net::HTTP::Get,
                                                          '/api/api-version-string/api-resource-name-string/abc-123-def',
                                                          nil,
                                                          nil,
                                                          false).and_return(['200', { test: :ok }])
      allow(api_service_double).to receive(:request).with(Net::HTTP::Get,
                                                          '/api/api-version-string/api-resource-name-string/bad-123-id',
                                                          nil,
                                                          nil,
                                                          false).and_return(['404', { error: :blahblah_not_found }])
      allow(core).to receive(:load_from_file_by_id).and_return({ 'load' => 'ok' })
    end

    context 'when id exists' do
      subject { core.restore('abc-123-def') }

      example 'it calls out to update' do
        expect(core).to receive(:update).with('abc-123-def', { 'load' => 'ok' })
        subject
      end
    end

    context 'when id does not exist' do
      subject { core.restore('bad-123-id') }

      before do
        allow(api_service_double).to receive(:request).with(Net::HTTP::Put,
                                                            '/api/api-version-string/api-resource-name-string/bad-123-id',
                                                            nil, { 'load' => 'ok' },
                                                            true).and_return(['404', { 'Error' => 'my not found' }])
        allow(api_service_double).to receive(:request).with(Net::HTTP::Post,
                                                            '/api/api-version-string/api-resource-name-string',
                                                            nil,
                                                            { 'load' => 'ok' },
                                                            true).and_return(['200', { 'id' => 'my-new-id' }])
      end

      example 'it calls out to create then saves the new file and deletes the new file' do
        expect(core).to receive(:create).with({ 'load' => 'ok' }).and_return({ 'id' => 'my-new-id' })
        expect(core).to receive(:get_and_write_file).with('my-new-id')
        allow(core).to receive(:find_file_by_id).with('bad-123-id').and_return('/path/to/bad-123-id.json')
        expect(FileUtils).to receive(:rm).with('/path/to/bad-123-id.json')
        subject
      end
    end
  end
end
