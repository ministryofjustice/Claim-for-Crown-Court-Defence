module HashExtension
  def all_keys
    each_with_object([]) do |(k, v), keys|
      keys << k
      keys.concat(v.all_keys) if v.is_a? Hash
    end
  end
end
