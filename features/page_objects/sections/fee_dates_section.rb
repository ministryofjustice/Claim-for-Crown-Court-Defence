class FeeDatesSection < SitePrism::Section
  section :from, "td:nth-of-type(1) > span:nth-of-type(1)" do
    include DateHelper
    element :day, "input:nth-of-type(1)"
    element :month, "input:nth-of-type(2)"
    element :year, "input:nth-of-type(3)"
  end

  section :to, "td:nth-of-type(1) > span:nth-of-type(2)" do
    include DateHelper
    element :day, "input:nth-of-type(1)"
    element :month, "input:nth-of-type(2)"
    element :year, "input:nth-of-type(3)"
  end
end
