module ClaimsHelper

	def includes_state?(claims, states)
		states.gsub(/\s+/,'').split(',').to_a unless states.is_a?(Array)
		claims.map(&:state).uniq.any? { |s| states.include?(s) }
	end

end
