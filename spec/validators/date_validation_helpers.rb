module RspecDateValidationHelpers

  def should_error_if_not_present(record, field, message)
    record.send("#{field}=", nil)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to eq( [ message ])
  end

  def should_error_if_in_future(record, field, message)
    record.send("#{field}=", 2.days.from_now)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to eq( [ message ])
  end

  def should_error_if_not_too_far_in_the_past(record, field, message) 
    record.send("#{field}=", 61.months.ago)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to eq( [ message ])
  end

  def should_error_if_earlier_than_earliest_repo_date(record, field, message)
    repo = double RepresentationOrder
    allow(record).to receive(:earliest_representation_order).and_return(repo)
    allow(repo).to receive(:representation_order_date).and_return(1.year.ago.to_date)
    record.send("#{field}=", 13.months.ago)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to eq( [ message ])
  end

  def should_error_if_earlier_than_other_date(record, field, other_date, message)
    record.send("#{field}=", 5.day.ago)
    record.send("#{other_date}=", 3.day.ago)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to eq( [ message ])
  end

  def should_error_if_before_specified_date(record, field, specified_date, message)
    record.send("#{field}=", specified_date - 1.day)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
  end

  def should_error_if_after_specified_date(record, field, specified_date, message)
    record.send("#{field}=", specified_date + 1.day)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
  end
end