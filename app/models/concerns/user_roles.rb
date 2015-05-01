module UserRoles
  extend ActiveSupport::Concern

  included do |klass|
    validates :role, presence: true, inclusion: { in: klass::ROLES }

    klass::ROLES.each do |role|
      scope role.pluralize.to_sym, -> { where(role: role) }
    end

    klass::ROLES.each do |role|
      define_method "#{role}?" do
        is?(role)
      end
    end
  end

  def is?(role)
    self.role == role.to_s
  end
end
