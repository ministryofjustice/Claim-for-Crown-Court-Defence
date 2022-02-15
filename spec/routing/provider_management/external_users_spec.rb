require 'rails_helper'

RSpec.describe ProviderManagement::ExternalUsersController, type: :routing do
  it 'routes GET /provider_management/providers/:provider_id/external_users to #index' do
    is_expected.to route(:get, '/provider_management/providers/1/external_users').to(action: :index, provider_id: 1)
  end

  it 'routes POST /provider_management/providers/:provider_id/external_users to #create' do
    is_expected.to route(:post, '/provider_management/providers/1/external_users').to(action: :create, provider_id: 1)
  end

  it 'routes GET /provider_management/providers/:provider_id/external_users/new to #new' do
    is_expected.to route(:get, '/provider_management/providers/1/external_users/new').to(action: :new, provider_id: 1)
  end

  it 'routes GET /provider_management/providers/:provider_id/external_users/:id/edit to #edit' do
    is_expected
      .to route(:get, '/provider_management/providers/1/external_users/2/edit')
      .to(action: :edit, provider_id: 1, id: 2)
  end

  it 'routes GET /provider_management/providers/:provider_id/external_users/:id to #show' do
    is_expected
      .to route(:get, '/provider_management/providers/1/external_users/2')
      .to(action: :show, provider_id: 1, id: 2)
  end

  it 'routes PATCH /provider_management/providers/:provider_id/external_users/:id to #update' do
    is_expected
      .to route(:patch, '/provider_management/providers/1/external_users/2')
      .to(action: :update, provider_id: 1, id: 2)
  end

  it 'routes PUT /provider_management/providers/:provider_id/external_users/:id to #update' do
    is_expected
      .to route(:put, '/provider_management/providers/1/external_users/2')
      .to(action: :update, provider_id: 1, id: 2)
  end

  it 'routes GET /provider_management/external_users/find to #find' do
    is_expected.to route(:get, '/provider_management/external_users/find').to(action: :find)
  end

  it 'routes POST /provider_management/external_users/find to #search' do
    is_expected.to route(:post, '/provider_management/external_users/find').to(action: :search)
  end

  it 'routes GET /provider_management/providers/1/external_users/2/change_password to #change_password' do
    is_expected
      .to route(:get, '/provider_management/providers/1/external_users/2/change_password')
      .to(action: :change_password, provider_id: 1, id: 2)
  end

  it 'routes PATCH /provider_management/providers/1/external_users/2/update_password to #update_password' do
    is_expected
      .to route(:patch, '/provider_management/providers/1/external_users/2/update_password')
      .to(action: :update_password, provider_id: 1, id: 2)
  end

  it 'routes PATCH /provider_management/providers/1/external_users/2/disable to #disable' do
    is_expected
      .to route(:patch, '/provider_management/providers/1/external_users/2/disable')
      .to(action: :disable, provider_id: 1, id: 2)
  end

  it 'routes PATCH /provider_management/providers/1/external_users/2/enable to #enable' do
    is_expected
      .to route(:patch, '/provider_management/providers/1/external_users/2/enable')
      .to(action: :enable, provider_id: 1, id: 2)
  end
end
