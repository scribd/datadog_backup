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
      'message' => "TEST: logged in user\n\nThis is a message.",
      'monitor_id' => 12_345,
      'name' => 'TEST: logged in user',
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
    subject { synthetics.get_by_id('abc-123-def') }

    it { is_expected.to eq api_test }
  end
end
