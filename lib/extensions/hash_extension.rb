module HashExtension
  def all_keys
    each_with_object([]) do |(k, v), keys|
      keys << k
      keys.concat(v.select { |el| el.is_a?(Hash) }.flat_map(&:all_keys)) if v.is_a? Array
      keys.concat(v.all_keys) if v.is_a? Hash
    end
  end

  def all_values_for(key)
    each_with_object([]) do |(k, v), values|
      values << v if k.eql?(key)
      values.concat(v.select { |el| el.is_a?(Hash) }.flat_map { |el| el.all_values_for(key) }) if v.is_a? Array
      values.concat(v.all_values_for(key)) if v.is_a? Hash
    end
  end
end
