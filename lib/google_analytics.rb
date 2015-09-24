module GATracking
  DEFAULT_GA_TRACKER_ID = "UA-37377084-37"

  def  self.ga_tracker_id
    ENV.fetch('GA_TRACKER_ID', DEFAULT_GA_TRACKER_ID)
  end
end
