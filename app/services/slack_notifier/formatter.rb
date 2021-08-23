class SlackNotifier
  class Formatter
    private

    def pass_fail_colour(boolean)
      boolean ? '#36a64f' : '#c41f1f'
    end
  end
end
