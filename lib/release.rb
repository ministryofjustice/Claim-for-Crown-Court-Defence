# class to assist with releasing features
class Release
  class << self
    def reject_refuse_messaging_released_at
      Time.parse(Settings.reject_refuse_messaging_released_at.to_s)
    end

    def reject_refuse_messaging_released?
      reject_refuse_messaging_released_at.utc <= Time.current.utc
    end
  end
end
