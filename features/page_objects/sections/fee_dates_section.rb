class FeeDatesSection < SitePrism::Section
  section :from, ".dates-wrapper .cc-date-from" do
    include DateHelper
    element :day, ".form-group-day input"
    element :month, ".form-group-month input"
    element :year, ".form-group-year input"
  end
end
