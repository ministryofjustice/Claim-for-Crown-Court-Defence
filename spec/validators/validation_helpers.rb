module ValidationHelpers

  shared_context "force-validation" do
    before do
      claim.force_validation = true
    end
  end

  # needed to work around Total validation on claim
  def create_and_submit_claim(claim)
    claim.force_validation = false
    claim.save
    claim.force_validation = true
    claim.submit!
  end

  def should_error_with(record, field, message)
    expect(record.valid?).to be false
    expect(record.errors[field]).to include(message)
  end

  def should_not_error(record, field)
    expect(record.valid?).to be true
    expect(record.errors[field]).to be_empty
  end

  def should_error_if_present(record, field, value, message, options={})
    record.send("#{field}=", value)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
    with_expected_error_translation(field, message, options) if options[:translated_message]
  end

  def should_error_if_not_present(record, field, message, options={})
    record.send("#{field}=", nil)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
    with_expected_error_translation(field, message, options) if options[:translated_message]
  end

  # checks the translation exists and has expected message
  def with_expected_error_translation(field, message, options)
    @translations ||= YAML.load_file("#{Rails.root}/config/locales/error_messages.en.yml") # lazy load translations
    message_type = options[:translated_message_type] || 'short'
    expect(@translations.has_key?(field.to_s)).to eql true
    expect(@translations[field.to_s].has_key?(message)).to eql true
    expect(@translations[field.to_s][message][message_type]).to eql options[:translated_message]
  end

  def should_error_if_in_future(record, field, message, options={})
    record.send("#{field}=", 2.days.from_now)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
    with_expected_error_translation(field, message, options) if options[:translated_message]
  end

  def should_error_if_too_far_in_the_past(record, field, message, options={})
    record.send("#{field}=", Settings.earliest_permitted_date - 1.day)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
    with_expected_error_translation(field, message, options) if options[:translated_message]
  end

  def should_error_if_earlier_than_earliest_repo_date(record, field, message, options={})
    stub_earliest_rep_order(record, 1.year.ago.to_date)
    record.send("#{field}=", 13.months.ago)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
    with_expected_error_translation(field, message, options) if options[:translated_message]
  end

  def should_error_if_earlier_than_other_date(record, field, other_date, message, options={})
    record.send("#{field}=", 5.day.ago)
    record.send("#{other_date}=", 3.day.ago)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
    with_expected_error_translation(field, message, options) if options[:translated_message]
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

  def should_errror_if_later_than_other_date(record, field, other_date, message, options={})
    record.send("#{field}=", 5.day.ago)
    record.send("#{other_date}=", 7.day.ago)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
    with_expected_error_translation(field, message, options) if options[:translated_message]
  end

  def should_error_if_equal_to_value(record, field, value, message)
    record.send("#{field}=", value)
    expect(record.send(:valid?)).to be false
    expect(record.errors[field]).to include(message)
  end

  def should_be_valid_if_equal_to_value(record, field, value)
    record.send("#{field}=", value)
    expect(record.errors[field]).to be_empty
    expect(record.send(:valid?)).to be true
  end

  def stub_earliest_rep_order(claim, date)
    allow(claim).to receive_message_chain(:earliest_representation_order, :representation_order_date).and_return(date)
  end

  def nulify_fields_on_record(record, *fields)
    fields.each do |field|
      record.send("#{field}=", nil)
    end
    record
  end

end
