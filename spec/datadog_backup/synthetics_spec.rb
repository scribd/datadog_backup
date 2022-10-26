# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Synthetics do
  before do
    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests', {}, {})
      .and_return({ 'tests' => [
                    { 'public_id' => 'abc-123-def', 'type' => 'api' },
                    { 'public_id' => 'ghi-456-jkl', 'type' => 'browser' }
                  ] })

    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests/api/abc-123-def', {}, {})
      .and_return({ 'public_id' => 'abc-123-def', 'type' => 'api' })

    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests/browser/ghi-456-jkl', {}, {})
      .and_return({ 'public_id' => 'ghi-456-jkl', 'type' => 'browser' })

    # While searching for a test, datadog_backup will brute force try one before the other.
    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests/browser/abc-123-def', {}, {})
      .and_raise(Faraday::ResourceNotFound)

    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/synthetics/tests/api/ghi-456-jkl', {}, {})
      .and_raise(Faraday::ResourceNotFound)
  end

  describe 'Class Methods' do
    describe '.new_resource' do
      context 'with id and body' do
        subject { described_class.new_resource(id: 'abc-123-def', body: { public_id: 'abc-123-def' }) }

        it { is_expected.to be_a(described_class) }
      end

      context 'with id and no body' do
        subject { described_class.new_resource(id: 'abc-123-def') }

        it { is_expected.to be_a(described_class) }
      end

      context 'with no id and with body' do
        subject { described_class.new_resource(body: { public_id: 'abc-123-def' }) }

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
          { 'public_id' => 'abc-123-def', 'type' => 'api' },
          { 'public_id' => 'ghi-456-jkl', 'type' => 'browser' }
        )
      }
    end

    describe '.get_by_id' do
      subject { described_class.get_by_id('abc-123-def').id }

      it { is_expected.to eq('abc-123-def') }
    end

    describe '.myclass' do
      subject { described_class.myclass }

      it { is_expected.to eq('synthetics') }
    end
  end

  describe 'Instance Methods' do
    subject(:abc) { described_class.new_resource(id: 'abc-123-def') }

    describe '#diff' do
      subject(:diff) { abc.diff }

      before do
        allow(abc).to receive(:body_from_backup)
          .and_return({ 'public_id' => 'abc-123-def', 'type' => 'api', 'title' => 'abc' })
        $options[:diff_format] = 'text'
      end

      it {
        expect(diff).to eq(<<~EODIFF
           ---
          +public_id: abc-123-def
           type: api
          +title: abc
        EODIFF
        .chomp)
      }
    end

    describe '#dump' do
      subject(:dump) { abc.dump }

      context 'when mode is :json' do
        before do
          $options[:output_format] = :json
        end

        it { is_expected.to eq(%({\n  "type": "api"\n})) }
      end

      context 'when mode is :yaml' do
        before do
          $options[:output_format] = :yaml
        end

        it { is_expected.to eq(%(---\ntype: api\n)) }
      end
    end

    describe '#myclass' do
      subject { abc.myclass }

      it { is_expected.to eq('synthetics') }
    end

    describe '#get' do
      subject(:get) { abc.get }

      it { is_expected.to eq({ 'type' => 'api' }) }
    end

    describe '#create' do
      subject(:create) { abc.create }

      it 'posts to the api endpoint' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:post_body)
          .with('/api/v1/synthetics/tests/api', { 'type' => 'api' }, {})
          .and_return({ 'public_id' => 'abc-999-def' })
        create
      end
    end

    describe '#update' do
      subject(:update) { abc.update }

      it 'puts to the api endpoint' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:put_body)
          .with('/api/v1/synthetics/tests/api/abc-123-def', { 'type' => 'api' }, {})
          .and_return({ 'public_id' => 'abc-123-def' })
        update
      end
    end
  end
end
