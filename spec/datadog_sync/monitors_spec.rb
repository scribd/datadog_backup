require 'spec_helper'

describe DatadogSync::Monitors do
  let(:client_double) { double }
  let(:monitors) do
    DatadogSync::Monitors.new(
      action: 'backup',
      client: client_double,
      output_dir: 'output',
      resources: [],
      logger: Logger.new('/dev/null')
    )
  end
  let(:monitor_description) do
    {
      'query' => 'bar',
      'message' => 'foo',
      'id' => 123455,
      'name' => 'foo'
    }
  end
  let(:all_monitors) do
    [
      '200',
      [
        monitor_description
      ]
    ]
  end
  let(:example_monitor) do
    [
      '200',
      monitor_description
    ]
  end
  before(:example) do
    allow(client_double).to receive(:get_all_monitors).and_return(all_monitors)
    allow(client_double).to receive(:get_monitor).and_return(example_monitor)
  end

  describe '#backup' do
    it 'is expected to call the #backup! method' do
      expect(monitors).to receive(:backup!)
      monitors.backup
    end
  end

  describe '#backup!' do
    subject { monitors.backup! }

    it 'subsequently calls each id' do
      allow(monitors).to receive(:write)
      subject
      expect(monitors).to have_received(:write).with(monitors.jsondump(monitor_description),monitors.filename(123455))
    end
  end

  describe '#all_monitors' do
    subject { monitors.all_monitors }

    it 'calls get_all_monitors' do
      subject
      expect(client_double).to have_received(:get_all_monitors)
    end

    it { is_expected.to eq [monitor_description] }
  end

  describe '#filename' do
    subject { monitors.filename(123455) }
    it { is_expected.to eq('output/monitors/123455.json') }
  end
end
