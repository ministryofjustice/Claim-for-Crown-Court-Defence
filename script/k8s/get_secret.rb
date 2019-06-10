#!/usr/bin/env ruby

# get_secret
# usage:
# script/get_secret name
# e.g.
# output default secrets oject to STDOUT
# `get_secret.rb -c live-1 -e dev -d true`
#
# write output to default temp secret file location (is .gitignored)
# `get_secret.rb -c live-1 -e dev -d true -w`
#
# query the s3 buckets secrets
# `get_secret.rb -c live-1 -e dev -s cccd-s3-bucket -d true`
#

require 'optparse'
require 'ostruct'
require 'yaml'
require 'base64'
require 'pry-byebug'

def grep_excludes
  @grep_excludes ||= 'annotations|last-applied-configuration|creationTimestamp|resourceVersion|selfLink|uid'
end

options = OpenStruct.new
options.context = `kubectl config current-context`.chomp
options.decode = false
options.write = false
options.secret = 'cccd-secrets'

OptionParser.new do |opts|
  opts.banner = "Usage: get_secret.rb [options]"
  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-c", "--context [CONTEXT]", "Required: Set context, defaults to k8s current-context") do |context|
    options.context = context
  end

  opts.on("-e", "--env [ENVIRONMENT]", "Required: the Environment for executing your script") do |env|
    options.environment = env
  end

  opts.on("-s", "--secret [SECRETS_OBJECT]", "Optional: the secret object from which to retrieve key-value pairs (default cccd-secrets)") do |secret|
    options.secret = secret
  end

  opts.on("-d", "--[no-]decode", "Optional: Decode base64, defaults to false") do |decode|
    options.decode = decode
  end

  opts.on("-w", "--write", "Optional: write output to file as yaml. Always writes to temp_<options.environment>_secrets.yaml") do |file|
    options.write = true
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

def write_file(secrets, options)
  file = File.join('kubectl_deploy', options.environment, "temp_#{options.environment}_secrets.yaml")
  File.open(file, 'w') do |file|
    file.write secrets.to_yaml
  end
  puts "secrets written to #{file}"
end

# entrypoint
if options.environment.nil?
  puts options
  exit
else
  cmd = "kubectl --context #{options.context} -n cccd-#{options.environment} get secret #{options.secret} -o yaml | grep -vE '#{grep_excludes}'"
  puts "Running command: #{cmd}"
  secrets = YAML.load(`#{cmd}`.chomp)
  secrets["data"].transform_values! { |v| Base64.decode64(v) unless v.nil? } if options.decode
  options.write ? write_file(secrets, options) : puts(secrets.to_yaml)
end

