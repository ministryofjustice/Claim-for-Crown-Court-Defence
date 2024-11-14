class CourtDataForm
  def name = :court_data
  def id = 26_269_575
  def collector = :court_data

  def template
    {
      case_number: { id: 63_321_668, format: :text },
      claim_id: { id: 63_321_670, format: :text },
      defendant_id: { id: 63_349_729, format: :text },
      comments: { id: 63_321_717, format: :text }
    }
  end
end
