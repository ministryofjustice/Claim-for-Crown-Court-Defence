module HashExtension
  def all_keys
    each_with_object([]) do |(k, v), keys|
      keys << k
      keys.concat(v.all_keys) if v.is_a? Hash
    end
  end

  def all_values_for(key)
    result = []
    result << fetch(key, nil)
    each_value do |hash_value|
      hash_values = [hash_value] unless hash_value.is_a? Array
      hash_values.each do |value|
        result += value.all_values_for(key) if value.is_a? Hash
      end
    end
    result.compact
  end
end
