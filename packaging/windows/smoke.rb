# frozen_string_literal: true

# Offline test: isolated config, no real credentials, no API calls.
require "tmpdir"
require "fileutils"
require "open3"
require "json"
require "yaml"

abort "Run this test on Windows" unless Gem.win_platform?
Dir.mktmpdir("adminka smoke ") do |temp|
  copy = File.join(temp, "Тест Adminka with spaces")
  FileUtils.cp_r(__dir__, copy)
  env = { "XDG_CONFIG_HOME" => File.join(temp, "config"), "ADMINKA_URL" => nil, "ADMINKA_TOKEN" => nil }
  launcher = File.join(copy, "adminka.cmd")
  run = lambda do |*args|
    output, error, status = Open3.capture3(env, launcher, *args)
    raise "Command failed: #{error}" unless status.success?
    output
  end
  raise "Missing help" unless run.call("--help").include?("tickets")
  run.call("login", "--url", "https://example.invalid", "--token", "OFFLINE_TEST_ONLY")
  config = YAML.load_file(File.join(temp, "config", "adminka", "config.yml"))
  raise "Config roundtrip failed" unless config["token"] == "OFFLINE_TEST_ONLY"
  puts JSON.generate(status: "PASS", checks: ["Windows launcher", "relocation", "Unicode/spaced path", "help", "isolated config roundtrip"], untested: ["HTTPS", "browser authorization", "API", "Windows credential ACLs", "AI assistants"])
end
