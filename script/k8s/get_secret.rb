#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'yaml'
require 'base64'

def grep_excludes
  @grep_excludes ||= 'annotations|last-applied-configuration|creationTimestamp|resourceVersion|selfLink|uid'
end

options = OpenStruct.new
options.context = 'live-0'
options.decode = false
options.output = false

OptionParser.new do |opts|
  opts.banner = "Usage: get_secret.rb [options]"
  opts.separator ""
  opts.separator "Specific options:"
  opts.on("-e", "--env ENVIRONMENT", "Require the Environment before executing your script") do |env|
    options.environment = env
  end
  opts.on("-d", "--[no-]decode", "Decode base64, defaults to false") do |d|
    options.decode = d
  end
  opts.on("-o", "--output", "Output as yaml file in format `temp_[environment]_secrets.yaml`") do |o|
    options.output = o
  end
  opts.on("-c", "--context [CONTEXT]", "Set context, defaults to `live-0`") do |context|
    options.context = context
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
end.parse!

if options.environment.nil?
  puts opts
  exit
else
  values = YAML.load(`kubectl --context #{options.context} -n cccd-#{options.environment} get secret cccd-#{options.environment}-secrets -o yaml | grep -vE '#{grep_excludes}'`)
  secrets = values
  values["data"].transform_values! { |v| Base64.decode64(v) unless v.nil? } if options.decode
  if options.output
    File.open(File.join('kubectl_deploy', options.environment, "temp_#{options.environment}_secrets.yaml"), 'w') do |file|
      file.write secrets.to_yaml
    end
  else
    pp secrets
  end
end
