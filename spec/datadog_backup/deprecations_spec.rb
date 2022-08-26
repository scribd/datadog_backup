# frozen_string_literal: true

require 'spec_helper'

describe DatadogBackup::Deprecations do
  subject(:check) { described_class.check }

  let(:logger) { instance_double('Logger') }

  before do
    stub_const('LOGGER', logger)
    allow(logger).to receive(:warn)
  end

  %w[2.4.10 2.5.9 2.6.8].each do |ruby_version|
    describe "#check#{ruby_version}" do
      it 'does warn' do
        stub_const('RUBY_VERSION', ruby_version)
        check
        expect(logger).to have_received(:warn).with(/ruby-#{ruby_version} is deprecated./)
      end
    end
  end

  %w[2.7.4 3.0.4 3.1.2 3.2.0-preview1].each do |ruby_version|
    describe "#check#{ruby_version}" do
      it 'does not warn' do
        stub_const('RUBY_VERSION', ruby_version)
        check
        expect(logger).not_to have_received(:warn).with(/ruby-#{ruby_version} is deprecated./)
      end
    end
  end
end
