# frozen_string_literal: true

RSpec.describe CertificationValidator, type: :validator do
  subject(:certification) { build(:certification, certification_type:, claim:) }

  let(:certification_type) { create(:certification_type) }
  let(:claim) { build(:claim) }

  describe '#validate_certification_type_id' do
    context 'when agfs final claim' do
      let(:claim) { build(:advocate_final_claim) }

      context 'with certification type' do
        before { certification.certification_type_id = certification_type.id }

        it { expect(certification).to be_valid }
      end

      context 'with no certification type' do
        before { certification.certification_type_id = nil }

        it { expect(certification).not_to be_valid }

        it {
          certification.valid?
          expect(certification.errors.messages[:certification_type_id]).to include('Choose a certification type')
        }
      end
    end

    context 'with advocate interim claim' do
      let(:claim) { build(:advocate_interim_claim) }

      context 'with no certification type' do
        before { certification.certification_type_id = nil }

        it { expect(certification).to be_valid }
      end
    end

    context 'with litigator claim' do
      let(:claim) { build(:litigator_final_claim) }

      context 'with no certification type' do
        before { certification.certification_type_id = nil }

        it { expect(certification).to be_valid }
      end
    end
  end

  describe '#validate_certified_by' do
    before { certification.certified_by = nil }

    it { expect(certification).not_to be_valid }

    it {
      certification.valid?
      expect(certification.errors.messages[:certified_by])
        .to include('Enter the name of person certifying')
    }
  end

  describe '#validate_certification_date' do
    context 'when before the claim creation date' do
      let(:claim) { build(:claim, created_at: 2.days.ago) }

      before do
        certification.certification_date = 3.days.ago
      end

      it { expect(certification).not_to be_valid }

      it {
        certification.valid?
        expect(certification.errors.messages[:certification_date])
          .to include('Certification date must be same day or after claim submission day')
      }
    end

    context 'when in the future' do
      before do
        certification.certification_date = 10.days.from_now
      end

      it { expect(certification).not_to be_valid }

      it {
        certification.valid?
        expect(certification.errors.messages[:certification_date])
          .to include('Certification date cannot be in the future')
      }
    end
  end
end
