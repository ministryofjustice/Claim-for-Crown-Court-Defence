require 'rails_helper'

RSpec.describe ClaimCsvPresenter do

  let(:provider)            { double 'provider', name: 'Firm One' }
  let(:external_user)       { double 'external_user', supplier_number: '0P235X', provider: provider}
  let(:case_type)           { double 'case_type', name: 'Discontinuance' }
  let(:last_submitted_at)   { Timecop.freeze(Time.now - 3.day) }
  let(:allocated_at)        { Timecop.freeze(Time.now - 2.day) }
  let(:assessed_at)         { Timecop.freeze(Time.now - 1.day) }
  let(:allocated_changeset) { {'state' => ['submitted', 'allocated']} }
  let(:assessed_changeset)  { {'state' => ['allocated', 'refused']} }
  let(:allocated_version)   { double 'version', changeset: allocated_changeset, created_at: allocated_at}
  let(:assessed_version)    { double 'version', changeset: assessed_changeset, created_at: assessed_at}
  let(:versions)            { [allocated_version, assessed_version] }
  let(:claim)               { double 'claim', case_number: 'A12345678', external_user: external_user, case_type: case_type, total: BigDecimal.new(100), state: 'submitted', last_submitted_at: last_submitted_at, versions: versions, redetermination?: false, awaiting_written_reasons?: false, opened_for_redetermination?: true}
  let(:subject)             { ClaimCsvPresenter.new(claim, view) }

  context '#present! generates csv that contains' do

    it 'case_number' do
      expect(subject.present!).to include(claim.case_number)
    end

    it 'account number' do
      expect(subject.present!).to include(external_user.supplier_number)
    end

    it 'organistion/provider_name' do
      expect(subject.present!).to include(provider.name)
    end

    it 'date last submitted' do
      expect(subject.present!).to include(claim.last_submitted_at)
    end

    it 'case_type' do
      expect(subject.present!).to include(case_type.name)
    end

    it 'total (ex VAT)' do
      expect(subject.present!).to include(claim.total.to_s)
    end

    it 'caseworker-relent state' do
      expect(subject.present!).to include(claim.state)
    end

    it 'allocation date' do      
      expect(subject.present!).to include(allocated_at.to_s)
    end

    it 'allocation type (as per allocation tool filters)' do
      expect(subject.present!).to include('Redetermination')
    end

    it 'date of last assessment' do
      expect(subject.present!).to include(assessed_at.to_s)
    end

  end

end
