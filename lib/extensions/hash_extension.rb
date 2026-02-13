module Extensions
  module HashExtension
    def all_values_for(key)
      each_with_object([]) do |(k, v), values|
        values << v if k.eql?(key)
        values.concat(v.select { |el| el.is_a?(Hash) }.flat_map { |el| el.all_values_for(key) }) if v.is_a? Array
        values.concat(v.all_values_for(key)) if v.is_a? Hash
      end
    end

    def key_paths(path = [])
      each_with_object([]) do |(k, v), items|
        if v.is_a?(Hash)
          items.push(*v.key_paths(path + [k]))
        else
          items << (path + [k])
        end
      end
    end
  end
end
