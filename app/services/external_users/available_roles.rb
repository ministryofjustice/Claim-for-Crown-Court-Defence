module ExternalUsers
  class AvailableRoles
    def self.call(external_user)
      provider = external_user.provider
      return %w( admin ) if provider.nil?

      if provider.agfs? && provider.lgfs?
        %w( admin advocate litigator )
      elsif provider.agfs?
        %w( admin advocate )
      elsif provider.lgfs?
        %w( admin litigator )
      else
        raise "Provider has no valid roles available: #{Provider::ROLES.join(', ')}"
      end
    end
  end
end
