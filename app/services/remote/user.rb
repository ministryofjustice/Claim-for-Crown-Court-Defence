module Remote
  class User < Base
    attr_accessor :uuid, :first_name, :last_name

    def name
      [first_name, last_name].join(' ')
    end
  end
end
