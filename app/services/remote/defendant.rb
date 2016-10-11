module Remote
  class Defendant < Remote::User
    attr_accessor :date_of_birth
    has_many :representation_orders
  end
end
