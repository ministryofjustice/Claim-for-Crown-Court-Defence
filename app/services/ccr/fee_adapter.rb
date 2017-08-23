# CCR bill types are logically similar to CCCD fee types,
# however the "advocate fee" is a combination
# of some of the basic fee types' values.
#
# * Its bill type "key" is AGFS_FEE
# * Its bill sub type "key" is derived from the case type
# * some case types are not allowed to claim an "advocate fee" at all
#
# INJECTION: eventually the bill type and sub type (for advocate fee)
# should be derivable by CCR from the bill scenario alone, since this
# maps the case type in any event.
# i.e.
# case type -> bill scenario
# case type -> bill type/subtype
# =
# bill scenario -> bill type/subtype
# AND eventually no mappings will be necessary on CCCD side as..
# case type uuid -> bill scenario/type/subtype
#
module CCR
  class FeeAdapter
    attr_reader :claim

    # The CCR "Advocate fee" bill can have different sub types
    # based on the type of case, which map as follows.
    # Those case types with nil values cannot claim an "Advocate fee" at all
    #
    KEYS = %i[bill_type bill_subtype].freeze
    def self.zip(bill_types = [])
      Hash[KEYS.zip(bill_types)]
    end

    ADVOCATE_FEE_BILL_MAPPINGS = {
      FXACV: zip(%w[AGFS_FEE AGFS_APPEAL_CON]), # Appeal against conviction
      FXASE: zip(%w[AGFS_FEE AGFS_APPEAL_SEN]), # Appeal against sentence
      FXCBR: zip(%w[AGFS_FEE AGFS_ORDER_BRCH]), # Breach of Crown Court order
      FXCSE: zip(%w[AGFS_FEE AGFS_COMMITTAL]), # Committal for Sentence
      FXCON: zip([nil, nil]), # Contempt
      GRRAK: zip(%w[AGFS_FEE AGFS_FEE]), # Cracked Trial
      GRCBR: zip(%w[AGFS_FEE AGFS_FEE]), # Cracked before retrial
      GRDIS: zip([nil, nil]), # Discontinuance
      FXENP: zip([nil, nil]), # Elected cases not proceeded
      GRGLT: zip(%w[AGFS_FEE AGFS_FEE]), # Guilty plea
      FXH2S: zip([nil, nil]), # Hearing subsequent to sentence??? LGFS only
      GRRTR: zip(%w[AGFS_FEE AGFS_FEE]), # Retrial
      GRTRL: zip(%w[AGFS_FEE AGFS_FEE]) # Trial
    }.freeze

    delegate :bill_type, :bill_subtype, to: :@bill_types

    def initialize(claim)
      @claim = claim
      @bill_types = OpenStruct.new(ADVOCATE_FEE_BILL_MAPPINGS[bill_key])
    end

    # Convienience class methods for single calls.
    # Multiple adaptor calls should instantiate an
    # instance and call the instance methods instead
    #
    class << self
      def bill_type(claim)
        adapter = new(claim)
        adapter.bill_type
      end

      def bill_subtype(claim)
        adapter = new(claim)
        adapter.bill_subtype
      end
    end

    private

    def bill_key
      claim.case_type.fee_type_code.to_sym
    end
  end
end
