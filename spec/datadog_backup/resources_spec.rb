# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Resources do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:api_client_double) { Faraday.new { |f| f.adapter :test, stubs } }
  let(:tempdir) { Dir.mktmpdir }
  let(:resources) do
    resources = described_class.new(
      action: 'backup',
      backup_dir: tempdir,
      diff_format: nil,
      resources: [],
      output_format: :json
    )
    allow(resources).to receive(:api_service).and_return(api_client_double)
    return resources
  end

  describe '#diff' do
    subject(:diff) { resources.diff('diff') }

    before do
      allow(resources).to receive(:get_by_id).and_return({ 'text' => 'diff1', 'extra' => 'diff1' })
      resources.write_file('{"text": "diff2", "extra": "diff2"}', "#{tempdir}/resources/diff.json")
    end

    it {
      expect(diff).to eq(<<~EODIFF
         ---
        -extra: diff1
        -text: diff1
        +extra: diff2
        +text: diff2
      EODIFF
      .chomp)
    }
  end

  describe '#except' do
    subject { resources.except({ a: :b, b: :c }) }

    it { is_expected.to eq({ a: :b, b: :c }) }
  end

  describe '#initialize' do
    subject(:myresources) { resources }

    it 'makes the subdirectories' do
      fileutils = class_double(FileUtils).as_stubbed_const
      allow(fileutils).to receive(:mkdir_p)
      myresources
      expect(fileutils).to have_received(:mkdir_p).with("#{tempdir}/resources")
    end
  end

  describe '#myclass' do
    subject { resources.myclass }

    it { is_expected.to eq 'resources' }
  end

  describe '#create' do
    subject(:create) { resources.create({ 'a' => 'b' }) }

    example 'it will post /api/v1/dashboard' do
      allow(resources).to receive(:api_version).and_return('v1')
      allow(resources).to receive(:api_resource_name).and_return('dashboard')
      stubs.post('/api/v1/dashboard', { 'a' => 'b' }) { respond_with200({ 'id' => 'whatever-id-abc' }) }
      create
      stubs.verify_stubbed_calls
    end
  end

  describe '#update' do
    subject(:update) { resources.update('abc-123-def', { 'a' => 'b' }) }

    example 'it puts /api/v1/dashboard' do
      allow(resources).to receive(:api_version).and_return('v1')
      allow(resources).to receive(:api_resource_name).and_return('dashboard')
      stubs.put('/api/v1/dashboard/abc-123-def', { 'a' => 'b' }) { respond_with200({ 'id' => 'whatever-id-abc' }) }
      update
      stubs.verify_stubbed_calls
    end

    context 'when the id is not found' do
      before do
        allow(resources).to receive(:api_version).and_return('v1')
        allow(resources).to receive(:api_resource_name).and_return('dashboard')
        stubs.put('/api/v1/dashboard/abc-123-def', { 'a' => 'b' }) { [404, {}, { 'id' => 'whatever-id-abc' }] }
      end

      it 'raises an error' do
        expect { update }.to raise_error(RuntimeError, 'update failed with error 404')
      end
    end
  end

  describe '#restore' do
    before do
      allow(resources).to receive(:api_version).and_return('api-version-string')
      allow(resources).to receive(:api_resource_name).and_return('api-resource-name-string')
      stubs.get('/api/api-version-string/api-resource-name-string/abc-123-def') { respond_with200({ 'test' => 'ok' }) }
      stubs.get('/api/api-version-string/api-resource-name-string/bad-123-id') do
        [404, {}, { 'error' => 'blahblah_not_found' }]
      end
      allow(resources).to receive(:load_from_file_by_id).and_return({ 'load' => 'ok' })
    end

    context 'when id exists' do
      subject(:restore) { resources.restore('abc-123-def') }

      example 'it calls out to update' do
        allow(resources).to receive(:update)
        restore
        expect(resources).to have_received(:update).with('abc-123-def', { 'load' => 'ok' })
      end
    end

    context 'when id does not exist on remote' do
      subject(:restore_newly) { resources.restore('bad-123-id') }

      let(:fileutils) { class_double(FileUtils).as_stubbed_const }

      before do
        allow(resources).to receive(:load_from_file_by_id).and_return({ 'load' => 'ok' })
        stubs.put('/api/api-version-string/api-resource-name-string/bad-123-id') do
          [404, {}, { 'error' => 'id not found' }]
        end
        stubs.post('/api/api-version-string/api-resource-name-string', { 'load' => 'ok' }) do
          respond_with200({ 'id' => 'my-new-id' })
        end
        allow(fileutils).to receive(:rm)
        allow(resources).to receive(:create).with({ 'load' => 'ok' }).and_return({ 'id' => 'my-new-id' })
        allow(resources).to receive(:get_and_write_file)
        allow(resources).to receive(:find_file_by_id).with('bad-123-id').and_return('/path/to/bad-123-id.json')
      end

      example 'it calls out to create' do
        restore_newly
        expect(resources).to have_received(:create).with({ 'load' => 'ok' })
      end

      example 'it saves the new file' do
        restore_newly
        expect(resources).to have_received(:get_and_write_file).with('my-new-id')
      end

      example 'it deletes the old file' do
        restore_newly
        expect(fileutils).to have_received(:rm).with('/path/to/bad-123-id.json')
      end
    end
  end
end
