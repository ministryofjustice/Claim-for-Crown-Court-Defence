Before do |scenario|
  @scenario_tags = scenario.source_tag_names
end

module TagHelper
  def scenario_tags
    @scenario_tags
  end

  def tag?(tag)
    scenario_tags.include?(tag)
  end

  def fee_calc_vcr_tag?
    tag?('@fee_calc_vcr')
  end

  def survey_monkey_vcr_tag?
    tag?('@survey_monkey_vcr')
  end
end

World(TagHelper)
