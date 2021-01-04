require 'rails_helper'

RSpec.describe ExternalUsers::Advocates::InterimClaimsController, type: :controller do
  let(:resource_klass) { Claim::AdvocateInterimClaim }
  let(:unauthorized_user) { create(:external_user, :litigator) }
  let(:authorized_user) { create(:external_user, :advocate) }

  def create_claim(*args)
    claim = build(*args)
    claim.save
    claim.reload
  end

  describe 'GET #new' do
    subject(:new_request) { get :new }

    context 'when the user in NOT authenticated' do
      it 'redirects the user to the login page' do
        new_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq('Must be signed in as an advocate, litigator or admin user')
      end
    end

    context 'when the user is authenticated' do
      context 'but the user is not authorized to manage this claim type' do
        before do
          sign_in(unauthorized_user.user)
        end

        it 'redirects the user to its home page with an unauthorised error' do
          new_request
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(external_users_root_path)
          expect(flash[:alert]).to eq('Unauthorised')
        end
      end

      context 'and the user is authorized to manage this claim type' do
        before do
          sign_in(authorized_user.user)
        end

        it 'assigns @claim is an instance of the defined claim type' do
          new_request
          expect(assigns(:claim)).to be_new_record
          expect(assigns(:claim)).to be_instance_of(resource_klass)
        end

        it 'renders the template' do
          new_request
          expect(response).to be_successful
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe 'POST #create' do
    let(:court) { create(:court) }
    let(:form_action) { { commit_continue: 'Save and continue' } }
    let(:claim_params) {
      {
        form_step: 'case_details',
        court_id: court.id,
        case_number: 'A20161234',
        case_transferred_from_another_court: 'false'
      }
    }
    let(:params) { { claim: claim_params }.merge(form_action) }

    subject(:create_request) { post :create, params: params }

    context 'when the user in NOT authenticated' do
      it 'redirects the user to the login page' do
        create_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq('Must be signed in as an advocate, litigator or admin user')
      end

      it 'does not create a claim record' do
        expect { create_request }.not_to change { resource_klass.count }
      end
    end

    context 'when the user is authenticated' do
      context 'but the user is not authorized to manage this claim type' do
        before do
          sign_in(unauthorized_user.user)
        end

        it 'redirects the user to its home page with an unauthorised error' do
          create_request
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(external_users_root_path)
          expect(flash[:alert]).to eq('Unauthorised')
        end

        it 'does not create a claim record' do
          expect { create_request }.not_to change { resource_klass.count }
        end
      end

      context 'and the user is authorized to manage this claim type' do
        before do
          sign_in(authorized_user.user)
        end

        context 'but the submitted claim params are invalid' do
          let(:claim_params) {
            {
              form_step: 'case_details',
              court_id: '',
              case_number: '',
              case_transferred_from_another_court: 'false'
            }
          }

          context 'and the form params were submitted as a draft' do
            let(:form_action) { { commit_save_draft: 'Save as draft' } }

            it 'assigns @claim with the newly created record' do
              create_request
              expect(assigns(:claim)).not_to be_new_record
              expect(assigns(:claim)).to be_instance_of(resource_klass)
            end

            it 'redirects to claims list page' do
              create_request
              expect(response).to redirect_to(external_users_claims_path)
            end

            it 'creates a new claim record as draft with the submitted data' do
              expect { create_request }.to change { resource_klass.count }.by(1)
              new_claim = resource_klass.active.first
              expect(new_claim).to be_draft
              expect(new_claim.external_user).to eq(authorized_user)
              expect(new_claim.creator).to eq(authorized_user)
            end
          end

          context 'and the form params were submitted to LAA' do
            let(:form_action) { { commit_submit_claim: 'Submit to LAA' } }

            it 'assigns @claim with errors' do
              create_request
              expect(assigns(:claim)).to be_new_record
              expect(assigns(:claim)).to be_instance_of(resource_klass)
              expect(assigns(:claim).errors).not_to be_empty
            end

            it 'renders the template' do
              create_request
              expect(response).to be_successful
              expect(response).to render_template(:new)
            end

            it 'does not create a claim record' do
              expect { create_request }.not_to change { resource_klass.count }
            end
          end

          it 'assigns @claim with errors' do
            create_request
            expect(assigns(:claim)).to be_new_record
            expect(assigns(:claim)).to be_instance_of(resource_klass)
            expect(assigns(:claim).errors).not_to be_empty
          end

          it 'renders the template' do
            create_request
            expect(response).to be_successful
            expect(response).to render_template(:new)
          end

          it 'does not create a claim record' do
            expect { create_request }.not_to change { resource_klass.count }
          end
        end

        context 'and the form params were submitted to LAA' do
          let(:form_action) { { commit_submit_claim: 'Submit to LAA' } }

          it 'assigns @claim with the newly created record' do
            create_request
            expect(assigns(:claim)).not_to be_new_record
            expect(assigns(:claim)).to be_instance_of(resource_klass)
          end

          it 'redirects user to the claim summary page' do
            create_request
            expect(response).to redirect_to(summary_external_users_claim_path(assigns(:claim)))
          end

          it 'creates a new claim record with the submitted data' do
            expect { create_request }.to change { resource_klass.count }.by(1)
            new_claim = resource_klass.active.first
            expect(new_claim).to be_draft
            expect(new_claim.external_user).to eq(authorized_user)
            expect(new_claim.creator).to eq(authorized_user)
          end
        end

        it 'assigns @claim with the newly created record' do
          create_request
          expect(assigns(:claim)).not_to be_new_record
          expect(assigns(:claim)).to be_instance_of(resource_klass)
        end

        it 'redirects the user to the next step of the claim edit form page' do
          create_request
          expect(response).to redirect_to(edit_advocates_interim_claim_path(assigns(:claim), step: :defendants))
        end

        it 'creates a new claim record with the submitted data' do
          expect { create_request }.to change { resource_klass.count }.by(1)
          new_claim = resource_klass.active.first
          expect(new_claim).to be_draft
          expect(new_claim.external_user).to eq(authorized_user)
          expect(new_claim.creator).to eq(authorized_user)
        end
      end
    end
  end

  describe 'GET #edit' do
    let(:claim) { create(:advocate_interim_claim, external_user: authorized_user, creator: authorized_user) }

    subject(:edit_request) { get :edit, params: { id: claim.id } }

    context 'when the user in NOT authenticated' do
      it 'redirects the user to the login page' do
        edit_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq('Must be signed in as an advocate, litigator or admin user')
      end
    end

    context 'when the user is authenticated' do
      context 'but the user is not authorized to manage this claim type' do
        before do
          sign_in(unauthorized_user.user)
        end

        it 'redirects the user to its home page with an unauthorised error' do
          edit_request
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(external_users_root_path)
          expect(flash[:alert]).to eq('Unauthorised')
        end
      end

      context 'and the user is authorized to manage this claim type' do
        before do
          sign_in(authorized_user.user)
        end

        context 'but the user is not the creator of the claim' do
          let(:other_authorized_user) { create(:external_user, :advocate) }
          let(:claim) { create_claim(:advocate_interim_claim, external_user: other_authorized_user, creator: other_authorized_user) }

          it 'redirects the user to its home page with an unauthorised error' do
            edit_request
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(external_users_root_path)
            expect(flash[:alert]).to eq('Unauthorised')
          end
        end

        context 'but the claim is not longer editable' do
          # TODO: there seems to be problems with the factories which previously allowed claims to be in submitted state without the
          # necessary valid information. Needs looking at!
          let!(:claim) { create_claim(:advocate_interim_claim, :submitted, external_user: authorized_user, creator: authorized_user).tap { |c| c.submit! } }

          it 'redirects the user to its home page with an unauthorised error' do
            edit_request
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(external_users_claims_path)
            expect(flash[:alert]).to eq('Can only edit "draft" claims')
          end
        end

        it 'assigned @claim is an instance of the defined claim type' do
          edit_request
          expect(assigns(:claim)).not_to be_new_record
          expect(assigns(:claim)).to be_instance_of(resource_klass)
        end

        it 'renders the template' do
          edit_request
          expect(response).to be_successful
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe 'PUT #update' do
    let(:original_case_number) { 'A20161234' }
    let(:original_court) { create(:court) }
    let!(:claim) { create(:advocate_interim_claim, external_user: authorized_user, creator: authorized_user, case_number: original_case_number, court: original_court) }
    let(:court) { create(:court) }
    let(:case_number) { 'A20171445' }
    let(:form_action) { { commit_continue: 'Save and continue' } }
    let(:claim_params) {
      {
        form_step: 'case_details',
        court_id: court.id,
        case_number: case_number,
        case_transferred_from_another_court: 'false'
      }
    }
    let(:params) { { id: claim.id, claim: claim_params }.merge(form_action) }

    subject(:update_request) { put :update, params: params }

    context 'when the user in NOT authenticated' do
      it 'redirects the user to the login page' do
        update_request
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq('Must be signed in as an advocate, litigator or admin user')
      end

      it 'does not update the existent claim record' do
        expect { update_request }.not_to change { claim.reload }
      end
    end

    context 'when the user is authenticated' do
      context 'but the user is not authorized to manage this claim type' do
        before do
          sign_in(unauthorized_user.user)
        end

        it 'redirects the user to its home page with an unauthorised error' do
          update_request
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(external_users_root_path)
          expect(flash[:alert]).to eq('Unauthorised')
        end

        it 'does not update the existent claim record' do
          expect { update_request }.not_to change { claim.reload }
        end
      end

      context 'and the user is authorized to manage this claim type' do
        before do
          sign_in(authorized_user.user)
        end

        context 'but the user is not the creator of the claim' do
          let(:other_authorized_user) { create(:external_user, :advocate) }
          let!(:claim) { create(:advocate_interim_claim, external_user: other_authorized_user, creator: other_authorized_user) }

          it 'redirects the user to its home page with an unauthorised error' do
            update_request
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(external_users_root_path)
            expect(flash[:alert]).to eq('Unauthorised')
          end

          it 'does not update the existent claim record' do
            expect { update_request }.not_to change { claim.reload }
          end
        end

        context 'but the claim is not longer editable' do
          # TODO: there seems to be problems with the factories which previously allowed claims to be in submitted state without the
          # necessary valid information. Needs looking at!
          let!(:claim) { create_claim(:advocate_interim_claim, :submitted, external_user: authorized_user, creator: authorized_user).tap { |c| c.submit! } }

          it 'redirects the user to its home page with an unauthorised error' do
            update_request
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to(external_users_claims_path)
            expect(flash[:alert]).to eq('Can only edit "draft" claims')
          end

          it 'does not update the existent claim record' do
            expect { update_request }.not_to change { claim.reload }
          end
        end

        context 'but the submitted claim params are invalid' do
          let(:claim_params) {
            {
              form_step: 'case_details',
              court_id: '',
              case_number: '',
              case_transferred_from_another_court: 'false'
            }
          }

          context 'and the form params were submitted as a draft' do
            let(:form_action) { { commit_save_draft: 'Save as draft' } }

            it 'assigns @claim with the existent updated record' do
              update_request
              expect(assigns(:claim).id).to eq(claim.id)
              expect(assigns(:claim)).to be_instance_of(resource_klass)
            end

            it 'redirects to claims list page' do
              update_request
              expect(response).to redirect_to(external_users_claims_path)
            end

            it 'updates the existent claim record as draft with the submitted data' do
              expect { update_request }.to change {
                [
                  claim.reload.court_id,
                  claim.reload.case_number
                ]
              }.from([original_court.id, original_case_number]).to([nil, nil])
            end
          end

          context 'and the form params were submitted to LAA' do
            let(:form_action) { { commit_submit_claim: 'Submit to LAA' } }

            it 'assigns @claim with errors' do
              update_request
              expect(assigns(:claim).id).to eq(claim.id)
              expect(assigns(:claim)).to be_instance_of(resource_klass)
              expect(assigns(:claim).errors).not_to be_empty
            end

            it 'renders the template' do
              update_request
              expect(response).to be_successful
              expect(response).to render_template(:edit)
            end

            it 'does not update the existent claim record' do
              expect { update_request }.not_to change {
                [
                  claim.reload.court_id,
                  claim.reload.case_number
                ]
              }.from([original_court.id, original_case_number])
            end
          end

          it 'assigns @claim with errors' do
            update_request
            expect(assigns(:claim).id).to eq(claim.id)
            expect(assigns(:claim)).to be_instance_of(resource_klass)
            expect(assigns(:claim).errors).not_to be_empty
          end

          it 'renders the template' do
            update_request
            expect(response).to be_successful
            expect(response).to render_template(:edit)
          end

          it 'does not update the existent claim record' do
            expect { update_request }.not_to change {
              [
                claim.reload.court_id,
                claim.reload.case_number
              ]
            }.from([original_court.id, original_case_number])
          end
        end

        context 'and the form params were submitted to LAA' do
          let(:form_action) { { commit_submit_claim: 'Submit to LAA' } }

          it 'assigns @claim with the existent updated record' do
            update_request
            expect(assigns(:claim).id).to eq(claim.id)
            expect(assigns(:claim)).to be_instance_of(resource_klass)
          end

          it 'redirects user to the claim summary page' do
            update_request
            expect(response).to redirect_to(summary_external_users_claim_path(assigns(:claim)))
          end

          it 'updates the existent claim record with the submitted data' do
            expect { update_request }.to change {
              [
                claim.reload.court_id,
                claim.reload.case_number
              ]
            }.from([original_court.id, original_case_number]).to([court.id, case_number])
          end
        end

        it 'assigns @claim with the newly created record' do
          update_request
          expect(assigns(:claim)).not_to be_new_record
          expect(assigns(:claim)).to be_instance_of(resource_klass)
        end

        it 'redirects the user to the next step of the edit claim form page' do
          update_request
          expect(response).to redirect_to(edit_advocates_interim_claim_path(assigns(:claim), step: :defendants))
        end

        it 'updates the existent claim record with the submitted data' do
          expect { update_request }.to change {
            [
              claim.reload.court_id,
              claim.reload.case_number
            ]
          }.from([original_court.id, original_case_number]).to([court.id, case_number])
        end
      end
    end
  end
end
