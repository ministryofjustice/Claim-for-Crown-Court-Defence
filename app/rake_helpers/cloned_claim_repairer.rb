# This class attempts to find the source claim of a cloned claim
# and update the clone_source_id coloumn with the id of the original claim.

class ClonedClaimRepairer
  def initialize(claim_id)
    @claim_id = claim_id
    @claim = Claim::BaseClaim.find_by(id: claim_id)

    @updated_claims = {}
  end

  def repair!
    if @claim.nil?
      puts "Unable to find claim #{@claim_id}"
      return
    end
    source_claim = find_source_claim
    @claim.update(clone_source_id: source_claim.id) unless source_claim.nil?
  end

  private

  def find_source_claim
    puts "Finding Source claim for claim id #{@claim.id}"
    candidates = @claim.class.where('case_number = ? and id < ?', @claim.case_number, @claim.id).order(:id)
    candidates = candidates.select { |c| same_defendants?(c) }
    candidates = candidates.select { |c| was_rejected?(c) }
    if candidates.empty?
      puts "   Unable to find candidate as clone source"
      return nil
    else
      puts "   Found #{candidates.size} candidates as clone source - picking the latest (claim id #{candidates.last.id}"
      return candidates.last
    end
  end


  def same_defendants?(candidate)
    return true if candidate.defendants.map(&:name) == @claim.defendants.map(&:name)
    puts "   Claim #{candidate.id} not considered as candidate for claim #{@claim.id}: defendants don't match"
    puts "      Claim #{candidate.id}: #{candidate.defendants.map(&:name).inspect} vs claim #{@claim.id}: #{@claim.defendants.map(&:name).inspect}"
    false
  end

  def was_rejected?(candidate)
    return true if candidate.claim_state_transitions.map(&:to).include?('rejected')
    puts "   Claim #{candidate.id} not considered as candidate for claim #{@claim.id}: was never rejected"
    false
  end
end