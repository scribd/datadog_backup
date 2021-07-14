# frozen_string_literal: true

require 'open3'
require 'timeout'

describe 'bin/datadog_backup' do
  # Contract Or[nil,String] => self
  def run_bin(args = '', input = nil)
    status = nil
    output = ''
    cmd = "bin/datadog_backup #{args}"
    Open3.popen2e(cmd) do |i, oe, t|
      pid = t.pid

      if input
        i.puts input
        i.close
      end

      Timeout.timeout(2.0) do
        oe.each do |v|
          output += v
        end
      end
    rescue Timeout::Error
      LOGGER.warn "Timing out #{t.inspect} after 2 second"
      Process.kill(15, pid)
    ensure
      status = t.value
    end
    [output, status]
  end

  required_vars = %w[
    DATADOG_API_KEY
    DATADOG_APP_KEY
  ]

  env = {}
  required_vars.each do |v|
    env[v] = v.downcase
  end

  required_vars.map do |v|
    it "dies unless given ENV[#{v}]" do
      stub_const('ENV', env.dup.tap { |h| h.delete(v) })
      _, status = run_bin('backup')
      expect(status).not_to be_success
    end
  end

  it 'supplies help' do
    stub_const('ENV', env)
    out_err, status = run_bin('--help')
    expect(out_err).to match(/Usage: DATADOG_API_KEY=/)
    expect(status).to be_success
  end
end
