class SelectOptionSection < SitePrism::Section
end

class LGFSHardshipFeeSection < SitePrism::Section

  # common hardship fee fields
  element :ppe_total, '.quantity'
  element :amount, ".total"

end
