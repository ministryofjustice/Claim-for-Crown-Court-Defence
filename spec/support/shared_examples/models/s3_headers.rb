RSpec.shared_examples 'an s3 bucket' do
  describe '.s3_headers' do
    subject { described_class.s3_headers }

    context ':s3_headers' do
      subject(:s3_headers) { described_class.s3_headers[:s3_headers] }

      it 'includes no-cache directive' do
        freeze_time do
          expect(s3_headers.values).to include('no-cache')
        end
      end

      it 'includes 3 month expiry directive' do
        freeze_time do
          is_expected.to include('Expires' => 3.months.from_now.httpdate)
        end
      end
    end

    context ':s3_permissions' do
      subject(:s3_permissions) { described_class.s3_headers[:s3_permissions] }

      it 'includes private directive for s3' do
        is_expected.to eql(:private)
      end
    end

    context ':s3_region' do
      subject(:s3_region) { described_class.s3_headers[:s3_region] }

      before { allow(Settings.aws).to receive(:region).and_return(fake_aws_region) }
      after { allow(Settings.aws).to receive(:region).and_call_original }

      let(:fake_aws_region) { 'eu-west-49' }

      it 'retrieves region from settings' do
        s3_region
        expect(Settings.aws).to have_received(:region)
      end

      it 'includes region value' do
        is_expected.to eql fake_aws_region
      end
    end
  end
end
