# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Monitors do
  before do
    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/monitor', {}, {})
      .and_return([{ 'id' => 'abc-123-def' }])

    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/monitor/abc-123-def', {}, {})
      .and_return({ 'id' => 'abc-123-def', 'name' => 'Test Monitor' })
  end

  describe 'Class Methods' do
    describe '.new_resource' do
      context 'with id and body' do
        subject { described_class.new_resource(id: 'abc-123-def', body: { id: 'abc-123-def' }) }

        it { is_expected.to be_a(described_class) }
      end

      context 'with id and no body' do
        subject { described_class.new_resource(id: 'abc-123-def') }

        it { is_expected.to be_a(described_class) }
      end

      context 'with no id and with body' do
        subject { described_class.new_resource(body: { id: 'abc-123-def' }) }

        it { is_expected.to be_a(described_class) }
      end

      context 'with no id and no body' do
        subject { proc { described_class.new_resource } }

        it { is_expected.to raise_error(ArgumentError) }
      end
    end

    describe '.all' do
      subject { described_class.all }

      it { is_expected.to be_a(Array) }
      it { is_expected.to all(be_a(described_class)) }
    end

    describe '.get_all' do
      subject { described_class.get_all }

      it { is_expected.to eq([{ 'id' => 'abc-123-def' }]) }
    end

    describe '.get_by_id' do
      subject { described_class.get_by_id('abc-123-def').id }

      it { is_expected.to eq('abc-123-def') }
    end

    describe '.myclass' do
      subject { described_class.myclass }

      it { is_expected.to eq('monitors') }
    end
  end

  describe 'Instance Methods' do
    subject(:abc) { described_class.new_resource(id: 'abc-123-def') }

    describe '#diff' do
      subject(:diff) { abc.diff }

      before do
        allow(abc).to receive(:body_from_backup)
          .and_return({ 'name' => 'Local Copy' })
        $options[:diff_format] = 'text'
      end

      it {
        expect(diff).to eq(<<~EODIFF
           ---
          -name: Test Monitor
          +name: Local Copy
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

        it { is_expected.to eq(%({\n  "name": "Test Monitor"\n})) }
      end

      context 'when mode is :yaml' do
        before do
          $options[:output_format] = :yaml
        end

        it { is_expected.to eq(%(---\nname: Test Monitor\n)) }
      end
    end

    describe '#myclass' do
      subject { abc.myclass }

      it { is_expected.to eq('monitors') }
    end

    describe '#get' do
      subject(:get) { abc.get }

      it { is_expected.to eq('name' => 'Test Monitor') }
    end

    describe '#create' do
      subject(:create) { abc.create }

      it 'posts to the API' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:post_body)
          .with('/api/v1/monitor', { 'name' => 'Test Monitor' }, {})
          .and_return({ 'id' => 'abc-999-def' })
        create
      end
    end

    describe '#update' do
      subject(:update) { abc.update }

      it 'posts to the API' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:put_body)
          .with('/api/v1/monitor/abc-123-def', { 'name' => 'Test Monitor' }, {})
          .and_return({ 'id' => 'abc-123-def' })
        update
      end
    end
  end
end
