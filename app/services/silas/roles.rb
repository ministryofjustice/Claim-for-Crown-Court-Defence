module Silas
  class Roles
    class NoApplicableRoles < StandardError; end
    class MixedPersonaRoles < StandardError; end

    INTERNAL_ROLE_MAPPINGS = {
      'Caseworker' => 'case_worker',
      'Provider Management' => 'provider_management',
      'LAA Administrator' => 'admin',
      'Beta Tester' => 'beta_tester'
    }.freeze

    EXTERNAL_ROLE_MAPPINGS = {
      'Advocate' => 'advocate',
      'Litigator' => 'litigator',
      'Advocate Admin' => 'admin',
      'Litigator Admin' => 'admin',
      'Administrator' => 'admin'
    }.freeze

    SUPER_ADMIN_ROLE = 'Super Administrator'.freeze
    NO_APPLICABLE_ROLES_MESSAGE = 'No applicable roles found in LAA_ROLES'.freeze

    def initialize(raw)
      @roles_supplied = raw.key?('LAA_ROLES')
      @laa_roles = Array(raw['LAA_ROLES']).map { |role| role.to_s.strip }.reject(&:empty?)
    end

    delegate :empty?, to: :laa_roles

    def case_worker_roles
      mapped_roles(INTERNAL_ROLE_MAPPINGS, CaseWorker::ROLES)
    end

    def case_worker_roles!
      roles = case_worker_roles
      raise NoApplicableRoles, NO_APPLICABLE_ROLES_MESSAGE if (roles - ['beta_tester']).empty?

      roles
    end

    def external_user_roles
      mapped_roles(EXTERNAL_ROLE_MAPPINGS, ExternalUser::ROLES)
    end

    def persona_type
      return SuperAdmin.name if laa_roles.include?(SUPER_ADMIN_ROLE)
      return ExternalUser.name if external_user_roles.any?
      return CaseWorker.name if case_worker_roles.any?

      nil
    end

    def validate_super_admin!
      validate_claims!

      raise NoApplicableRoles, NO_APPLICABLE_ROLES_MESSAGE unless laa_roles.include?(SUPER_ADMIN_ROLE)
    end

    def sync!(user)
      return unless user.case_worker? || user.external_user?

      validate_claims!

      mapped = roles_for(user)
      raise NoApplicableRoles, NO_APPLICABLE_ROLES_MESSAGE if mapped.empty?

      return if Array(user.persona.roles).map(&:to_s).sort == mapped.sort

      user.persona.update!(roles: mapped)
    end

    private

    attr_reader :laa_roles, :roles_supplied

    def validate_claims!
      raise NoApplicableRoles, NO_APPLICABLE_ROLES_MESSAGE unless roles_supplied
      return if case_worker_roles.empty? || external_user_roles.empty?

      raise MixedPersonaRoles, 'Both internal and external roles found in LAA_ROLES'
    end

    def mapped_roles(mapping, valid_roles)
      laa_roles.filter_map { |role| mapping[role] } & valid_roles
    end

    def roles_for(user)
      return case_worker_roles! if user.case_worker?
      return external_user_roles & user.persona.available_roles if user.external_user?

      []
    end
  end
end
