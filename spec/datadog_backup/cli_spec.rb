require 'spec_helper'

describe DatadogBackup::Cli do
  let(:client_double) { double }
  let(:tempdir) { Dir.mktmpdir }
  let(:options) {{
    action: 'backup',
    backup_dir: tempdir,
    client: client_double,
    datadog_api_key: 1,
    datadog_app_key: 1,
    logger: Logger.new('/dev/null'),
    output_format: :json,
    resources: [DatadogBackup::Dashboards]
  }}
  let(:cli) { DatadogBackup::Cli.new(options) }
  let(:dashboards) { DatadogBackup::Dashboards.new(options) }

  before(:example) {
    allow(cli).to receive(:resource_instances).and_return([dashboards])
  }

  
  describe '#diffs' do
    before(:example) do
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs1.json")
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs2.json")
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs3.json")
      allow(dashboards).to receive(:get_by_id).and_return({"text" => "diff2"})
      allow(cli).to receive(:initialize_client).and_return(client_double)
    end
    subject { cli.diffs }
    it { is_expected.to eq({
      'diffs1' => [["~", "text", "diff2", "diff"]],
      'diffs2' => [["~", "text", "diff2", "diff"]],
      'diffs3' => [["~", "text", "diff2", "diff"]]
      }) }
      
    end
  
end
