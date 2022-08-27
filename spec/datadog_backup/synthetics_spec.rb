# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Synthetics do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:api_client_double) { Faraday.new { |f| f.adapter :test, stubs } }
  let(:tempdir) { Dir.mktmpdir }
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

  let(:synthetic_description) do
    { 'config' => { 'assertions' => [{ 'operator' => 'contains', 'property' => 'set-cookie', 'target' => '_user_id', 'type' => 'header' }, { 'operator' => 'contains', 'target' => 'body message', 'type' => 'body' }, { 'operator' => 'is', 'property' => 'content-type', 'target' => 'text/html; charset=utf-8', 'type' => 'header' }, { 'operator' => 'is', 'target' => 200, 'type' => 'statusCode' }, { 'operator' => 'lessThan', 'target' => 5000, 'type' => 'responseTime' }], 'request' => { 'headers' => { 'User-Agent' => 'Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0', 'cookie' => '_a=12345; _example_session=abc123' }, 'method' => 'GET', 'url' => 'https://www.example.com/' } }, 'creator' => { 'email' => 'user@example.com', 'handle' => 'user@example.com', 'name' => 'Hugh Zer' }, 'locations' => ['aws:ap-northeast-1', 'aws:eu-central-1', 'aws:eu-west-2', 'aws:us-west-2'], 'message' => "TEST: logged in user\n\nThis is a message.", 'monitor_id' => 12_345, 'name' => 'TEST: logged in user', 'options' => { 'follow_redirects' => true, 'httpVersion' => 'http1', 'min_failure_duration' => 120, 'min_location_failed' => 2, 'monitor_options' => { 'renotify_interval' => 0 }, 'monitor_priority' => 1, 'retry' => { 'count' => 1, 'interval' => 500 }, 'tick_every' => 120 }, 'public_id' => 'abc-123-def', 'status' => 'live', 'subtype' => 'http', 'tags' => ['env:production'], 'type' => 'api' }
  end
  let(:all_synthetics) do
    [
      200,
      {},
      {
        'tests' => [synthetic_description]
      }
    ]
  end
  let(:example_synthetic) do
    [
      200,
      {},
      synthetic_description
    ]
  end

  before do
    stubs.get('/api/v1/synthetics/tests') { all_synthetics }
    stubs.get('/api/v1/synthetics/tests/api/abc-123-def') { example_synthetic }
  end

  describe '#all' do
    subject { synthetics.all }

    it { is_expected.to eq [synthetic_description] }
  end

  describe '#backup' do
    subject { synthetics.backup }

    it 'is expected to create a file' do
      file = instance_double('File')
      allow(File).to receive(:open).with(synthetics.filename('abc-123-def'), 'w').and_return(file)
      allow(file).to receive(:write)
      allow(file).to receive(:close)

      synthetics.backup
      expect(file).to have_received(:write).with(::JSON.pretty_generate(synthetic_description))
    end
  end

  describe '#filename' do
    subject { synthetics.filename('abc-123-def') }

    it { is_expected.to eq("#{tempdir}/synthetics/abc-123-def.json") }
  end

  describe '#get_by_id' do
    subject { synthetics.get_by_id('abc-123-def') }

    it { is_expected.to eq synthetic_description }
  end
end
