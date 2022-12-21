# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Monitors do
  before do
    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/monitor', {}, {})
      .and_return([FactoryBot.body(:monitor)])

    allow_any_instance_of(DatadogBackup::Client).to receive(:get_body)
      .with('/api/v1/monitor/12345', {}, {})
      .and_return(FactoryBot.body(:monitor))
  end

  describe 'Class Methods' do
    describe '.new_resource' do
      context 'with id and body' do
        subject { described_class.new_resource(id: '12345', body: FactoryBot.body(:monitor)) }

        it { is_expected.to be_a(described_class) }
      end

      context 'with id and no body' do
        subject { described_class.new_resource(id: '12345') }

        it { is_expected.to be_a(described_class) }
      end

      context 'with no id and with body' do
        subject { described_class.new_resource(body: FactoryBot.body(:monitor)) }

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

      it { is_expected.to eq([FactoryBot.body(:monitor)]) }
    end

    describe '.get_by_id' do
      subject { described_class.get_by_id('12345').id }

      it { is_expected.to eq('12345') }
    end

    describe '.myclass' do
      subject { described_class.myclass }

      it { is_expected.to eq('monitors') }
    end
  end

  describe 'Instance Methods' do
    subject(:abc) { build(:monitor) }

    describe '#diff' do
      subject(:diff) { abc.diff('text') }

      before do
        allow(abc).to receive(:body_from_backup)
          .and_return({ 'id' => '12345', 'name' => 'Local Copy' })
      end

      it {
        expect(diff).to eq(<<~EODIFF
           ---
           id: '12345'
          -name: '12345'
          +name: Local Copy
        EODIFF
        .chomp)
      }
    end

    describe '#dump' do
      context 'when mode is :json' do
        subject(:json) { abc.dump(:json) }

        it { is_expected.to eq(JSON.pretty_generate(FactoryBot.body(:monitor))) }
      end

      context 'when mode is :yaml' do
        subject(:yaml) { abc.dump(:yaml) }

        it { is_expected.to eq(FactoryBot.body(:monitor).to_yaml) }
      end
    end


    describe '#myclass' do
      subject { abc.myclass }

      it { is_expected.to eq('monitors') }
    end

    describe '#get' do
      subject(:get) { abc.get }

      it { is_expected.to eq(FactoryBot.body(:monitor)) }
    end

    describe '#create' do
      subject(:create) { abc.create }

      it 'posts to the API' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:post_body)
          .with('/api/v1/monitor',  FactoryBot.body(:monitor) , {})
          .and_return({ 'id' => 'abc-999-def' })
        create
      end
    end

    describe '#update' do
      subject(:update) { abc.update }

      it 'posts to the API' do
        expect_any_instance_of(DatadogBackup::Client).to receive(:put_body)
          .with('/api/v1/monitor/12345', FactoryBot.body(:monitor), {})
          .and_return(FactoryBot.body(:monitor))
        update
      end
    end
  end
end
