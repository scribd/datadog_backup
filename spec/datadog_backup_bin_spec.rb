require 'open3'
require 'climate_control'
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

      Timeout.timeout(1.0) do
        oe.each do |v|
          output << v
        end
      end
    rescue Timeout::Error
      LOGGER.warn "Timing out #{t.inspect} after 1 second"
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

  before do
    required_vars.each do |v|
      ClimateControl.env[v] = v.downcase
    end
  end

  required_vars.map do |v|
    it "dies unless given ENV[#{v}]" do
      ClimateControl.env[v] = nil
      out_err, status = run_bin('backup')
      expect(status).to_not be_success
    end
  end

  it 'supplies help' do
    out_err, status = run_bin('--help')
    expect(out_err).to match(/Usage: datadog_backup/)
    expect(status).to be_success
  end
end
