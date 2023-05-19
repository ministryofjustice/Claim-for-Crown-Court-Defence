require 'rails_helper'
require 'services/cleaners/cleaner_shared_examples'

RSpec.describe Cleaners::AdvocateInterimClaimCleaner do
  subject(:cleaner) { described_class.new(claim) }

  describe '#call' do
    subject(:call_cleaner) { cleaner.call }

    let(:claim) { create(:advocate_interim_claim) }

    include_examples 'fix advocate category'
  end
end
