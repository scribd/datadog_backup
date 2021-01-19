# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Monitors do
  let(:api_service_double) { double(Dogapi::APIService) }
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:monitors) do
    described_class.new(
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
      'id' => 123_455,
      'name' => 'foo',
      'overall_state' => 'OK',
      'overall_state_modified' => '2020-07-27T22:00:00+00:00'
    }
  end
  let(:clean_monitor_description) do
    {
      'id' => 123_455,
      'message' => 'foo',
      'name' => 'foo',
      'query' => 'bar'
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

  before do
    allow(client_double).to receive(:instance_variable_get).with(:@monitor_svc).and_return(api_service_double)
    allow(api_service_double).to receive(:request).with(Net::HTTP::Get, '/api/v1/monitor', nil, nil,
                                                        false).and_return(all_monitors)
    allow(api_service_double).to receive(:request).with(Net::HTTP::Get, '/api/v1/dashboard/123455', nil, nil,
                                                        false).and_return(example_monitor)
  end

  describe '#all_monitors' do
    subject { monitors.all_monitors }

    it { is_expected.to eq [monitor_description] }
  end

  describe '#backup' do
    subject { monitors.backup }

    it 'is expected to create a file' do
      file = double('file')
      allow(File).to receive(:open).with(monitors.filename(123_455), 'w').and_return(file)
      expect(file).to receive(:write).with(::JSON.pretty_generate(clean_monitor_description))
      allow(file).to receive(:close)

      monitors.backup
    end
  end

  describe '#diff and #except' do
    example 'it ignores `overall_state` and `overall_state_modified`' do
      monitors.write_file(monitors.dump(monitor_description), monitors.filename(123_455))
      allow(api_service_double).to receive(:request).and_return(
        [
          '200',
          [
            {
              'query' => 'bar',
              'message' => 'foo',
              'id' => 123_455,
              'name' => 'foo',
              'overall_state' => 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZ',
              'overall_state_modified' => '9999-07-27T22:55:55+00:00'
            }
          ]
        ]
      )

      expect(monitors.diff(123_455)).to eq ''

      FileUtils.rm monitors.filename(123_455)
    end
  end

  describe '#filename' do
    subject { monitors.filename(123_455) }

    it { is_expected.to eq("#{tempdir}/monitors/123455.json") }
  end

  describe '#get_by_id' do
    context 'Integer' do
      subject { monitors.get_by_id(123_455) }

      it { is_expected.to eq monitor_description }
    end

    context 'String' do
      subject { monitors.get_by_id('123455') }

      it { is_expected.to eq monitor_description }
    end
  end
end
