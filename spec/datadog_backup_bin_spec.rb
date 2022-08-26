# frozen_string_literal: true

require 'open3'
require 'timeout'

describe 'bin/datadog_backup' do
  # Contract Or[nil,String] => self
  def run_bin(env = {}, args = '')
    status = nil
    output = ''
    cmd = "bin/datadog_backup #{args}"
    Open3.popen2e(env, cmd) do |i, oe, t|
      pid = t.pid

      Timeout.timeout(4.0) do
        oe.each do |v|
          output += v
        end
      end
    rescue Timeout::Error
      LOGGER.error "Timing out #{t.inspect} after 4 second"
      Process.kill(15, pid)
    ensure
      status = t.value
    end
    [output, status]
  end

  required_vars = %w[
    DD_API_KEY
    DD_APP_KEY
  ]

  env = {}
  required_vars.each do |v|
    env[v] = v.downcase
  end

  required_vars.map do |v|
    it "dies unless given ENV[#{v}]" do
      myenv = env.dup.tap { |h| h.delete(v) }
      _, status = run_bin(myenv, 'backup')
      expect(status).not_to be_success
    end
  end

  it 'supplies help' do
    out_err, status = run_bin(env, '--help')
    expect(out_err).to match(/Usage: DD_API_KEY=/)
    expect(status).to be_success
  end
end
