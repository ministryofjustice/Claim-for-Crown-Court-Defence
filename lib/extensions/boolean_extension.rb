module BooleanExtension
  module True
    def to_i
      1
    end
  end

  module False
    def to_i
      0
    end
  end
end
