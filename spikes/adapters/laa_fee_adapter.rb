class LaaFeeAdapter
  BASIC_FEES_MAP = {
    'FXACV' => 'AGFS_APPEAL_CON',
    'FXASE' => 'AGFS_APPEAL_SEN',
    'FXCBR' => 'AGFS_ORDER_BRCH',
    'FXCSE' => 'AGFS_COMMITTAL',
    'FXCON' => nil,
    'GRRAK' => 'AGFS_FEE',
    'GRCBR' => 'AGFS_FEE',
    'GRDIS' => 'AGFS_FEE',
    'FXENP' => 'AGFS_FEE',
    'GRGLT' => 'AGFS_FEE',
    'FXH2S' => 'AGFS_FEE',
    'GRRTR' => 'AGFS_FEE',
    'GRTRL' => 'AGFS_FEE'
  }.freeze

  FEES_MAP = {
    'BABAF' => nil, # special processing
    'BACAV' => %w[AGFS_MISC_FEES AGFS_CONFERENCE],
    'BADAF' => nil,
    'BADAH' => nil,
    'BADAJ' => nil,
    'BANOC' => nil,
    'BANDR' => nil,
    'BANPW' => nil,
    'BAPPE' => nil,
    'BAPCM' => %w[AGFS_MISC_FEES AGFS_PLEA],
    'BASAF' => %w[AGFS_MISC_FEES AGFS_STD_APPRNC],
    'FXALT' => nil,
    'FXACV' => %w[AGFS_FEE AGFS_APPEAL_CON],
    'FXACU' => nil,
    'FXASE' => %w[AGFS_FEE AGFS_APPEAL_SEN],
    'FXASU' => nil,
    'FXASS' => nil,
    'FXCBR' => nil,
    'FXCBU' => nil,
    'FXCSE' => %w[AGFS_FEE AGFS_COMMITTAL],
    'FXCSU' => nil,
    'FXCON' => %w[AGFS_MISC_FEES AGFS_CONTEMPT],
    'FXCCD' => nil,
    'FXCDU' => nil,
    'FXENP' => nil,
    'FXENU' => nil,
    'FXH2S' => nil,
    'FXNOC' => nil,
    'FXNDR' => nil,
    'FXSAF' => %w[AGFS_MISC_FEES AGFS_STD_APPRNC],
    'FXASB' => nil,
    'GRCBR' => nil,
    'GRRAK' => nil,
    'GRDIS' => nil,
    'GRGLT' => nil,
    'GRRTR' => nil,
    'GRTRL' => nil,
    'INDIS' => nil,
    'INPCM' => nil,
    'INRNS' => nil,
    'INRST' => nil,
    'INTDT' => nil,
    'INWAR' => nil,
    'MIAHU' => nil,
    'MIAPH' => %w[AGFS_MISC_FEES AGFS_ABS_PRC_HF],
    'MIAWU' => nil,
    'MIAPW' => %w[AGFS_MISC_FEES AGFS_ABS_PRC_WL],
    'MISAF' => %w[AGFS_MISC_FEES AGFS_ADJOURNED],
    'MIADC3' => nil,
    'MIADC1' => %w[AGFS_MISC_FEES AGFS_DMS_DY2_HF],
    'MIADC4' => nil,
    'MIADC2' => %w[AGFS_MISC_FEES AGFS_DMS_DY2_WL],
    'MIUPL' => nil,
    'MIDHU' => nil,
    'MIDTH' => %w[AGFS_MISC_FEES AGFS_CONFISC_HF],
    'MIDWU' => nil,
    'MIDTW' => %w[AGFS_MISC_FEES AGFS_CONFISC_WL],
    'MICJA' => %w[AGFS_EXPENSES AGFS_CJD_FEE],
    'MICJP' => %w[AGFS_EXPENSES AGFS_CJD_EXP],
    'MIDSE' => %w[AGFS_MISC_FEES AGFS_DEF_SEN_HR],
    'MIDSU' => nil,
    'MIEVI' => %w[AGFS_EVIDPRVFEE AGFS_EVIDPRVFEE],
    'MIEHU' => nil,
    'MIAEH' => %w[AGFS_MISC_FEES AGFS_ADM_EVD_HF],
    'MIEWU' => nil,
    'MIAEW' => %w[AGFS_MISC_FEES AGFS_ADM_EVD_WL],
    'MIHHU' => nil,
    'MIHDH' => %w[AGFS_MISC_FEES AGFS_DISC_HALF],
    'MIHWU ' => nil,
    'MIHDW' => %w[AGFS_MISC_FEES AGFS_DISC_FULL],
    'MINBR' => %w[AGFS_MISC_FEES AGFS_NOTING_BRF],
    'MIPPC' => %w[AGFS_MISC_FEES AGFS_PAPER_PLEA],
    'MIPCU' => nil,
    'MICHU' => nil,
    'MIPCH' => nil,
    'MICHW' => nil,
    'MIPCW' => nil,
    'MIPIU3' => nil,
    'MIPIH1' => %w[AGFS_MISC_FEES AGFS_PI_IMMN_HF],
    'MIPIH4' => nil,
    'MIPIH2' => %w[AGFS_MISC_FEES AGFS_PI_IMMN_WL],
    'MIRNF' => %w[AGFS_MISC_FEES AGFS_NOVELISSUE],
    'MIRNL' => %w[AGFS_MISC_FEES AGFS_NOVEL_LAW],
    'MISHR' => %w[AGFS_MISC_FEES AGFS_SENTENCE],
    'MISHU' => nil,
    'MISPF' => %w[AGFS_MISC_FEES SPECIAL_PREP],
    'MISAU' => nil,
    'MITNP' => %w[AGFS_MISC_FEES AGFS_NOT_PRCD],
    'MITNU' => nil,
    'MIUAV3' => nil,
    'MIUAV1' => %w[AGFS_MISC_FEES AGFS_UN_VAC_HF],
    'MIUAV4' => nil,
    'MIUAV2' => %w[AGFS_MISC_FEES AGFS_UN_VAC_WL],
    'MIWPF' => %w[AGFS_MISC_FEES AGFS_WSTD_PREP],
    'MIWOA' => %w[AGFS_MISC_FEES AGFS_WRTN_ORAL],
    'TRANS' => nil,
    'WARR' => nil
  }.freeze

  def self.laa_bill_type_and_sub_type(fee)
    if fee.fee_type.unique_code == 'BABAF'
      translate_basic_fee_type(fee)
    else
      translate_fee_type(fee)
    end
  end

  def self.translate_basic_fee_type(fee)
    sub_type = BASIC_FEES_MAP[fee.claim.case_type.fee_type_code]
    if sub_type.nil?
      nil
    else
      ['AGFS_FEE', sub_type]
    end
  end

  def self.translate_fee_type(fee)
    FEES_MAP[fee.fee_type.unique_code]
  end

  private_class_method :translate_basic_fee_type, :translate_fee_type
end
