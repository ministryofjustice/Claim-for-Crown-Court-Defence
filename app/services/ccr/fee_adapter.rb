# CCR bill types are logically similar to CCCD fee types,
# however the "advocate fee" is a combination
# of some of the basic fee types' values.
#
# * Its bill type "key" is AGFS_FEE
# * Its bill sub type "key" is derived from the case type
# * some case types are not allowed to claim an "advocate fee" at all
#
module CCR
  class FeeAdapter
    attr_reader :claim

   # The CCR "Advocate fee" bill can have different sub types
    # based on the type of case, which map as follows.
    # Those case types marked as not allowed cannot claim an "Advocate fee" at all
    #
    ADVOCATE_FEE_BILL_SUBTYPE_MAPPINGS = {
      FXACV: 'AGFS_APPEAL_CON', # Appeal against conviction
      FXASE: 'AGFS_APPEAL_SEN', # Appeal against sentence
      FXCBR: 'AGFS_ORDER_BRCH', # Breach of Crown Court order
      FXCSE: 'AGFS_COMMITAL', # Committal for Sentence
      FXCON: 'NOT_ALLOWED', # Contempt
      GRRAK: 'AGFS_FEE', # Cracked Trial
      GRCBR: 'AGFS_FEE', # Cracked before retrial
      GRDIS: 'NOT_ALLOWED', # Discontinuance
      FXENP: 'NOT_ALLOWED', # Elected cases not proceeded
      GRGLT: 'AGFS_FEE', # Guilty plea
      FXH2S: 'NOT_APPLICABLE', # Hearing subsequent to sentence??? LGFS only
      GRRTR: 'AGFS_FEE', # Retrial
      GRTRL: 'AGFS_FEE', # Trial
    }.freeze

    def initialize(claim)
      @claim = claim
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
        adapter.bill_type
      end
    end

    # INJECTION: this will need to be derived once mapping logic for misc
    # fees and other fee types in CCCD are understood.
    # Currently this is hardcoded to the "advocate fee" bill of CCR
    def bill_type
      'AGFS_FEE'
    end

    def bill_subtype
      ADVOCATE_FEE_BILL_SUBTYPE_MAPPINGS[claim.case_type.fee_type_code.to_sym]
    end

  end
end
