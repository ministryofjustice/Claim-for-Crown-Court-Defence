class CaseWorkerPresenter < BasePresenter

  presents :case_worker



  #returns markup like:
  #
  # <div class="working-pattern">
  #   <ul>
  #     <li class="working-day"><abbr title="Monday">M</abbr></li>
  #     <li><abbr title="Tuesday">T</abbr></li>
  #   </ul>
  # </div>
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
