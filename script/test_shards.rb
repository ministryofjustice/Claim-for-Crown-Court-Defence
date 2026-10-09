# frozen_string_literal: true

require 'fileutils'
require 'rexml/document'
require 'parallel_tests/grouper'

module TestShards
  SUITES = { 'rspec' => 'spec/**/*_spec.rb', 'cucumber' => 'features/**/*.feature' }.freeze

  def self.groups(files, reports, count)
    timings = timings_for(files, reports)
    rate = runtime_per_byte(timings)
    weights = files.sort.map { |file| [file, weight(file, timings, rate)] }
    ParallelTests::Grouper.in_even_groups_by_size(weights, count)
  end

  def self.timings_for(files, reports)
    timings = Hash.new(0.0)
    reports.sort.each { |report| add_report(timings, files, report) }
    timings.select { |_file, duration| duration.positive? }
  end

  def self.add_report(timings, files, report)
    document = REXML::Document.new(File.read(report))
    REXML::XPath.each(document, '//testcase') do |testcase|
      file = testcase.attributes['file']&.delete_prefix('./')
      next unless files.include?(file)

      duration = Float(testcase.attributes['time'])
      timings[file] += duration if duration.finite? && duration >= 0
    end
  end

  def self.runtime_per_byte(timings)
    bytes = timings.keys.sum { |file| File.size(file) }
    timings.values.sum / [bytes, 1].max
  end

  def self.weight(file, timings, rate)
    return File.size(file) if timings.empty?

    timings.fetch(file) { [File.size(file) * rate, 0.001].max }
  end

  def self.write(reports_directory, output_directory, count)
    FileUtils.mkdir_p(output_directory)
    SUITES.each do |suite, pattern|
      files = Dir.glob(pattern)
      reports = Dir.glob("#{reports_directory}/#{suite}-results-*/**/*.xml")
      groups(files, reports, count).each_with_index do |group, index|
        File.write("#{output_directory}/#{suite}-#{index + 1}.txt", group.join("\n") + (group.empty? ? '' : "\n"))
      end
    end
  end
end

TestShards.write(ARGV.fetch(0), ARGV.fetch(1), Integer(ARGV.fetch(2))) if $PROGRAM_NAME == __FILE__
