# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Cli do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:api_client_double) { Faraday.new { |f| f.adapter :test, stubs } }
  let(:tempdir) { Dir.mktmpdir }
  let(:options) do
    {
      action: 'backup',
      backup_dir: tempdir,
      diff_format: nil,
      output_format: :json,
      resources: [DatadogBackup::Dashboards]
    }
  end
  let(:cli) { described_class.new(options) }
  let(:dashboards) do
    dashboards = DatadogBackup::Dashboards.new(options)
    allow(dashboards).to receive(:api_service).and_return(api_client_double)
    return dashboards
  end

  before do
    allow(cli).to receive(:resource_instances).and_return([dashboards])
  end

  describe '#backup' do
    context 'when dashboards are deleted in datadog' do
      let(:all_dashboards) do
        respond_with200(
          {
            'dashboards' => [
              { 'id' => 'stillthere' },
              { 'id' => 'alsostillthere' }
            ]
          }
        )
      end

      before do
        dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/stillthere.json")
        dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/alsostillthere.json")
        dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/deleted.json")

        stubs.get('/api/v1/dashboard') { all_dashboards }
        stubs.get('/api/v1/dashboard/stillthere') { respond_with200({}) }
        stubs.get('/api/v1/dashboard/alsostillthere') { respond_with200({}) }
      end

      it 'deletes the file locally as well' do
        cli.backup
        expect { File.open("#{tempdir}/dashboards/deleted.json", 'r') }.to raise_error(Errno::ENOENT)
      end
    end
  end

  describe '#restore' do
    subject(:restore) { cli.restore }
    let(:stdin) { class_double('STDIN') }

    after(:all) do
      $stdin = STDIN
    end
    
    before do
      $stdin = stdin
      dashboards.write_file('{"text": "diff"}', "#{tempdir}/dashboards/diffs1.json")
      allow(dashboards).to receive(:get_by_id).and_return({ 'text' => 'diff2' })
      allow(dashboards).to receive(:write_file)
      allow(dashboards).to receive(:update)
    end

    example 'starts interactive restore' do
      allow(stdin).to receive(:gets).and_return('q')

      expect { restore }.to(
        output(/\(r\)estore to Datadog, overwrite local changes and \(d\)ownload, \(s\)kip, or \(q\)uit\?/).to_stdout
        .and(raise_error(SystemExit))
      )
    end

    context 'when the user chooses to restore' do
      before do
        allow(stdin).to receive(:gets).and_return('r')
      end

      example 'it restores from disk to server' do
        restore
        expect(dashboards).to have_received(:update).with('diffs1', { 'text' => 'diff' })
      end
    end

    context 'when the user chooses to download' do
      before do
        allow(stdin).to receive(:gets).and_return('d')
      end

      example 'it writes from server to disk' do
        restore
        expect(dashboards).to have_received(:write_file).with(%({\n  "text": "diff2"\n}), "#{tempdir}/dashboards/diffs1.json")
      end
    end

    context 'when the user chooses to skip' do
      before do
        allow(stdin).to receive(:gets).and_return('s')
      end

      example 'it does not write to disk' do
        restore
        expect(dashboards).not_to have_received(:write_file)
      end

      example 'it does not update the server' do
        restore
        expect(dashboards).not_to have_received(:update)
      end
    end

    context 'when the user chooses to quit' do
      before do
        allow(stdin).to receive(:gets).and_return('q')
      end

      example 'it exits' do
        expect { restore }.to raise_error(SystemExit)
      end

      example 'it does not write to disk' do
        restore
      rescue SystemExit
        expect(dashboards).not_to have_received(:write_file)
      end

      example 'it does not update the server' do
        restore
      rescue SystemExit
        expect(dashboards).not_to have_received(:update)
      end
    end
  end
end
