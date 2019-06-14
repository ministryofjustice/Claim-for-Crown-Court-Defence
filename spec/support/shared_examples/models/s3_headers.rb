RSpec.shared_examples 'an s3 bucket' do
  describe '.s3_headers' do
    subject { described_class.s3_headers[:s3_region] }

    context 'when an aws region has been explicitly recorded in the settings' do
      let(:fake_aws_region) { 'eu-west-49'}

      before { allow(Settings.aws).to receive(:region).and_return(fake_aws_region) }

      it { is_expected.to eql fake_aws_region }
    end

    context 'when an aws region has not been set' do

      before { allow(Settings.aws).to receive(:region).and_return(nil) }

      it { is_expected.to eql 'eu-west-1' }
    end
  end
end
