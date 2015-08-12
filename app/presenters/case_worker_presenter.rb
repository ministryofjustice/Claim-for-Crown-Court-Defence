class CaseWorkerPresenter < BasePresenter

  presents :case_worker



  #returns markup like:
  #
  #  <div><span class="working-day">M</span><span>T</span> etc</div>
  def days_worked_markup
    result = '<div>'
    case_worker.days_worked.each_with_index do |day, i|
      result += '<span'
      result += ' class="working-day"' if day == 1
      result += ' title="' + Settings.day_names[i] + '"'
      result += '>'
      result += Settings.day_name_initials[i]
      result += '</span>'
    end
    result += '</div>'
    result
  end
end
