# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Core do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:api_client_double) { Faraday.new { |f| f.adapter :test, stubs } }
  let(:tempdir) { Dir.mktmpdir }
  let(:core) do
    core = described_class.new(
      action: 'backup',
      backup_dir: tempdir,
      diff_format: nil,
      resources: [],
      output_format: :json
    )
    allow(core).to receive(:api_service).and_return(api_client_double)
    return core
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

    example 'it will post /api/v1/dashboard' do
      allow(core).to receive(:api_version).and_return('v1')
      allow(core).to receive(:api_resource_name).and_return('dashboard')
      stubs.post('/api/v1/dashboard', {'a' => 'b'}) {[200, {},  {'id' => 'whatever-id-abc' }]}
      subject
      stubs.verify_stubbed_calls
    end
  end

  describe '#update' do
    subject { core.update('abc-123-def', { 'a' => 'b' }) }

    example 'it puts /api/v1/dashboard' do
      allow(core).to receive(:api_version).and_return('v1')
      allow(core).to receive(:api_resource_name).and_return('dashboard')
      stubs.put('/api/v1/dashboard/abc-123-def', {'a' => 'b'}) {[200, {},  {'id' => 'whatever-id-abc' }]}
      subject
      stubs.verify_stubbed_calls
    end

    context 'when the id is not found' do
      before do
        allow(core).to receive(:api_version).and_return('v1')
        allow(core).to receive(:api_resource_name).and_return('dashboard')
        stubs.put('/api/v1/dashboard/abc-123-def', {'a' => 'b'}) {[404, {},  {'id' => 'whatever-id-abc' }]}
      end
      it 'raises an error' do
        expect { subject }.to raise_error(RuntimeError, 'update failed with error 404')
      end
    end
  end

  describe '#restore' do
    before do
      allow(core).to receive(:api_version).and_return('api-version-string')
      allow(core).to receive(:api_resource_name).and_return('api-resource-name-string')
      stubs.get('/api/api-version-string/api-resource-name-string/abc-123-def') {[200, {},  {'test'  => 'ok' }]}
      stubs.get('/api/api-version-string/api-resource-name-string/bad-123-id') {[404, {},  {'error'  => 'blahblah_not_found' }]}
      allow(core).to receive(:load_from_file_by_id).and_return({ 'load' => 'ok' })
    end

    context 'when id exists' do
      subject { core.restore('abc-123-def') }

      example 'it calls out to update' do
        expect(core).to receive(:update).with('abc-123-def', { 'load' => 'ok' })
        subject
      end
    end

    context 'when id does not exist on remote' do
      subject { core.restore('bad-123-id') }

      before do
        allow(core).to receive(:load_from_file_by_id).and_return({ 'load' => 'ok' })
        stubs.put('/api/api-version-string/api-resource-name-string/bad-123-id') {[404, {},  {'error'  => 'id not found' }]}
        stubs.post('/api/api-version-string/api-resource-name-string', {'load' => 'ok'}) {[200, {},  {'id' => 'my-new-id' }]}
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
