module ExternalUsers
  class MultiFirmUserLinksController < ApplicationController
    skip_load_and_authorize_resource
    before_action :require_multi_firm_user

    def show
      prepare_page
    end

    def create
      @linker = MultiFirmUserLinker.new(user: current_user, **link_params.to_h.symbolize_keys)
      return redirect_to external_users_multi_firm_user_links_path, notice: t('.notice') if @linker.save

      @links = current_user.multi_firm_user_links.includes(linked_user: :persona)
      render :show, status: :unprocessable_content
    end

    def destroy
      current_user.multi_firm_user_links.find(params.expect(:id)).destroy!
      redirect_to external_users_multi_firm_user_links_path, notice: t('.notice')
    end

    private

    def prepare_page
      @links = current_user.multi_firm_user_links.includes(linked_user: :persona)
      @linker = MultiFirmUserLinker.new(user: current_user)
    end

    def link_params
      params.expect(multi_firm_user_linker: %i[email password])
    end

    def require_multi_firm_user
      return if current_user.multi_firm_user?

      redirect_to edit_external_users_admin_external_user_path(current_user.persona),
                  alert: t('external_users.multi_firm_user_links.multi_firm_user_required')
    end
  end
end
