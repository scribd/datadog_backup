# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Synthetics do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:api_client_double) { Faraday.new { |f| f.adapter :test, stubs } }
  let(:tempdir) { Dir.mktmpdir } # TODO: delete afterward
  let(:synthetics) do
    synthetics = described_class.new(
      action: 'backup',
      backup_dir: tempdir,
      output_format: :json,
      resources: []
    )
    allow(synthetics).to receive(:api_service).and_return(api_client_double)
    return synthetics
  end
  let(:api_test) do
    { 'config' => { 'assertions' => [{ 'operator' => 'contains', 'property' => 'set-cookie', 'target' => '_user_id', 'type' => 'header' },
                                     { 'operator' => 'contains', 'target' => 'body message', 'type' => 'body' },
                                     { 'operator' => 'is', 'property' => 'content-type', 'target' => 'text/html; charset=utf-8', 'type' => 'header' },
                                     { 'operator' => 'is', 'target' => 200, 'type' => 'statusCode' },
                                     { 'operator' => 'lessThan', 'target' => 5000, 'type' => 'responseTime' }],
                    'request' => { 'headers' => { 'User-Agent' => 'Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0',
                                                  'cookie' => '_a=12345; _example_session=abc123' },
                                   'method' => 'GET',
                                   'url' => 'https://www.example.com/' } },
      'creator' => { 'email' => 'user@example.com', 'handle' => 'user@example.com', 'name' => 'Hugh Zer' },
      'locations' => ['aws:ap-northeast-1', 'aws:eu-central-1', 'aws:eu-west-2', 'aws:us-west-2'],
      'message' => 'TEST: This is a test',
      'monitor_id' => 12_345,
      'name' => 'TEST: This is a test',
      'options' => { 'follow_redirects' => true,
                     'httpVersion' => 'http1',
                     'min_failure_duration' => 120,
                     'min_location_failed' => 2,
                     'monitor_options' => { 'renotify_interval' => 0 },
                     'monitor_priority' => 1,
                     'retry' => { 'count' => 1, 'interval' => 500 },
                     'tick_every' => 120 },
      'public_id' => 'abc-123-def',
      'status' => 'live',
      'subtype' => 'http',
      'tags' => ['env:test'],
      'type' => 'api' }
  end
  let(:browser_test) do
    { 'config' => { 'assertions' => [],
                    'configVariables' => [],
                    'request' => { 'headers' => {}, 'method' => 'GET', 'url' => 'https://www.example.com' },
                    'setCookie' => nil,
                    'variables' => [] },
      'creator' => { 'email' => 'user@example.com',
                     'handle' => 'user@example.com',
                     'name' => 'Hugh Zer' },
      'locations' => ['aws:us-east-2'],
      'message' => 'Test message',
      'monitor_id' => 12_345,
      'name' => 'www.example.com',
      'options' => { 'ci' => { 'executionRule' => 'non_blocking' },
                     'device_ids' => ['chrome.laptop_large', 'chrome.mobile_small'],
                     'disableCors' => false,
                     'disableCsp' => false,
                     'ignoreServerCertificateError' => false,
                     'min_failure_duration' => 300,
                     'min_location_failed' => 1,
                     'monitor_options' => { 'renotify_interval' => 0 },
                     'noScreenshot' => false,
                     'retry' => { 'count' => 0, 'interval' => 1000 },
                     'tick_every' => 900 },
      'public_id' => '456-ghi-789',
      'status' => 'live',
      'tags' => ['env:test'],
      'type' => 'browser' }
  end
  let(:all_synthetics) { respond_with200({ 'tests' => [api_test, browser_test] }) }
  let(:api_synthetic) { respond_with200(api_test) }
  let(:browser_synthetic) { respond_with200(browser_test) }

  before do
    stubs.get('/api/v1/synthetics/tests') { all_synthetics }
    stubs.get('/api/v1/synthetics/tests/api/abc-123-def') { api_synthetic }
    stubs.get('/api/v1/synthetics/tests/browser/456-ghi-789') { browser_synthetic }
  end

  describe '#all' do
    subject { synthetics.all }

    it { is_expected.to contain_exactly(api_test, browser_test) }
  end

  describe '#backup' do
    subject(:backup) { synthetics.backup }

    let(:apifile) { instance_double(File) }
    let(:browserfile) { instance_double(File) }

    before do
      allow(File).to receive(:open).with(synthetics.filename('abc-123-def'), 'w').and_return(apifile)
      allow(File).to receive(:open).with(synthetics.filename('456-ghi-789'), 'w').and_return(browserfile)
      allow(apifile).to receive(:write)
      allow(apifile).to receive(:close)
      allow(browserfile).to receive(:write)
      allow(browserfile).to receive(:close)
    end

    it 'is expected to write the API test' do
      backup
      expect(apifile).to have_received(:write).with(::JSON.pretty_generate(api_test))
    end

    it 'is expected to write the browser test' do
      backup
      expect(browserfile).to have_received(:write).with(::JSON.pretty_generate(browser_test))
    end
  end

  describe '#filename' do
    subject { synthetics.filename('abc-123-def') }

    it { is_expected.to eq("#{tempdir}/synthetics/abc-123-def.json") }
  end

  describe '#get_by_id' do
    context 'when the type is api' do
      subject { synthetics.get_by_id('abc-123-def') }

      it { is_expected.to eq api_test }
    end

    context 'when the type is browser' do
      subject { synthetics.get_by_id('456-ghi-789') }

      it { is_expected.to eq browser_test }
    end
  end

  describe '#diff' do # TODO: migrate to resources_spec.rb, since #diff is not defined here.
    subject { synthetics.diff('abc-123-def') }

    before do
      synthetics.write_file(synthetics.dump(api_test), synthetics.filename('abc-123-def'))
    end

    context 'when the test is identical' do
      it { is_expected.to be_empty }
    end

    context 'when the remote is not found' do
      subject(:invalid_diff) { synthetics.diff('invalid-id') }

      before do
        synthetics.write_file(synthetics.dump({ 'name' => 'invalid-diff' }), synthetics.filename('invalid-id'))
      end

      it {
        expect(invalid_diff).to eq(%(---- {}\n+---\n+name: invalid-diff))
      }
    end

    context 'when there is a local update' do
      before do
        different_test = api_test.dup
        different_test['message'] = 'Different message'
        synthetics.write_file(synthetics.dump(different_test), synthetics.filename('abc-123-def'))
      end

      it { is_expected.to include(%(-message: 'TEST: This is a test'\n+message: Different message)) }
    end
  end

  describe '#create' do
    context 'when the type is api' do
      subject(:create) { synthetics.create({ 'type' => 'api' }) }

      before do
        stubs.post('/api/v1/synthetics/tests/api') { respond_with200({ 'public_id' => 'api-create-abc' }) }
      end

      it { is_expected.to eq({ 'public_id' => 'api-create-abc' }) }
    end

    context 'when the type is browser' do
      subject(:create) { synthetics.create({ 'type' => 'browser' }) }

      before do
        stubs.post('/api/v1/synthetics/tests/browser') { respond_with200({ 'public_id' => 'browser-create-abc' }) }
      end

      it { is_expected.to eq({ 'public_id' => 'browser-create-abc' }) }
    end
  end

  describe '#update' do
    context 'when the type is api' do
      subject(:update) { synthetics.update('api-update-abc', { 'type' => 'api' }) }

      before do
        stubs.put('/api/v1/synthetics/tests/api/api-update-abc') { respond_with200({ 'public_id' => 'api-update-abc' }) }
      end

      it { is_expected.to eq({ 'public_id' => 'api-update-abc' }) }
    end

    context 'when the type is browser' do
      subject(:update) { synthetics.update('browser-update-abc', { 'type' => 'browser' }) }

      before do
        stubs.put('/api/v1/synthetics/tests/browser/browser-update-abc') { respond_with200({ 'public_id' => 'browser-update-abc' }) }
      end

      it { is_expected.to eq({ 'public_id' => 'browser-update-abc' }) }
    end
  end

  describe '#restore' do
    context 'when the id exists' do
      subject { synthetics.restore('abc-123-def') }

      before do
        synthetics.write_file(synthetics.dump({ 'name' => 'restore-valid-id', 'type' => 'api' }), synthetics.filename('abc-123-def'))
        stubs.put('/api/v1/synthetics/tests/api/abc-123-def') { respond_with200({ 'public_id' => 'abc-123-def', 'type' => 'api' }) }
      end

      it { is_expected.to eq({ 'public_id' => 'abc-123-def', 'type' => 'api' }) }
    end

    context 'when the id does not exist' do
      subject(:restore) { synthetics.restore('restore-invalid-id') }

      before do
        synthetics.write_file(synthetics.dump({ 'name' => 'restore-invalid-id', 'type' => 'api' }), synthetics.filename('restore-invalid-id'))
        stubs.put('/api/v1/synthetics/tests/api/restore-invalid-id') { raise Faraday::ResourceNotFound }
        stubs.post('/api/v1/synthetics/tests/api') { respond_with200({ 'public_id' => 'restore-valid-id' }) }
        allow(synthetics).to receive(:create).and_call_original
        allow(synthetics).to receive(:all).and_return([api_test, browser_test, { 'public_id' => 'restore-valid-id', 'type' => 'api' }])
      end

      it { is_expected.to eq({ 'type' => 'api' }) }

      it 'calls create with the contents of the original file' do
        restore
        expect(synthetics).to have_received(:create).with({ 'name' => 'restore-invalid-id', 'type' => 'api' })
      end

      it 'deletes the original file' do
        restore
        expect(File.exist?(synthetics.filename('restore-invalid-id'))).to be false
      end

      it 'creates a new file with the restored contents' do
        restore
        expect(File.exist?(synthetics.filename('restore-valid-id'))).to be true
      end
    end
  end
end
