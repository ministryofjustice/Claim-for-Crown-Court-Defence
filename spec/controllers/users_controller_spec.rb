# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  persona_id             :integer
#  persona_type           :string
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string
#  last_name              :string
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#  unlock_token           :string
#  settings               :text
#  deleted_at             :datetime
#  api_key                :uuid
#

require 'rails_helper'

RSpec.describe UsersController do
  describe 'PUT #update_settings' do
    let(:external_user) { create(:external_user) }
    let(:user) { external_user.user }

    before do
      sign_in user
      expect(user.settings).to eq({})
    end

    def do_put(params = {})
      put :update_settings, params: params.merge(id: user, format: :js)
      user.reload
    end

    it 'can update the api_promo_seen setting' do
      do_put(api_promo_seen: 'test')
      expect(assigns(:settings).to_h).to eq({ 'api_promo_seen' => 'test' })
      expect(user.settings).to eq({ 'api_promo_seen' => 'test' })
    end

    it 'can update the timed_retention_banner_seen setting' do
      do_put(timed_retention_banner_seen: 'test')
      expect(assigns(:settings).to_h).to eq({ 'timed_retention_banner_seen' => 'test' })
      expect(user.settings).to eq({ 'timed_retention_banner_seen' => 'test' })
    end

    it 'can update the hardship_claims_banner_seen setting' do
      do_put(hardship_claims_banner_seen: 'test')
      expect(assigns(:settings).to_h).to eq({ 'hardship_claims_banner_seen' => 'test' })
      expect(user.settings).to eq({ 'hardship_claims_banner_seen' => 'test' })
    end

    it 'can update the clair_contingency_banner_seen setting' do
      do_put(clair_contingency_banner_seen: 'test')
      expect(assigns(:settings).to_h).to eq({ 'clair_contingency_banner_seen' => 'test' })
      expect(user.settings).to eq({ 'clair_contingency_banner_seen' => 'test' })
    end

    it 'can update the out_of_hours_banner_seen setting' do
      do_put(out_of_hours_banner_seen: 'test')
      expect(assigns(:settings).to_h).to eq({ 'out_of_hours_banner_seen' => 'test' })
      expect(user.settings).to eq({ 'out_of_hours_banner_seen' => 'test' })
    end
  end
end
