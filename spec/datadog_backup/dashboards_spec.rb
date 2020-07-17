require 'spec_helper'

describe DatadogBackup::Dashboards do
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:dashboards) do
    DatadogBackup::Dashboards.new(
      action: 'backup',
      client: client_double,
      backup_dir: tempdir,
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
  before(:example) do
    allow(client_double).to receive(:get_all_boards).and_return(all_boards)
    allow(client_double).to receive(:get_board).and_return(example_dashboard)
  end

  describe '#backup' do
    it 'is expected to call the #backup! method' do
      expect(dashboards).to receive(:backup!)
      dashboards.backup
    end
  end

  describe '#backup!' do
    subject { dashboards.backup! }

    it 'is expected to create a file' do
      file = double('file')
      allow(File).to receive(:open).with(dashboards.filename('abc-123-def'), 'w').and_return( file )
      expect(file).to receive(:write).with(::MultiJson.dump(board_abc_123_def, pretty: true))
      allow(file).to receive(:close)

      dashboards.backup!.map(&:value!)
    end
  end

  describe '#all_boards' do
    subject { dashboards.all_boards }

    it 'calls get_all_boards' do
      subject
      expect(client_double).to have_received(:get_all_boards)
    end

    it { is_expected.to eq [dashboard_description] }
  end

  describe '#get_board' do
    subject { dashboards.get_board('abc-123-def') }

    it { is_expected.to eq board_abc_123_def }
  end

  describe '#filename' do
    subject { dashboards.filename('abc-123-def') }
    it { is_expected.to eq("#{tempdir}/dashboards/abc-123-def.json") }
  end
end
