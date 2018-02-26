module HashExtension
  def all_keys
    each_with_object([]) do |(k, v), keys|
      keys << k
      keys.concat(v.all_keys) if v.is_a? Hash
    end
  end

  def all_values_for(key)
    each_with_object([]) do |(k, v), result|
      result << v if k.eql?(key)
      result.concat(v.all_values_for(key)) if v.is_a? Hash
    end
  end
end
