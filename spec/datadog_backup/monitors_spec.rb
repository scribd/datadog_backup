require 'spec_helper'

describe DatadogBackup::Monitors do
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:monitors) do
    DatadogBackup::Monitors.new(
      action: 'backup',
      client: client_double,
      backup_dir: tempdir,
      output_format: :json,
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
    subject { monitors.backup }

    it 'is expected to create a file' do
      file = double('file')
      allow(File).to receive(:open).with(monitors.filename(123455), 'w').and_return( file )
      expect(file).to receive(:write).with(::JSON.pretty_generate(monitor_description))
      allow(file).to receive(:close)

      monitors.backup.map(&:value!)
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
    it { is_expected.to eq("#{tempdir}/monitors/123455.json") }
  end

  describe '#get_by_id' do
    subject { monitors.get_by_id(123455) }
    it { is_expected.to eq monitor_description }
  end
end
