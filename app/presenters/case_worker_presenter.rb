class CaseWorkerPresenter < BasePresenter

  presents :case_worker



  #returns markup like:
  #
  #  <div><span class="working-day">M</span><span>T</span> etc</div>
  def days_worked_markup
    result = '<div class="working-pattern"><ul>'
    case_worker.days_worked.each_with_index do |day, i|
      result += '<li'
      result += ' class="working-day"' if day == 1
      result += '>'
      result += '<abbr title="' + Settings.day_names[i] + '">'
      result += Settings.day_name_initials[i]
      result += '</abbr></li>'
    end
    result += '</ul></div>'
    result.html_safe
  end
end
