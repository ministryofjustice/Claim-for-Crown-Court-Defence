class ExternalUsers::RegistrationsController < Devise::RegistrationsController
  skip_load_and_authorize_resource only: [:new, :create]
  before_action :check_environment
  before_action :configure_permitted_parameters, only: [:create]

  def create
    unless params[:terms_and_conditions_acceptance] == '1'
      return redirect_to new_user_registration_url, alert: 'You must accept the terms and conditions before continuing'
    end

    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      create_external_user
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  private

  def check_environment
    redirect_to external_users_root_url unless Rails.host.api_sandbox?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up).push(:first_name, :last_name)
  end

  def create_external_user
    highest_sup_no = SupplierNumber.last&.id || 1
    provider = Provider.create!(
      name: Faker::Company.name,
      firm_agfs_supplier_number: generate_unique_supplier_number,
      provider_type: 'firm',
      roles: ['agfs', 'lgfs'],
      lgfs_supplier_numbers: [ SupplierNumber.new(supplier_number: sprintf('9X%03dX', highest_sup_no)) ]
    )
    external_user = ExternalUser.new(
      provider: provider,
      roles: ['admin'],
      supplier_number: generate_unique_supplier_number
    )
    external_user.user = resource
    external_user.save!
  end

  def generate_unique_supplier_number
    alpha_part = ""
    2.times{alpha_part  << (65 + rand(25)).chr}
    numeric_part = rand(999)
    "#{alpha_part}#{sprintf('%03d', numeric_part)}"
  end
end
