module Remote
  class Court < Base
    attr_accessor :name,
                  :code,
                  :court_type

    class << self
      # def resource_path
      #   'court'
      # end

      # # TODO: following methods will be extracted to a new (non-ActiveRecord) Roles concern
      # #
      # def lgfs
      #   all.select { |ct| ct.roles.include?('lgfs') }
      # end
      #
      # def agfs
      #   all.select { |ct| ct.roles.include?('agfs') }
      # end
      #
      # def interims
      #   all.select { |ct| ct.roles.include?('interim') }
      # end
    end
  end
end
