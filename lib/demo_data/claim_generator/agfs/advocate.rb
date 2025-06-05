module DemoData
  class ClaimGenerator
    class AGFS
      class Advocate < AGFS
        def generate_claim(advocate)
          super(Claim::AdvocateClaim, advocate)
        end
      end
    end
  end
end
