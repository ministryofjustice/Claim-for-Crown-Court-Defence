module SelectHelper
  def select(value, options)
    super value.to_s, {visible: false}.merge(options)
  end
end

World(SelectHelper)
