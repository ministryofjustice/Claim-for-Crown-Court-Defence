require 'rails_helper'

module Claim 
	describe BaseClaim do

		let(:advocate) { create :external_user }
		
		it 'raises if I try to instantiate a base claim' do
			expect {
				claim = BaseClaim.new(external_user: advocate, creator: advocate)
			}.to raise_error ::Claim::BaseClaimAbstractClassError, 'Claim::BaseClaim is an abstract class and cannot be instantiated'
		end
	end
end