require "rails_helper"


describe ClaimsHelper do

  describe '#claim_allocation_checkbox_helper' do
    let(:case_worker)         { double CaseWorker }
    let(:claim)               { double Claim }

    before(:each) do
      allow(claim).to receive(:id).and_return(66)
      allow(case_worker).to receive(:id).and_return(888)
    end

    it 'should produce the html for a checked checkbox if the claim is allocated to the case worker' do
      expect(claim).to receive(:is_allocated_to_case_worker?).with(case_worker).and_return(true)
      expected_html = %q{<input checked="checked" id="case_worker_claim_ids_66" name="case_worker[claim_ids][]" type="checkbox" value="66">}
      expect(claim_allocation_checkbox_helper(claim, case_worker)).to eq expected_html
    end

    it 'should produce the html for a un-checked checkbox if the claim is not allocated to the case worker' do
      expect(claim).to receive(:is_allocated_to_case_worker?).with(case_worker).and_return(false)
      expected_html = %q{<input  id="case_worker_claim_ids_66" name="case_worker[claim_ids][]" type="checkbox" value="66">}
      expect(claim_allocation_checkbox_helper(claim, case_worker)).to eq expected_html
    end

  end

	describe "#includes_state?" do

		let(:only_allocated_claims) { create_list(:allocated_claim, 5) }

		it "returns true if state included as array" do
			states_as_arr = ['draft','allocated']
			expect(includes_state?(only_allocated_claims,states_as_arr)).to eql(true)
		end

		it "returns true if state included as comma delimited string" do
			states_as_comma_delimited_string='draft,allocated'
			expect(includes_state?(only_allocated_claims,states_as_comma_delimited_string)).to eql(true)
		end

		it "returns false if state NOT included" do
			invalid_states ='draft,submitted'
			expect(includes_state?(only_allocated_claims,invalid_states)).to eql(false)
		end
  end

  describe '#show_api_promo_to_user?' do
    helper do
      def current_user
        instance_double(User, setting?: api_promo_seen_setting)
      end
    end

    before do
      allow(Settings).to receive(:api_promo_enabled?).and_return(api_promo_enabled)
    end

    context 'feature flag enabled' do
      let(:api_promo_enabled) { true }

      context 'user has not seen yet the promo' do
        let(:api_promo_seen_setting) { nil }

        it 'should return true' do
          expect(show_api_promo_to_user?).to be_truthy
        end
      end

      context 'user has seen the promo' do
        let(:api_promo_seen_setting) { '1' }

        it 'should return false' do
          expect(show_api_promo_to_user?).to be_falsey
        end
      end
    end

    context 'feature flag disabled' do
      let(:api_promo_enabled) { false }

      it 'should return false regardless of the user setting' do
        expect(helper).not_to receive(:current_user)
        expect(show_api_promo_to_user?).to be_falsey
      end
    end
  end
end