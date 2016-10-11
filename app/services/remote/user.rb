module Remote
  class User < Base
    attr_accessor :first_name, :last_name, :email

    def name
      [first_name, last_name].join(' ')
    end

    def sortable_name
      [last_name, first_name].join(' ')
    end
  end
end
