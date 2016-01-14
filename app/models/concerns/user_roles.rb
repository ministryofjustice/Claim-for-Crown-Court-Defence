module UserRoles
  extend ActiveSupport::Concern

  included do |klass|
    klass.serialize :roles, Array
    klass.before_validation :strip_empty_role
    klass.validate :roles_valid

    klass::ROLES.each do |role|
      klass.scope role.pluralize.to_sym, -> { klass.select { |m| m.roles.include?(role) } }

      define_method "#{role}?" do
        is?(role)
      end
    end
  end

  def is?(role)
    self.roles.include?(role.to_s)
  end

  private

  def strip_empty_role
    self.roles = self.roles.reject(&:empty?)
  end

  def roles_valid
    if self.roles.empty?
      errors[:roles] << 'at least one role must be present'
    elsif (self.roles - self.class::ROLES).any?
      errors[:roles] << "must be one or more of: #{roles_string}"
    end
  end

  def roles_string(delimiter=', ')
    self.class::ROLES.map{ |r| r.humanize.downcase }.join(delimiter)
  end
end
