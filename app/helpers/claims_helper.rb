module ClaimsHelper

	def includes_state?(claims, states)
		states.gsub(/\s+/,'').split(',').to_a unless states.is_a?(Array)
		claims.map(&:state).uniq.any? { |s| states.include?(s) }
	end


  def number_with_precision_or_blank(number, options = {})
    if options.has_key?(:precision)
      number == 0 ? '' : number_with_precision(number, options)
    else
      number == 0 ? '' : number.to_s
    end
  end

end
