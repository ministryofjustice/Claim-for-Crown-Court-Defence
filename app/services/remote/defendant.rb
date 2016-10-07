module Remote
  class Defendant < Remote::User
    has_many :representation_orders
  end
end
