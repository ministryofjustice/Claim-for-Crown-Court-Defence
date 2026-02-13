module Extensions
  module HashExtension
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
