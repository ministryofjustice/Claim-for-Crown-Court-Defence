module HostMemory
  # All memory returned in kilobytes
  #
  class << self
    def total
      mem_at_index 7
    end

    def used
      mem_at_index 8
    end

    def free
      mem_at_index 9
    end

    def percentage_of_total(percent)
      (total / 100) * percent.to_i
    rescue StandardError => err
      puts "Error: #{err}"
      nil
    end

    private

    # use kilobytes explicitly for simplicity (NB: KB is the default for `free`)
    def mem_at_index(index)
      `free -k`.split(' ')[index].to_i
    rescue StandardError => err
      puts "Error: #{err}"
      nil
    end
  end
end
