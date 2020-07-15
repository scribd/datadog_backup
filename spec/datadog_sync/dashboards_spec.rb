require 'spec_helper'

describe DatadogSync::Dashboards do
  let(:client_double) { double }
  let(:dashboards) {
    DatadogSync::Dashboards.new(
      action: 'backup',
      client: client_double,
      output_dir: 'output',
      resources: [],
      logger: Logger.new('/dev/null')
    )
  }
  let(:dashboard_description) {
    {
      'description' => 'bar',
      'id' => 'abc-123-def',
      'title' => 'foo'
    }
  }
  let(:all_boards) {
    [
      '200',
      {
        'dashboards' => [
          dashboard_description
        ]
      }
    ]
  }
  let(:example_dashboard) {
    [
      '200',
      board_abc_123_def
    ]
  }
  let(:board_abc_123_def) {
    {
      'graphs' => [
        {
          'definition' =>  {
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
  }
  before(:example) {
    allow(client_double).to receive(:get_all_boards).and_return(all_boards)
    allow(client_double).to receive(:get_board).and_return(example_dashboard)
  }

  describe '#backup' do
    it 'is expected to call the #backup! method' do
      expect(dashboards).to receive(:backup!)
      dashboards.backup
    end


  end

  describe '#backup!' do
    subject { dashboards.backup! }

    it 'subsequently calls each id' do
      subject
      expect(client_double).to have_received(:get_board).with('abc-123-def')
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
    it { is_expected.to eq('output/abc-123-def.json') }
  end

end
