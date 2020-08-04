# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Cli do
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
  let(:cli) { DatadogBackup::Cli.new(options) }
  let(:dashboards) { DatadogBackup::Dashboards.new(options) }

  before(:example) do
    allow(cli).to receive(:resource_instances).and_return([dashboards])
  end

  describe '#diffs' do
    before(:example) do
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs1.json")
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs2.json")
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs3.json")
      allow(dashboards).to receive(:get_by_id).and_return({ 'text' => 'diff2' })
      allow(cli).to receive(:initialize_client).and_return(client_double)
    end
    subject { cli.diffs }
    it {
      is_expected.to include(
        " ---\n id: diffs1\n ---\n-text: diff2\n+text: diff\n",
        " ---\n id: diffs3\n ---\n-text: diff2\n+text: diff\n",
        " ---\n id: diffs2\n ---\n-text: diff2\n+text: diff\n"
      )
    }
  end

  describe '#restore' do
    before(:example) do
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs1.json")
      allow(dashboards).to receive(:get_by_id).and_return({ 'text' => 'diff2' })
      allow(cli).to receive(:initialize_client).and_return(client_double)
    end

    subject { cli.restore }

    example 'starts interactive restore' do
      allow($stdin).to receive(:gets).and_return('q')
      begin
        expect { subject }.to(
          output(/\(r\)estore to Datadog, overwrite local changes and \(d\)ownload, \(s\)kip, or \(q\)uit\?/).to_stdout
          .and(raise_error(SystemExit))
        )
      end
    end

    example 'restore' do
      allow($stdin).to receive(:gets).and_return('r')
      expect(dashboards).to receive(:update).with('diffs1', '{"text":"diff"}')
      subject
    end
    example 'download' do
      allow($stdin).to receive(:gets).and_return('d')
      expect(dashboards).to receive(:write_file).with(%({\n  "text": "diff2"\n}), "#{tempdir}/dashboards/diffs1.json")
      subject
    end
    example 'skip' do
      allow($stdin).to receive(:gets).and_return('s')
      expect(dashboards).to_not receive(:write_file)
      expect(dashboards).to_not receive(:update)
      subject
    end
    example 'quit' do
      allow($stdin).to receive(:gets).and_return('q')
      expect(dashboards).to_not receive(:write_file)
      expect(dashboards).to_not receive(:update)
      expect { subject }.to raise_error(SystemExit)
    end
  end
end
