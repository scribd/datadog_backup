# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Dashboards do
  let(:api_service_double) { double(Dogapi::APIService) }
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:dashboards) do
    described_class.new(
      action: 'backup',
      client: client_double,
      backup_dir: tempdir,
      output_format: :json,
      resources: [],
      logger: Logger.new('/dev/null')
    )
  end
  let(:dashboard_description) do
    {
      'description' => 'bar',
      'id' => 'abc-123-def',
      'title' => 'foo'
    }
  end
  let(:all_boards) do
    [
      '200',
      {
        'dashboards' => [
          dashboard_description
        ]
      }
    ]
  end
  let(:example_dashboard) do
    [
      '200',
      board_abc_123_def
    ]
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

  before do
    allow(client_double).to receive(:instance_variable_get).with(:@dashboard_service).and_return(api_service_double)
    allow(api_service_double).to receive(:request).with(Net::HTTP::Get, '/api/v1/dashboard', nil, nil,
                                                        false).and_return(all_boards)
    allow(api_service_double).to receive(:request).with(Net::HTTP::Get, '/api/v1/dashboard/abc-123-def', nil, nil,
                                                        false).and_return(example_dashboard)
  end

  describe '#backup' do
    subject { dashboards.backup }

    it 'is expected to create a file' do
      file = double('file')
      allow(File).to receive(:open).with(dashboards.filename('abc-123-def'), 'w').and_return(file)
      expect(file).to receive(:write).with(::JSON.pretty_generate(board_abc_123_def.deep_sort))
      allow(file).to receive(:close)

      dashboards.backup
    end
  end

  describe '#all_boards' do
    subject { dashboards.all_boards }

    it { is_expected.to eq [dashboard_description] }
  end

  describe '#diff' do
    it 'calls the api only once' do
      dashboards.write_file('{"a":"b"}', dashboards.filename('abc-123-def'))
      expect(dashboards.diff('abc-123-def')).to eq(<<~EOF
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
      EOF
                                                  )
    end
  end

  describe '#except' do
    subject { dashboards.except({ :a => :b, 'modified_at' => :c, 'url' => :d }) }

    it { is_expected.to eq({ a: :b }) }
  end

  describe '#get_by_id' do
    subject { dashboards.get_by_id('abc-123-def') }

    it { is_expected.to eq board_abc_123_def }
  end
end
