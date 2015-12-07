class DeterminationPresenter < BasePresenter

  presents :version

  def event
    version.event
  end

  def timestamp
    " - #{version.created_at.strftime('%H:%M')}"
  end

  def itemise
    changeset.each do |attribute, changes|
      yield attribute, changes.last
    end
  end

end
