# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Synthetics do
  before do
    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests', {}, {})
      .and_return({ 'tests' => [
                    FactoryBot.body(:synthetic_api),
                    FactoryBot.body(:synthetic_browser)
                  ] })

    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests/api/mno-789-pqr', {}, {})
      .and_return(FactoryBot.body(:synthetic_api))

    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests/browser/stu-456-vwx', {}, {})
      .and_return(FactoryBot.body(:synthetic_browser))

    # While searching for a test, datadog_backup will brute force try one before the other.
    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests/browser/mno-789-pqr', {}, {})
      .and_raise(Faraday::ResourceNotFound)

    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests/api/stu-456-vwx', {}, {})
      .and_raise(Faraday::ResourceNotFound)
  end

  describe 'Class Methods' do
    describe '.new_resource' do
      context 'with id and body' do
        subject { described_class.new_resource(id: 'mno-789-pqr', body: FactoryBot.body(:synthetic_api)) }

        it { is_expected.to be_a(described_class) }
      end

      context 'with id and no body' do
        subject { described_class.new_resource(id: 'mno-789-pqr') }

        it { is_expected.to be_a(described_class) }
      end

      context 'with no id and with body' do
        subject { described_class.new_resource(body: FactoryBot.body(:synthetic_api)) }

        it { is_expected.to be_a(described_class) }
      end

      context 'with no id and no body' do
        subject { described_class.new_resource }

        it 'raises an ArgumentError' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    describe '.all' do
      subject { described_class.all }

      it { is_expected.to be_a(Array) }
      it { is_expected.to all(be_a(described_class)) }
    end

    describe '.get_all' do
      subject { described_class.get_all }

      it {
        expect(subject).to contain_exactly(
          FactoryBot.body(:synthetic_api),
          FactoryBot.body(:synthetic_browser)
        )
      }
    end

    describe '.get_by_id' do
      subject { described_class.get_by_id('mno-789-pqr').id }

      it { is_expected.to eq('mno-789-pqr') }
    end

    describe '.myclass' do
      subject { described_class.myclass }

      it { is_expected.to eq('synthetics') }
    end
  end

  describe 'Instance Methods' do
    subject(:abc) { build(:synthetic_api) }

    describe '#diff' do
      subject(:diff) { abc.diff('text') }

      before do
        allow(abc).to receive(:body_from_backup)
          .and_return({ 'public_id' => 'mno-789-pqr', 'type' => 'api', 'title' => 'abc' })
      end

      it {
        expect(diff).to eq(<<~EODIFF
           ---
           public_id: mno-789-pqr
           type: api
          +title: abc
        EODIFF
        .chomp)
      }
    end

    describe '#dump' do
      context 'when mode is :json' do
        subject(:json) { abc.dump(:json) }

        it { is_expected.to eq(JSON.pretty_generate(FactoryBot.body(:synthetic_api))) }
      end

      context 'when mode is :yaml' do
        subject(:yaml) { abc.dump(:yaml) }

        it { is_expected.to eq(FactoryBot.body(:synthetic_api).to_yaml) }
      end
    end

    describe '#myclass' do
      subject { abc.myclass }

      it { is_expected.to eq('synthetics') }
    end

    describe '#get' do
      subject(:get) { abc.get }

      it { is_expected.to eq(FactoryBot.body(:synthetic_api)) }
    end

    describe '#create' do
      subject(:create) { abc.create }

      it 'posts to the api endpoint' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:post_body)
          .with('/api/v1/synthetics/tests/api', FactoryBot.body(:synthetic_api), {})
          .and_return(FactoryBot.body(:synthetic_api))
        create
      end
    end

    describe '#update' do
      subject(:update) { abc.update }

      it 'puts to the api endpoint' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:put_body)
          .with('/api/v1/synthetics/tests/api/mno-789-pqr', FactoryBot.body(:synthetic_api), {})
          .and_return(FactoryBot.body(:synthetic_api))
        update
      end
    end
  end
end
