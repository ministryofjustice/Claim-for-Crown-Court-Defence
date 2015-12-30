# require 'rails_helper'
#
# RSpec.describe SuperAdmins::ChambersController, type: :controller do
#
#   let(:super_admin) { create(:super_admin) }
#   let(:params)      { {name: 'St Johns', supplier_number: '4321'} }
#   let(:chambers)    { create_list(:chamber, 5) }
#   let(:chamber)     { create(:chamber) }
#
#   subject { chamber }
#
#   before { sign_in super_admin.user }
#
#   describe "GET #show" do
#     before { get :show, id: subject }
#
#     it "returns http success" do
#       expect(response).to have_http_status(:success)
#     end
#
#     it 'assigns @chamber' do
#       expect(assigns(:chamber)).to eql(subject)
#     end
#   end
#
#   describe "GET #index" do
#     before { get :index }
#
#     it "returns http success" do
#       expect(response).to have_http_status(:success)
#     end
#
#     it 'assigns @chambers to ALL chambers' do
#       chambers.each do |chamber|
#         expect(assigns(:chambers)).to include(chamber)
#       end
#     end
#
#   end
#
#   describe "GET #edit" do
#     before { get :edit, id: subject}
#
#     it "returns http success" do
#       expect(response).to have_http_status(:success)
#     end
#
#     it 'assigns @chamber' do
#       expect(assigns(:chamber)).to eql(subject)
#     end
#
#   end
#
#   describe "PUT #update" do
#     before { subject.update(supplier_number: 'AB123') }
#
#     context 'when valid' do
#       before(:each) { put :update, id: subject, chamber: { supplier_number: 'XY123' } }
#
#       it 'updates successfully' do
#         subject.reload
#         expect(subject.reload.supplier_number).to eq('XY123')
#       end
#
#       it 'redirects to chambers show page' do
#         expect(response).to redirect_to(super_admins_chamber_path(subject))
#       end
#     end
#
#     context 'when invalid' do
#       before(:each) { put :update, id: subject, chamber: { supplier_number: '' } }
#
#       it 'does not update chamber' do
#         subject.reload
#         expect(subject.supplier_number).to eq('AB123')
#       end
#
#       it 'renders the edit template' do
#         expect(response).to render_template(:edit)
#       end
#     end
#   end
#
#   describe "GET #new" do
#     before { get :new }
#
#     it 'returns http succes' do
#       expect(response).to have_http_status(:success)
#     end
#
#     it "assigns a new chamber to @chamber" do
#       expect(assigns(:chamber)).to be_a_new(Chamber)
#     end
#   end
#
#   describe "POST #create" do
#     before(:each) do
#       post :create, chamber: params
#     end
#
#     it "creates a new chamber" do
#       expect(flash[:notice]).to eq 'Chamber successfully created'
#     end
#
#     it 'redirects to index' do
#       expect(response).to redirect_to(super_admins_root_path)
#     end
#
#   end
#
# end
