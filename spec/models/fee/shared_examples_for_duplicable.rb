RSpec.shared_examples 'duplicable fee' do
  subject(:fee) { build(described_class.to_s.demodulize.underscore.to_sym) }
  let(:parent) { fee._parent_amoeba.instance_variable_get(:@klass) }
  let(:config) { fee._parent_amoeba.instance_variable_get(:@config) }

  it { is_expected.to respond_to(:duplicate) }

  it 'inherits amoeba config from its superclass' do
    expect(parent).to be described_class.superclass
    expect(config).to include(inherit: true)
  end

  it 'clones dates attended' do
    expect(config[:clones]).to include(:dates_attended)
  end
end
