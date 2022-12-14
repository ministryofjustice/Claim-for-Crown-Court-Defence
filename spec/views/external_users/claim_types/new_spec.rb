# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'external_users/claim_types/new.html.haml' do
  let(:external_user) { create(:external_user) }
  let(:claim_type) { ClaimType.new }

  before do
    initialize_view_helpers(view)
    sign_in(external_user.user)
  end

  include_context 'claim-types helpers'

  context 'with all available_claim_types' do
    before do
      assign(:available_claim_types, all_claim_types)
      assign(:claim_type, claim_type)
      render
    end

    it 'includes advocate and litigator claim types' do
      expect(response.body).to include('Advocate final fee', 'Advocate warrant fee',
                                       'Advocate supplementary fee', 'Advocate hardship fee',
                                       'Litigator final fee', 'Litigator interim fee',
                                       'Litigator transfer fee', 'Litigator hardship fee')
    end
  end

  context 'with lgfs available_claim_types' do
    before do
      assign(:available_claim_types, lgfs_claim_types)
      assign(:claim_type, claim_type)
      render
    end

    it 'includes litigator claim types' do
      expect(response.body).to include('Litigator final fee',
                                       'Litigator interim fee',
                                       'Litigator transfer fee',
                                       'Litigator hardship fee')
    end

    it 'does not include advocate claim types' do
      expect(response.body).not_to include('Advocate final fee',
                                           'Advocate warrant fee',
                                           'Advocate supplementary fee',
                                           'Advocate hardship fee')
    end
  end

  context 'with agfs available_claim_types' do
    before do
      assign(:available_claim_types, agfs_claim_types)
      assign(:claim_type, claim_type)
      render
    end

    it 'includes advocate claim types' do
      expect(response.body).to include('Advocate final fee',
                                       'Advocate warrant fee',
                                       'Advocate supplementary fee',
                                       'Advocate hardship fee')
    end

    it 'does not include litigator claim types' do
      expect(response.body).not_to include('Litigator final fee',
                                           'Litigator interim fee',
                                           'Litigator transfer fee',
                                           'Litigator hardship fee')
    end
  end
end
