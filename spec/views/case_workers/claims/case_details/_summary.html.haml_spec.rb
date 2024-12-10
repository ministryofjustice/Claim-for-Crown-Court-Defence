# frozen_string_literal: true

RSpec::Matchers.define :have_govuk_summary_row do |key, value|
  match do |page|
    page.all('.govuk-summary-list__row').map do |row|
      row.has_selector?('.govuk-summary-list__key', text: key) &&
        row.has_selector?('.govuk-summary-list__value', text: value)
    end.any?
    # page.has_govuk_summary_row?(key, value) # can't negate just the key
  end

  description do
    "have govuk summary list row for \"#{key}\" with \"#{value}\""
  end

  failure_message do |page|
    "expected \n#{page.native.inner_html} \nto contain \"#{key}\" and \"#{value}\""
  end

  failure_message_when_negated do |page|
    "expected \n#{page.native.inner_html} \nnot to contain \"#{key}\" and \"#{value}\""
  end
end

RSpec.describe 'shared/summary/case_details/summary.html.haml' do
  subject(:summary) { 'shared/summary/case_details/summary' }

  let(:page) { Capybara::Node::Simple.new(rendered) }
  let(:date_format) { '%d/%m/%Y' }

  context 'with editable claim' do
    let(:claim) { present(create(:advocate_final_claim, :draft)) }

    before do
      render summary, claim:, editable: true
    end

    it {
      expect(page)
        .to have_govuk_link(text: 'Change',
                            class: 'link-change',
                            href: "/advocates/claims/#{claim.id}/edit?referrer=summary&step=case_details")
    }
  end

  context 'with no mandatory claim details available' do
    let(:claim) { present(create(:advocate_final_claim, :draft)) }

    before { allow(claim).to receive(:mandatory_case_details?).and_return(false) }

    context 'with editable claims' do
      before { render summary, claim:, editable: true }

      it { expect(page).to have_content('There are no case details for this claim') }
    end

    context 'with uneditable claims' do
      before { render summary, claim:, editable: false, section: :case_details }

      it { expect(view).to render_template(partial: 'external_users/claims/summary/_section_status') }
    end
  end

  # rubocop:disable Layout/LineLength
  context 'with AGFS final claim' do
    let(:claim) { present(build(:advocate_final_claim, :draft)) }

    before { render summary, claim: }

    it { expect(page).to have_govuk_section_title(text: 'Case details') }

    context 'with general details available' do
      it { expect(page).to have_govuk_summary_row('Reference number', claim.providers_ref) }
      it { expect(page).to have_govuk_summary_row('Advocate', claim.external_user.name) }
      it { expect(page).to have_govuk_summary_row('Crown court', claim.court.name) }
      it { expect(page).to have_govuk_summary_row('Case number', claim.case_number) }
      it { expect(page).to have_govuk_summary_row('Case type', claim.case_type.name) }
    end

    context 'with transfer court details available' do
      let(:claim) { present(build(:advocate_final_claim, :draft, transfer_court: build(:court, name: 'Blackfriars'), transfer_case_number: 'T20210432')) }

      it { expect(page).to have_govuk_summary_row('Transfer court', 'Blackfriars') }
      it { expect(page).to have_govuk_summary_row('Transfer case number', 'T20210432') }
    end

    context 'with cracked trial case type' do
      let(:claim) { present(build(:advocate_final_claim, :draft, case_type: build(:case_type, :cracked_trial))) }

      it { expect(page).to have_govuk_summary_row('Notice of 1st fixed/warned issued', claim.trial_fixed_notice_at.strftime(date_format)) }
      it { expect(page).to have_govuk_summary_row('1st fixed/warned trial', claim.trial_fixed_at.strftime(date_format)) }
      it { expect(page).to have_govuk_summary_row('Case cracked on', claim.trial_cracked_at.strftime(date_format)) }
      it { expect(page).to have_govuk_summary_row('Case cracked in', claim.trial_cracked_at_third.humanize) }
    end

    context 'with trial case type' do
      let(:claim) { present(build(:advocate_final_claim, :draft, case_type: build(:case_type, :trial))) }

      it { expect(page).to have_govuk_summary_row('First day of trial', claim.first_day_of_trial.strftime(date_format)) }
      it { expect(page).to have_govuk_summary_row('Estimated trial length', claim.estimated_trial_length) }
      it { expect(page).to have_govuk_summary_row('Actual trial length', claim.actual_trial_length) }
      it { expect(page).to have_govuk_summary_row('Trial concluded on', claim.trial_concluded_at.strftime(date_format)) }
    end

    context 'with retrial case type' do
      let(:claim) { present(build(:advocate_final_claim, :draft, case_type: build(:case_type, :retrial))) }

      it { expect(page).to have_govuk_summary_row('First day of trial', claim.first_day_of_trial.strftime(date_format)) }
      it { expect(page).to have_govuk_summary_row('Estimated trial length', claim.estimated_trial_length) }
      it { expect(page).to have_govuk_summary_row('Actual trial length', claim.actual_trial_length) }
      it { expect(page).to have_govuk_summary_row('Trial concluded on', claim.trial_concluded_at.strftime(date_format)) }

      it { expect(page).to have_govuk_summary_row('First day of retrial', claim.retrial_started_at.strftime(date_format)) }
      it { expect(page).to have_govuk_summary_row('Estimated retrial length', claim.retrial_estimated_length) }
      it { expect(page).to have_govuk_summary_row('Actual retrial length', claim.retrial_actual_length) }
      it { expect(page).to have_govuk_summary_row('Retrial concluded on', claim.retrial_concluded_at.strftime(date_format)) }
      it { expect(page).to have_govuk_summary_row('Apply reduced rate to retrial?', 'No') }
    end
  end

  context 'with claims that are lgfs?' do
    let(:claim) { present(build(:litigator_final_claim, :draft)) }

    before { render summary, claim: }

    it { expect(page).to have_govuk_summary_row('Claim creator', claim.creator.name) }
  end

  context 'with claims that requires_case_concluded_date?' do
    let(:claim) { present(build(:litigator_final_claim, :draft)) }

    before { render summary, claim: }

    it { expect(page).to have_govuk_summary_row('Date case concluded', claim.case_concluded_at.strftime(date_format)) }
  end

  context 'with claims that have a case stage' do
    let(:claim) { present(build(:advocate_hardship_claim, :draft)) }

    before do
      # TODO: mock current user instead
      allow(claim).to receive_messages(case_stage: build(:case_stage, description: 'Case stage 101'), display_case_type?: false)
      render summary, claim:
    end

    it { expect(page).to have_govuk_summary_row('Case stage', 'Case stage 101') }
    it { expect(page).not_to have_govuk_summary_row('Case type', claim.case_type.name) }
  end

  context 'with cracked hardship claims' do
    let(:claim) do
      present(
        build(:advocate_hardship_claim, :draft, case_stage: build(:case_stage, :cracked_trial)).tap do |claim|
          claim.trial_fixed_notice_at = Date.current
          claim.trial_fixed_at = Date.current + 2
          claim.trial_cracked_at_third = :first_third
        end
      )
    end

    before do
      allow(claim).to receive(:display_case_type?).and_return(false) # TODO: mock current user instead
      render summary, claim:
    end

    it { expect(page).to have_govuk_summary_row('Case stage', 'After PTPH before trial') }
    it { expect(page).to have_govuk_summary_row('Notice of 1st fixed/warned issued', claim.trial_fixed_notice_at&.strftime(date_format)) }
    it { expect(page).to have_govuk_summary_row('1st fixed/warned trial', claim.trial_fixed_at&.strftime(date_format)) }
    it { expect(page).not_to have_govuk_summary_row('Case cracked on', claim.trial_cracked_at&.strftime(date_format)) }
    it { expect(page).to have_govuk_summary_row('If the case cracked today, which third would it be?', 'First third') }
  end
  # rubocop:enable Layout/LineLength
end
