class SelectOptionSection < SitePrism::Section
end

class LgfsHardshipFeeSection < SitePrism::Section

  # common hardship fee fields
  element :ppe_total, '.quantity'
  element :amount, ".total"

end
