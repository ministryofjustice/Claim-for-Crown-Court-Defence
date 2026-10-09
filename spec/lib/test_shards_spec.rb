require 'tmpdir'
require_relative '../../script/test_shards'

RSpec.describe TestShards do
  around do |example|
    Dir.mktmpdir do |directory|
      Dir.chdir(directory) { example.run }
    end
  end

  def create_files(sizes)
    sizes.map.with_index do |size, index|
      file = "test_#{index}_spec.rb"
      File.write(file, 'x' * size)
      file
    end
  end

  def report_xml(files, durations)
    cases = files.zip(durations).map do |file, duration|
      %(<testcase file="./#{file}" time="#{duration}"/>)
    end
    File.write('results.xml', "<testsuite>#{cases.join}</testsuite>")
    ['results.xml']
  end

  it 'balances measured runtimes rather than file counts' do
    files = create_files([1, 1, 1, 1])
    reports = report_xml(files, [9, 3, 3, 3])

    groups = described_class.groups(files, reports, 2)

    expect(groups.map(&:size).sort).to eq([1, 3])
  end

  it 'sums scenario or example durations for each file' do
    files = create_files([1, 1, 1, 1])
    reports = report_xml([files[0], files[0], *files.drop(1)], [4, 5, 3, 3, 3])

    expect(described_class.groups(files, reports, 2).map(&:size).sort).to eq([1, 3])
  end

  it 'balances by file size without historical timings' do
    files = create_files([9, 3, 3, 3])

    expect(described_class.groups(files, [], 2).map(&:size).sort).to eq([1, 3])
  end

  it 'includes new files exactly once and ignores removed files' do
    files = create_files([9, 3, 3, 3])
    reports = report_xml([files.first, 'removed_spec.rb'], [9, 100])

    expect(described_class.groups(files, reports, 6).flatten.sort).to eq(files.sort)
  end

  it 'creates empty groups when there are fewer files than shards' do
    files = create_files([1])

    expect(described_class.groups(files, [], 6).map(&:size).sort).to eq([0, 0, 0, 0, 0, 1])
  end

  it 'creates empty groups when there are no files' do
    expect(described_class.groups([], [], 6)).to eq(Array.new(6) { [] })
  end

  context 'when writing manifests' do
    before do
      FileUtils.mkdir_p(%w[spec features])
      File.write('spec/example_spec.rb', 'spec')
      File.write('features/example.feature', 'feature')
      described_class.write('reports', 'shards', 6)
    end

    it 'writes one manifest per suite and shard' do
      expect(Dir.glob('shards/*.txt').size).to eq(12)
    end

    it 'includes each Ruby spec once' do
      expect(Dir.glob('shards/rspec-*.txt').flat_map { |file| File.readlines(file, chomp: true) })
        .to eq(['spec/example_spec.rb'])
    end

    it 'includes each feature file once' do
      expect(Dir.glob('shards/cucumber-*.txt').flat_map { |file| File.readlines(file, chomp: true) })
        .to eq(['features/example.feature'])
    end
  end
end
