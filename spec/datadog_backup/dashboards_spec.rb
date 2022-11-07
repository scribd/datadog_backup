# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Dashboards do
  before do
    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/dashboard', {}, {})
      .and_return({ 'dashboards' => [FactoryBot.body(:dashboard)]})

    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/dashboard/abc-123-def', {}, {})
      .and_return(FactoryBot.body(:dashboard))
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

      it { is_expected.to eq([FactoryBot.body(:dashboard)]) }
    end

    describe '.get_by_id' do
      subject { described_class.get_by_id('abc-123-def').id }

      it { is_expected.to eq('abc-123-def') }
    end

    describe '.myclass' do
      subject { described_class.myclass }

      it { is_expected.to eq('dashboards') }
    end
  end

  describe 'Instance Methods' do
    subject(:abc) { build(:dashboard) }

    describe '#diff' do
      subject(:diff) { abc.diff('text') }

      before do
        allow(abc).to receive(:body_from_backup)
          .and_return({ 'id' => 'abc-123-def', 'title' => 'def' })
      end

      it {
        expect(diff).to eq(<<~EODIFF
           ---
           id: abc-123-def
          -title: abc
          +title: def
        EODIFF
        .chomp)
      }
    end

    describe '#dump' do
      context 'when mode is :json' do
        subject(:json) { abc.dump(:json) }

        it { is_expected.to eq(JSON.pretty_generate(FactoryBot.body(:dashboard))) }
      end

      context 'when mode is :yaml' do
        subject(:yaml) { abc.dump(:yaml) }

        it { is_expected.to eq(FactoryBot.body(:dashboard).to_yaml) }
      end
    end

    describe '#myclass' do
      subject { abc.myclass }

      it { is_expected.to eq('dashboards') }
    end

    describe '#get' do
      subject(:get) { abc.get }

      it { is_expected.to eq(FactoryBot.body(:dashboard)) }
    end

    describe '#create' do
      subject(:create) { abc.create }

      it 'posts to the API' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:post_body)
          .with('/api/v1/dashboard', FactoryBot.body(:dashboard), {})
          .and_return(FactoryBot.body(:dashboard))
        create
      end
    end

    describe '#update' do
      subject(:update) { abc.update }

      it 'posts to the API' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:put_body)
          .with('/api/v1/dashboard/abc-123-def', FactoryBot.body(:dashboard), {})
          .and_return(FactoryBot.body(:dashboard))
        update
      end
    end
  end
end
