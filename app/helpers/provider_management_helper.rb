# frozen_string_literal: true

# helpers for the provider manager views
#
module ProviderManagementHelper
  def account_status(external_user)
    [
      external_user.active? ? t('provider_management_helper.live') : t('provider_management_helper.inactive'),
      external_user.enabled? ? t('provider_management_helper.enabled') : t('provider_management_helper.disabled')
    ].join(', ')
  end

  def availability_page_title(external_user)
    if external_user.enabled?
      t('provider_management_helper.disable.page_title', external_user: external_user.name)
    else
      t('provider_management_helper.enable.page_title', external_user: external_user.name)
    end
  end

  def availability_heading(external_user)
    if external_user.enabled?
      t('provider_management_helper.disable.heading', external_user: external_user.name)
    else
      t('provider_management_helper.enable.heading', external_user: external_user.name)
    end
  end

  def availability_submit(external_user, form:)
    if external_user.enabled?
      form.govuk_submit(t('provider_management_helper.disable.submit'), class: 'govuk-button--warning')
    else
      form.govuk_submit(t('provider_management_helper.enable.submit'))
    end
  end
end
