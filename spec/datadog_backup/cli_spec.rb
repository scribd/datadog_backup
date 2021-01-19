# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Cli do
  let(:api_service_double) { double(Dogapi::APIService) }
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:options) do
    {
      action: 'backup',
      backup_dir: tempdir,
      client: client_double,
      datadog_api_key: 1,
      datadog_app_key: 1,
      diff_format: nil,
      logger: Logger.new('/dev/null'),
      output_format: :json,
      resources: [DatadogBackup::Dashboards]
    }
  end
  let(:cli) { described_class.new(options) }
  let(:dashboards) { DatadogBackup::Dashboards.new(options) }

  before do
    allow(cli).to receive(:resource_instances).and_return([dashboards])
  end

  describe '#backup' do
    context 'when dashboards are deleted in datadog' do
      let(:all_boards) do
        [
          '200',
          {
            'dashboards' => [
              { 'id' => 'stillthere' },
              { 'id' => 'alsostillthere' }
            ]
          }
        ]
      end

      before do
        dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/stillthere.json")
        dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/alsostillthere.json")
        dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/deleted.json")

        allow(client_double).to receive(:instance_variable_get).with(:@dashboard_service).and_return(api_service_double)
        allow(api_service_double).to receive(:request).with(Net::HTTP::Get,
                                                            '/api/v1/dashboard',
                                                            nil,
                                                            nil,
                                                            false).and_return(all_boards)
        allow(api_service_double).to receive(:request).with(Net::HTTP::Get,
                                                            '/api/v1/dashboard/stillthere',
                                                            nil,
                                                            nil,
                                                            false).and_return(['200', {}])
        allow(api_service_double).to receive(:request).with(Net::HTTP::Get,
                                                            '/api/v1/dashboard/alsostillthere',
                                                            nil,
                                                            nil,
                                                            false).and_return(['200', {}])
      end

      it 'deletes the file locally as well' do
        cli.backup
        expect { File.open("#{tempdir}/dashboards/deleted.json", 'r') }.to raise_error(Errno::ENOENT)
      end
    end
  end

  describe '#diffs' do
    subject { cli.diffs }

    before do
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs1.json")
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs2.json")
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs3.json")
      allow(dashboards).to receive(:get_by_id).and_return({ 'text' => 'diff2' })
      allow(cli).to receive(:initialize_client).and_return(client_double)
    end

    it {
      expect(subject).to include(
        " ---\n id: diffs1\n ---\n-text: diff2\n+text: diff\n",
        " ---\n id: diffs3\n ---\n-text: diff2\n+text: diff\n",
        " ---\n id: diffs2\n ---\n-text: diff2\n+text: diff\n"
      )
    }
  end

  describe '#restore' do
    subject { cli.restore }

    before do
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs1.json")
      allow(dashboards).to receive(:get_by_id).and_return({ 'text' => 'diff2' })
      allow(cli).to receive(:initialize_client).and_return(client_double)
    end

    example 'starts interactive restore' do
      allow($stdin).to receive(:gets).and_return('q')

      expect { subject }.to(
        output(/\(r\)estore to Datadog, overwrite local changes and \(d\)ownload, \(s\)kip, or \(q\)uit\?/).to_stdout
        .and(raise_error(SystemExit))
      )
    end

    example 'restore' do
      allow($stdin).to receive(:gets).and_return('r')
      expect(dashboards).to receive(:update).with('diffs1', { 'text' => 'diff' })
      subject
    end

    example 'download' do
      allow($stdin).to receive(:gets).and_return('d')
      expect(dashboards).to receive(:write_file).with(%({\n  "text": "diff2"\n}), "#{tempdir}/dashboards/diffs1.json")
      subject
    end

    example 'skip' do
      allow($stdin).to receive(:gets).and_return('s')
      expect(dashboards).not_to receive(:write_file)
      expect(dashboards).not_to receive(:update)
      subject
    end

    example 'quit' do
      allow($stdin).to receive(:gets).and_return('q')
      expect(dashboards).not_to receive(:write_file)
      expect(dashboards).not_to receive(:update)
      expect { subject }.to raise_error(SystemExit)
    end
  end
end
