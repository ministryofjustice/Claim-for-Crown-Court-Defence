class FeeDatesSectionCondensed < SitePrism::Section
  section :from, ".dates-wrapper .fee-date-from" do
    include DateHelper
    element :day, ".form-group-day input"
    element :month, ".form-group-month input"
    element :year, ".form-group-year input"
  end

  section :to, ".dates-wrapper .fee-date-to" do
    include DateHelper
    element :day, "input:nth-of-type(1)"
    element :month, "input:nth-of-type(2)"
    element :year, "input:nth-of-type(3)"
  end
end
