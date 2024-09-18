require 'rails_helper'

RSpec.describe CourtData do
  subject(:court_data) { described_class.new(claim_id: claim.id) }

  let(:claim) do
    create(:claim, case_number: 'TEST12345', create_defendant_and_rep_order: false, defendants: claim_defendants)
  end
  let(:claim_defendants) { [] }

  before do
    search_data.each do |search|
      allow(LAA::Cda::ProsecutionCase).to receive(:search).with(**search[:params]).and_return(search[:response])
    end
  end

  describe '#case_number' do
    subject { court_data.case_number }

    context 'with a matching case number in Common Platform' do
      let(:search_data) do
        [
          {
            params: { prosecution_case_reference: 'TEST12345' },
            response: [instance_double(LAA::Cda::ProsecutionCase, case_number: 'TEST12345')]
          }
        ]
      end

      it { is_expected.to match(hash_including(hmcts: 'TEST12345', claim: 'TEST12345')) }
    end

    context 'when there is no case number in Common Platform but there is a matching defendant' do
      let(:search_data) do
        [
          {
            params: { prosecution_case_reference: 'TEST12345' },
            response: []
          },
          {
            params: { name: 'Zaphod Beeblebrox', date_of_birth: Date.parse('2000-01-01') },
            response: []
          },
          {
            params: { name: 'Arthur Raffles', date_of_birth: Date.parse('1939-08-17') },
            response: [instance_double(LAA::Cda::ProsecutionCase, case_number: 'TEST12345')]
          }
        ]
      end
      let(:claim_defendants) do
        [
          create(:defendant, first_name: 'Zaphod', last_name: 'Beeblebrox', date_of_birth: Date.parse('2000-01-01')),
          create(:defendant, first_name: 'Arthur', last_name: 'Raffles', date_of_birth: Date.parse('1939-08-17'))
        ]
      end

      it { is_expected.to match(hash_including(hmcts: 'TEST12345', claim: 'TEST12345')) }
    end
  end

  describe '#status' do
    subject { court_data.status }

    context 'with a matching case number in Common Platform' do
      let(:search_data) do
        [
          {
            params: { prosecution_case_reference: 'TEST12345' },
            response: [instance_double(LAA::Cda::ProsecutionCase, status: 'INACTIVE')]
          }
        ]
      end

      it { is_expected.to match(hash_including(hmcts: 'INACTIVE')) }
    end

    context 'when there is no case number in Common Platform' do
      let(:search_data) do
        [
          {
            params: { prosecution_case_reference: 'TEST12345' },
            response: []
          }
        ]
      end

      it { is_expected.to match(hash_including(hmcts: nil)) }
    end
  end

  describe '#defendants' do
    subject { court_data.defendants }

    let(:claim_defendants) do
      [
        create(:defendant, first_name: 'Arthur', last_name: 'Raffles'),
        create(:defendant, first_name: 'Hawley', last_name: 'Crippen')
      ]
    end

    context 'when there is no case number in Common Platform' do
      let(:search_data) do
        [
          {
            params: { prosecution_case_reference: 'TEST12345' },
            response: []
          },
          {
            params: { name: kind_of(String), date_of_birth: kind_of(Date) },
            response: []
          }
        ]
      end

      it do
        is_expected.to match_array(claim_defendants.map do |defendant|
          hash_including(maat_reference: defendant.earliest_representation_order.maat_reference, hmcts: nil,
                         claim: hash_including(name: defendant.name))
        end)
      end
    end

    context 'when the defendant in Common Platform does not match' do
      let(:search_data) do
        [
          {
            params: { prosecution_case_reference: 'TEST12345' },
            response: [
              instance_double(
                LAA::Cda::ProsecutionCase,
                defendants: [
                  instance_double(
                    LAA::Cda::Defendant,
                    id: '12345',
                    name: 'Billy The Kid',
                    representation_order: instance_double(
                      LAA::Cda::RepresentationOrder,
                      reference: '9999999',
                      start: Date.parse('2024-05-05'),
                      end: Date.parse('2024-05-06'),
                      contract_number: 'AA111'
                    )
                  )
                ]
              )
            ]
          }
        ]
      end

      it do
        is_expected.to contain_exactly(
          *claim_defendants.map do |defendant|
            hash_including(maat_reference: defendant.earliest_representation_order.maat_reference, hmcts: nil,
                           claim: hash_including(name: defendant.name))
          end,
          hash_including(maat_reference: '9999999', hmcts: hash_including(name: 'Billy The Kid'), claim: nil)
        )
      end
    end

    context 'when the defendant in Common Platform has a matching MAAT reference' do
      let(:search_data) do
        [
          {
            params: { prosecution_case_reference: 'TEST12345' },
            response: [
              instance_double(
                LAA::Cda::ProsecutionCase,
                defendants: [
                  instance_double(
                    LAA::Cda::Defendant,
                    id: '12345',
                    name: 'Hawley Harvey Crippen',
                    representation_order: instance_double(
                      LAA::Cda::RepresentationOrder,
                      reference: claim_defendants[1].earliest_representation_order.maat_reference,
                      start: Date.parse('2024-05-05'),
                      end: Date.parse('2024-05-06'),
                      contract_number: 'AA111'
                    )
                  )
                ]
              )
            ]
          }
        ]
      end

      it do
        is_expected.to contain_exactly(
          hash_including(
            maat_reference: claim_defendants[0].earliest_representation_order.maat_reference,
            hmcts: nil,
            claim: hash_including(name: 'Arthur Raffles')
          ),
          hash_including(
            maat_reference: claim_defendants[1].earliest_representation_order.maat_reference,
            hmcts: hash_including(name: 'Hawley Harvey Crippen'),
            claim: hash_including(name: 'Hawley Crippen')
          )
        )
      end
    end

    context 'with multiple defendants in Common Platform with no MAAT reference' do
      let(:search_data) do
        [
          {
            params: { prosecution_case_reference: 'TEST12345' },
            response: [
              instance_double(
                LAA::Cda::ProsecutionCase,
                defendants: [
                  instance_double(
                    LAA::Cda::Defendant,
                    id: '12345',
                    name: 'Hawley Harvey Crippen',
                    representation_order: nil
                  ),
                  instance_double(
                    LAA::Cda::Defendant,
                    id: '12346',
                    name: 'Arthur Justice Raffles',
                    representation_order: nil
                  )
                ]
              )
            ]
          }
        ]
      end

      it do
        is_expected.to contain_exactly(
          *claim_defendants.map do |defendant|
            hash_including(maat_reference: defendant.earliest_representation_order.maat_reference, hmcts: nil,
                           claim: hash_including(name: defendant.name))
          end,
          hash_including(
            maat_reference: 'No representation order recorded',
            hmcts: hash_including(name: 'Hawley Harvey Crippen')
          ),
          hash_including(
            maat_reference: 'No representation order recorded',
            hmcts: hash_including(name: 'Arthur Justice Raffles')
          )
        )
      end
    end
  end
end
