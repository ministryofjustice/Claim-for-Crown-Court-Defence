class FeeDatesSectionCondensed < SitePrism::Section
  section :from, ".dates-wrapper .fee-date-from" do
    include DateHelper
    element :day, "input:nth-of-type(1)"
    element :month, "input:nth-of-type(2)"
    element :year, "input:nth-of-type(3)"
  end

  section :to, ".dates-wrapper .fee-date-to" do
    include DateHelper
    element :day, "input:nth-of-type(1)"
    element :month, "input:nth-of-type(2)"
    element :year, "input:nth-of-type(3)"
  end
end
