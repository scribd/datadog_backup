# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::SLOs do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:api_client_double) { Faraday.new { |f| f.adapter :test, stubs } }
  let(:tempdir) { Dir.mktmpdir }
  let(:slos) do
    slos = described_class.new(
      action: 'backup',
      backup_dir: tempdir,
      output_format: :json,
      resources: []
    )
    allow(slos).to receive(:api_service).and_return(api_client_double)
    return slos
  end
  let(:fetched_slos) do
    {
      "data"=>[
        {"id"=>"abc-123", "name"=>"CI Stability", "tags"=>["kind:availability", "team:my_team"], "monitor_tags"=>[], "thresholds"=>[{"timeframe"=>"7d", "target"=>98.0, "target_display"=>"98."}, {"timeframe"=>"30d", "target"=>98.0, "target_display"=>"98."}, {"timeframe"=>"90d", "target"=>98.0, "target_display"=>"98."}], "type"=>"metric", "type_id"=>1, "description"=>"something helpful", "timeframe"=>"30d", "target_threshold"=>98.0, "query"=>{"denominator"=>"sum:metric.ci_things{*}.as_count()", "numerator"=>"sum:metric.ci_things{*}.as_count()-sum:metric.ci_things{infra_failure}.as_count()"}, "creator"=>{"name"=>"Thelma Patterson", "handle"=>"thelma.patterson@example.com", "email"=>"thelma.patterson@example.com"}, "created_at"=>1571335531, "modified_at"=>1687844157},
        {"id"=>"sbc-124", "name"=>"A Latency SLO", "tags"=>["team:my_team", "kind:latency"], "monitor_tags"=>[], "thresholds"=>[{"timeframe"=>"7d", "target"=>95.0, "target_display"=>"95."}, {"timeframe"=>"30d", "target"=>95.0, "target_display"=>"95."}, {"timeframe"=>"90d", "target"=>95.0, "target_display"=>"95."}], "type"=>"monitor", "type_id"=>0, "description"=>"", "timeframe"=>"30d", "target_threshold"=>95.0, "monitor_ids"=>[13158755], "creator"=>{"name"=>"Louise Montague", "handle"=>"louise.montague@example.com", "email"=>"louise.montague@example.com"}, "created_at"=>1573162531, "modified_at"=>1685819875}
      ],
      "error"=>nil,
      "metadata"=>{"page"=>{"total_count"=>359, "total_filtered_count"=>359}}
    }
  end
  let(:slo_abc_123) do
    {
      "data" => {
        "id" => "abc-123",
        "name" => "CI Stability",
        "tags" => [
          "kind:availability",
          "team:my_team",
        ],
        "monitor_tags" => [],
        "thresholds" => [
          {
            "timeframe" => "7d",
            "target" => 98.0,
            "target_display" => "98."
          },
          {
            "timeframe" => "30d",
            "target" => 98.0,
            "target_display" => "98."
          },
          {
            "timeframe" => "90d",
            "target" => 98.0,
            "target_display" => "98."
          }
        ],
        "type" => "metric",
        "type_id" => 1,
        "description" => "something helpful",
        "timeframe" => "30d",
        "target_threshold" => 98.0,
        "query" => {
          "denominator" => "sum:metric.ci_things{*}.as_count()",
          "numerator" => "sum:metric.ci_things{*}.as_count()-sum:metric.ci_things{infra_failure}.as_count()"
        },
        "creator" => {
          "name" => "Thelma Patterson",
          "handle" => "thelma.patterson@example.com",
          "email" => "thelma.patterson@example.com"
        },
        "created_at" => 1571335531,
        "modified_at" => 1687844157
      },
      "error" => nil
    }
  end
  let(:slo_sbc_124) do
    {
      "data" => {
        "id" => "sbc-124",
        "name" => "A Latency SLO",
        "tags" => [
          "kind:latency",
          "team:my_team",
        ],
        "monitor_tags" => [],
        "thresholds" => [
          {
            "timeframe" => "7d",
            "target" => 98.0,
            "target_display" => "98."
          },
          {
            "timeframe" => "30d",
            "target" => 98.0,
            "target_display" => "98."
          },
          {
            "timeframe" => "90d",
            "target" => 98.0,
            "target_display" => "98."
          }
        ],
        "type" => "monitor",
        "type_id"=>0,
        "description"=>"",
        "timeframe"=>"30d",
        "target_threshold"=>95.0,
        "monitor_ids"=>[ 13158755 ],
        "creator"=>{
          "name"=>"Louise Montague",
          "handle"=>"louise.montague@example.com",
          "email"=>"louise.montague@example.com"
        },
        "created_at"=>1573162531,
        "modified_at"=>1685819875
      },
      "error" => nil
    }
  end
  let(:all_slos) { respond_with200(fetched_slos) }
  let(:example_slo1) { respond_with200(slo_abc_123) }
  let(:example_slo2) { respond_with200(slo_sbc_124) }

  before do
    stubs.get('/api/v1/slo') { all_slos }
    stubs.get('/api/v1/slo/abc-123') { example_slo1 }
    stubs.get('/api/v1/slo/sbc-124') { example_slo2 }
  end

  describe '#backup' do
    subject { slos.backup }

    it 'is expected to create two files' do
      file1 = instance_double(File)
      allow(File).to receive(:open).with(slos.filename('abc-123'), 'w').and_return(file1)
      allow(file1).to receive(:write)
      allow(file1).to receive(:close)

      file2 = instance_double(File)
      allow(File).to receive(:open).with(slos.filename('sbc-124'), 'w').and_return(file2)
      allow(file2).to receive(:write)
      allow(file2).to receive(:close)

      slos.backup
      expect(file1).to have_received(:write).with(::JSON.pretty_generate(slo_abc_123.deep_sort))
      expect(file2).to have_received(:write).with(::JSON.pretty_generate(slo_sbc_124.deep_sort))
    end
  end

  describe '#filename' do
    subject { slos.filename('abc-123') }

    it { is_expected.to eq("#{tempdir}/slos/abc-123.json") }
  end

  describe '#get_by_id' do
    subject { slos.get_by_id('abc-123') }

    it { is_expected.to eq slo_abc_123 }
  end

  describe '#diff' do
    it 'calls the api only once' do
      slos.write_file('{"a":"b"}', slos.filename('abc-123'))
      expect(slos.diff('abc-123')).to eq(<<~EODASH
         ---
        -data:
        -  created_at: 1571335531
        -  creator:
        -    email: thelma.patterson@example.com
        -    handle: thelma.patterson@example.com
        -    name: Thelma Patterson
        -  description: something helpful
        -  id: abc-123
        -  modified_at: 1687844157
        -  monitor_tags: []
        -  name: CI Stability
        -  query:
        -    denominator: sum:metric.ci_things{*}.as_count()
        -    numerator: sum:metric.ci_things{*}.as_count()-sum:metric.ci_things{infra_failure}.as_count()
        -  tags:
        -  - kind:availability
        -  - team:my_team
        -  target_threshold: 98.0
        -  thresholds:
        -  - target: 98.0
        -    target_display: '98.'
        -    timeframe: 30d
        -  - target: 98.0
        -    target_display: '98.'
        -    timeframe: 7d
        -  - target: 98.0
        -    target_display: '98.'
        -    timeframe: 90d
        -  timeframe: 30d
        -  type: metric
        -  type_id: 1
        -error:
        +a: b
      EODASH
      .chomp)
    end
  end

  describe '#except' do
    subject { slos.except({ :a => :b, 'modified_at' => :c, 'url' => :d }) }

    it { is_expected.to eq({ a: :b }) }
  end
end
