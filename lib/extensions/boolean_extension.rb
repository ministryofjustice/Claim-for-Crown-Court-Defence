module BooleanExtension
  module True
    def to_i
      1
    end

    def to_yesno
      'Yes'
    end
  end

  module False
    def to_i
      0
    end

    def to_yesno
      'No'
    end
  end
end
