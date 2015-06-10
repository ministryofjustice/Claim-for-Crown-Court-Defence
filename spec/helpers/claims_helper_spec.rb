require "rails_helper"


describe ClaimsHelper do

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

end