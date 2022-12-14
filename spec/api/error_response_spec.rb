RSpec.shared_examples 'model error handler' do |model_klass|
  context "with #{model_klass} object" do
    subject(:error_response) { described_class.new(model_instance) }

    let(:model_instance) { build(model_name.to_sym) }
    let(:model_name) { model_klass.name.demodulize.underscore }

    context 'with no errors' do
      before { allow(model_instance).to receive(:errors).and_return([]) }

      it { expect { error_response }.to raise_error(RuntimeError, 'unable to build error response as no errors were found') }
    end

    context 'with errors on nested models' do
      before do
        error = instance_double(ActiveModel::Error, attribute: 'foo', message: 'bar')
        allow(model_instance).to receive(:errors) { [error] }
      end

      it { expect(error_response.status).to eq(400) }
      it { expect(error_response.body).to include({ error: "#{model_name.humanize} 1 foo bar" }) }
    end
  end
end

RSpec.shared_examples 'claim model error handler' do |model_klass|
  context "with #{model_klass} object" do
    subject(:error_response) { described_class.new(model_instance) }

    let(:model_instance) { build(model_name.to_sym) }
    let(:model_name) { model_klass.name.demodulize.underscore }

    context 'with no errors' do
      before { allow(model_instance).to receive(:errors).and_return([]) }

      it { expect { error_response }.to raise_error(RuntimeError, 'unable to build error response as no errors were found') }
    end

    context 'with errors on claims' do
      before do
        error = instance_double(ActiveModel::Error, attribute: 'foo', message: 'bar')
        allow(model_instance).to receive(:errors) { [error] }
      end

      it { expect(error_response.status).to eq(400) }
      it { expect(error_response.body).to include({ error: 'Foo bar' }) }
    end
  end
end

RSpec.shared_examples 'api exception handler' do |exception_klass|
  context "with #{exception_klass} exception object" do
    subject(:error_response) { described_class.new(ex) }

    let(:ex) { exception_klass.new('my exception message') }

    it { expect { error_response }.not_to raise_error }
    it { expect(error_response.status).to eq 400 }
    it { expect(error_response.body).to include(error: 'my exception message') }
  end
end

RSpec.describe API::ErrorResponse do
  subject(:error_response) { described_class.new(claim) }

  NESTED_MODEL_KLASSES = [Expense, Disbursement, Defendant, DateAttended, RepresentationOrder,
                          Fee::GraduatedFee, Fee::InterimFee, Fee::TransferFee, Fee::BasicFee, Fee::MiscFee, Fee::FixedFee]
  CLAIM_MODEL_KLASSES =  [Claim::AdvocateClaim, Claim::AdvocateInterimClaim, Claim::AdvocateSupplementaryClaim,
                          Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim, Claim::AdvocateHardshipClaim,
                          Claim::LitigatorHardshipClaim]
  EXCEPTION_KLASSES = [RuntimeError, ArgumentError]

  let(:claim) { build(:claim, case_number: 'A123456') }

  before do
    claim.force_validation = true
    claim.valid?
  end

  it { is_expected.to respond_to(:status, :body) }
  it { expect { error_response.body.to_json }.not_to raise_error }

  NESTED_MODEL_KLASSES.each do |model_klass|
    it_behaves_like 'model error handler', model_klass
  end

  CLAIM_MODEL_KLASSES.each do |model_klass|
    it_behaves_like 'claim model error handler', model_klass
  end

  EXCEPTION_KLASSES.each do |exception_klass|
    it_behaves_like 'api exception handler', exception_klass
  end

  context 'with Unauthorized exception' do
    subject(:error_response) { described_class.new(ex) }

    let(:ex) { ArgumentError.new('Unauthorised') }

    it { expect(error_response.status).to eq 401 }
  end

  context 'with other objects' do
    [1, '1', [1, 2]].each do |other_object|
      context "when #{other_object.class}" do
        subject(:error_response) { described_class.new(other_object) }

        it { expect { error_response }.not_to raise_error }
        it { expect(error_response.status).to eq 400 }
        it { expect(error_response.body).to include(error: "No message provided by object #{other_object.class}") }
      end
    end
  end
end
