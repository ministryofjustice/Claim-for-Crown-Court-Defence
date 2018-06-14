require 'rails_helper'

RSpec.describe PreviousVersionOfClaim do
  subject(:previous_version) { described_class.new(claim) }

  let(:claim) { create(:archived_pending_delete_claim, evidence_checklist_ids: [3, 4, 1]) }

  describe 'call' do
    subject(:call) { previous_version.call }

    it { is_expected.to be_a Claim::BaseClaim }

    context 'when claim was archived by legacy paper_trail' do
      before do
        # manually update the, correctly, archived record to reflect the legacy style
        version = claim.versions.last
        new_object = version.object_deserialized.transform_values do |value|
          if value.present? && value.eql?("---\n- 3\n- 4\n- 1\n")
            [3, 4, 1]
          else
            value
          end
        end
        version.update_columns object: PaperTrail.serializer.dump(new_object)
      end

      it { expect{ previous_version.version }.to raise_error(ActiveRecord::SerializationTypeMismatch) }
    end
  end
end
