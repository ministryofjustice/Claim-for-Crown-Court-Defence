class MiscellaneousFeePage < BasePage
  set_url /advocates\/claims\/\d+\/edit\\?step=miscellaneous_fees/
  element :misc_fees_id, '.govuk-details__summary', text: 'Types of miscellaneous fees you can claim'
end
