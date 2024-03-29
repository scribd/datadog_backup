# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Dashboards do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:api_client_double) { Faraday.new { |f| f.adapter :test, stubs } }
  let(:tempdir) { Dir.mktmpdir }
  let(:dashboards) do
    dashboards = described_class.new(
      action: 'backup',
      backup_dir: tempdir,
      output_format: :json,
      resources: []
    )
    allow(dashboards).to receive(:api_service).and_return(api_client_double)
    return dashboards
  end
  let(:dashboard_description) do
    {
      'description' => 'bar',
      'id' => 'abc-123-def',
      'title' => 'foo'
    }
  end
  let(:board_abc_123_def) do
    {
      'graphs' => [
        {
          'definition' => {
            'viz' => 'timeseries',
            'requests' => [
              {
                'q' => 'min:foo.bar{a:b}',
                'stacked' => false
              }
            ]
          },
          'title' => 'example graph'
        }
      ],
      'description' => 'example dashboard',
      'title' => 'example dashboard'
    }
  end
  let(:all_dashboards) { respond_with200({ 'dashboards' => [dashboard_description] }) }
  let(:example_dashboard) { respond_with200(board_abc_123_def) }

  before do
    stubs.get('/api/v1/dashboard') { all_dashboards }
    stubs.get('/api/v1/dashboard/abc-123-def') { example_dashboard }
  end

  describe '#backup' do
    subject { dashboards.backup }

    it 'is expected to create a file' do
      file = instance_double(File)
      allow(File).to receive(:open).with(dashboards.filename('abc-123-def'), 'w').and_return(file)
      allow(file).to receive(:write)
      allow(file).to receive(:close)

      dashboards.backup
      expect(file).to have_received(:write).with(::JSON.pretty_generate(board_abc_123_def.deep_sort))
    end
  end

  describe '#filename' do
    subject { dashboards.filename('abc-123-def') }

    it { is_expected.to eq("#{tempdir}/dashboards/abc-123-def.json") }
  end

  describe '#get_by_id' do
    subject { dashboards.get_by_id('abc-123-def') }

    it { is_expected.to eq board_abc_123_def }
  end

  describe '#diff' do
    it 'calls the api only once' do
      dashboards.write_file('{"a":"b"}', dashboards.filename('abc-123-def'))
      expect(dashboards.diff('abc-123-def')).to eq(<<~EODASH
         ---
        -description: example dashboard
        -graphs:
        -- definition:
        -    requests:
        -    - q: min:foo.bar{a:b}
        -      stacked: false
        -    viz: timeseries
        -  title: example graph
        -title: example dashboard
        +a: b
      EODASH
      .chomp)
    end
  end

  describe '#except' do
    subject { dashboards.except({ :a => :b, 'modified_at' => :c, 'url' => :d }) }

    it { is_expected.to eq({ a: :b }) }
  end
end
