#!/usr/bin/env ruby

puts ENV['GITHUB_SHA']
puts ENV['GITHUB_REF']
puts ENV['GITHUB_EVENT_PATH']

puts 'need to check and delete ECR image with tag matching branch name standards and conventions'

find_image(expected_tag_name)

def find_image(tag_name)
  puts "looking for image with tag: #{tag_name}"
  system("aws ecr describe-images --repository-name laa-get-paid/cccd --query \"imageDetails[?contains(imageTags, \'#{tag_name}\')]\"")
end

def event_file
  @event_file ||= File.read(ENV['GITHUB_EVENT_PATH'])
end

def event
  JSON.parse(event_file)
end

def branch_name
  event[:ref]
end

def expected_tag_name
  "app-#{branch_name}-latest"
end

# set output to github action
system("echo ::set-output name=my-output::Ran delete ECR images at: #{Time.now}")
