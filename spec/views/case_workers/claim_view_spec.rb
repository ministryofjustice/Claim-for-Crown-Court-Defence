require 'rails_helper'

describe 'case_workers/claims/show.html.haml', type: :view do
  include ViewSpecHelper

  before(:all) do
    @case_worker = create :case_worker
    @doc_types = DocType.all
  end

  after(:all) do
    clean_database
  end

  before(:each) do
    initialize_view_helpers(view)
    sign_in :user, @case_worker.user
    allow(view).to receive(:current_user_persona_is?).and_return(false)
    assign(:claim, @claim)
  end

  context 'certified claims' do
    before(:all) { certified_claim }

    it 'displays who certified the claim' do
      render
      expect(rendered).to include('Bobby Legrand')
    end

    it 'shows the reason for certification' do
      render
      expect(rendered).to include('which ever reason i please')
    end
  end

  context 'trial and retrial claims' do
    it 'shows trial details' do
      trial_claim
      assign(:claim, @claim)
      render
      expect(rendered).to have_content('First day of trial')
    end

    it 'shows retrial details' do
      trial_claim('re')
      assign(:claim, @claim)
      render
      expect(rendered).to have_content('First day of retrial')
    end
  end


  def certified_claim
    @claim = create(:allocated_claim)
    @claim.certification.destroy unless @claim.certification.nil?
    certification_type = FactoryGirl.create(:certification_type, name: 'which ever reason i please')
    FactoryGirl.create(:certification, claim: @claim, certified_by: 'Bobby Legrand', certification_type: certification_type)
    @case_worker.claims << @claim
    @claim.reload
    @messages = @claim.messages.most_recent_last
    @message = @claim.messages.build
  end

  def trial_claim(trial_prefix = nil)
    @claim = create(:submitted_claim, case_type: FactoryGirl.create(:case_type, "#{trial_prefix}trial".to_sym))
    @case_worker.claims << @claim
    @messages = @claim.messages.most_recent_last
    @message = @claim.messages.build
  end
end
