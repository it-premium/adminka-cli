# frozen_string_literal: true

require "tmpdir"
require "fileutils"
require "open3"
require "json"
require "yaml"
require "socket"
require "timeout"

abort "Run on macOS" unless RUBY_PLATFORM.include?("darwin")
Dir.mktmpdir("adminka smoke ") do |temp|
  copy = File.join(temp, "Тест Adminka with spaces")
  FileUtils.cp_r(__dir__, copy)
  env = { "XDG_CONFIG_HOME" => File.join(temp, "config"), "ADMINKA_URL" => nil,
          "ADMINKA_TOKEN" => nil, "http_proxy" => nil, "HTTP_PROXY" => nil,
          "https_proxy" => nil, "HTTPS_PROXY" => nil }
  launcher = File.join(copy, "adminka")
  run = lambda do |*args|
    Timeout.timeout(15) { Open3.capture3(env, launcher, *args) }
  end
  output, error, status = run.call("--help")
  raise "Help failed: #{error}" unless status.success? && output.include?("tickets")
  _, error, status = run.call("tickets", "--my", "--json")
  raise "Missing-config error failed" if status.success? || !error.include?("Not configured")

  server = TCPServer.new("127.0.0.1", 0)
  requests = Queue.new
  worker = Thread.new do
    loop do
      socket = server.accept
      request = socket.gets
      headers = {}
      while (line = socket.gets) && line != "\r\n"
        key, value = line.split(":", 2)
        headers[key.downcase] = value.strip
      end
      body = socket.read(headers.fetch("content-length", "0").to_i)
      requests << [request, headers, body]
      path = request.split[1]
      code, data = case path
                   when "/api/device_authorizations"
                     [200, { verification_url: "https://example.invalid/confirm", user_code: "TEST-CODE",
                             device_code: "fake-device", interval: 1, expires_in: 20 }]
                   when "/api/device_authorizations/token"
                     [200, { access_token: "OFFLINE_TEST_ONLY" }]
                   when "/api/tickets/my"
                     [200, { tickets: [{ id: 123, description: "Перевірка заявки" }] }]
                   else
                     [401, {}]
                   end
      payload = JSON.generate(data)
      socket.write("HTTP/1.1 #{code} Test\r\nContent-Type: application/json\r\nContent-Length: #{payload.bytesize}\r\nConnection: close\r\n\r\n#{payload}")
      socket.close
    end
  end
  begin
    base = "http://127.0.0.1:#{server.addr[1]}"
    output, error, status = run.call("login", "--url", base)
    raise "Mock login failed: #{error}" unless status.success? && output.include?("TEST-CODE")
    config_path = File.join(temp, "config", "adminka", "config.yml")
    raise "Config mode not 0600" unless File.stat(config_path).mode & 0o777 == 0o600
    raise "Fake token not saved" unless YAML.load_file(config_path)["token"] == "OFFLINE_TEST_ONLY"
    output, error, status = run.call("tickets", "--my", "--json")
    raise "Unicode JSON failed: #{error}" unless status.success? && JSON.parse(output)["tickets"][0]["description"] == "Перевірка заявки"
    _, error, status = run.call("ticket", "999", "--json")
    raise "401 error failed" if status.success? || !error.include?("Unauthorized")
    seen = []
    seen << requests.pop until requests.empty?
    raise "Bearer token missing" unless seen.select { |req| req[0].start_with?("GET") }.all? { |req| req[1]["authorization"] == "Bearer OFFLINE_TEST_ONLY" }
    raise "Device code missing" unless JSON.parse(seen[1][2])["device_code"] == "fake-device"
    puts JSON.generate(status: "PASS", checks: ["relocated Unicode/spaced path", "help", "missing config", "mock device login", "config mode 0600", "Bearer authentication", "Unicode JSON", "401 nonzero exit"], untested: ["real browser authorization", "production API", "AI assistants", "other macOS versions/Intel"])
  ensure
    worker.kill
    worker.join
    server.close
  end
end
