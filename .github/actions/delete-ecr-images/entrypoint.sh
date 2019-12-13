#!/usr/bin/env ruby

puts ENV['GITHUB_SHA']
puts ENV['GITHUB_REF']
puts ENV['GITHUB_EVENT_PATH']

puts ARGV
puts "first input was \"#{ARGV[0]}\""
puts 'need to check and delete ECR image with tag matching branch name standards and conventions'
