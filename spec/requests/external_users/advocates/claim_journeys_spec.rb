require 'rails_helper'

RSpec.describe 'Claim journeys' do
  context 'when at the defendants page' do
    subject(:submit_defendants_update) { put advocates_claim_path(claim.id), params: defendants_params }

    let(:claim) { create(:draft_claim, external_user: advocate) }
    let(:advocate) { create(:external_user, :advocate) }

    context 'when on case_details form step' do
      let(:defendants_params) do
        {
          'id' => claim.id,
          'commit_continue' => '',
          'claim' => {
            'form_id' => SecureRandom.uuid, # not actually needed for test
            'form_step' => 'defendants',
            'defendants_attributes' => {
              '0' => {
                'first_name' => 'Fred',
                'last_name' => 'Bloggs',
                'date_of_birth(3i)' => '1',
                'date_of_birth(2i)' => '1',
                'date_of_birth(1i)' => '1970',
                'order_for_judicial_appointment' => '0',
                'representation_orders_attributes' => representation_orders_attributes
              }
            }
          }
        }
      end

      before do
        sign_in advocate.user
        claim.defendants = []
        claim.save
      end

      context 'when setting two representation orders to the defendant in the correct chronological order' do
        let(:representation_orders_attributes) do
          {
            '0' => {
              'representation_order_date(3i)' => '4',
              'representation_order_date(2i)' => '4',
              'representation_order_date(1i)' => '2023',
              'maat_reference' => '9876543'
            },
            '1' => {
              'representation_order_date(3i)' => '5',
              'representation_order_date(2i)' => '5',
              'representation_order_date(1i)' => '2023',
              'maat_reference' => '9876542'
            }
          }
        end

        it do
          submit_defendants_update
          expect(response).to redirect_to edit_polymorphic_path(claim, step: 'offence_details')
        end

        it do
          expect { submit_defendants_update }.to change(claim.defendants, :count).from(0).to(1)
        end

        it do
          expect { submit_defendants_update }
            .to change { Claim::BaseClaim.find(claim.id).defendants.first&.representation_orders&.count }
            .from(nil).to(2)
        end
      end

      context 'when setting two representation orders to the defendant in the wrong chronological order' do
        let(:representation_orders_attributes) do
          {
            '0' => {
              'representation_order_date(3i)' => '4',
              'representation_order_date(2i)' => '4',
              'representation_order_date(1i)' => '2023',
              'maat_reference' => '9876543'
            },
            '1' => {
              'representation_order_date(3i)' => '3',
              'representation_order_date(2i)' => '3',
              'representation_order_date(1i)' => '2023',
              'maat_reference' => '9876542'
            }
          }
        end

        it do
          submit_defendants_update
          expect(response).to be_successful
        end

        it do
          expect { submit_defendants_update }.not_to change(claim.defendants, :count).from(0)
        end
      end
    end
  end
end
