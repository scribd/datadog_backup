# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Deprecations do
  let(:logger) { double }

  before do
    stub_const('LOGGER', logger)
    allow(logger).to receive(:warn)
  end

  %w[2.4.10 2.5.9 2.6.8].each do |ruby_version|
    describe "#check#{ruby_version}" do
      subject { described_class.check }

      it 'does warn' do
        stub_const('RUBY_VERSION', ruby_version)
        expect(logger).to receive(:warn).with(/ruby-#{ruby_version} is deprecated./)
        subject
      end
    end
  end

  %w[2.7.4 3.0.4 3.1.2 3.2.0-preview1].each do |ruby_version|
    describe "#check#{ruby_version}" do
      subject { described_class.check }

      it 'does not warn' do
        stub_const('RUBY_VERSION', ruby_version)
        expect(logger).to_not receive(:warn).with(/ruby-#{ruby_version} is deprecated./)
        subject
      end
    end
  end
end
