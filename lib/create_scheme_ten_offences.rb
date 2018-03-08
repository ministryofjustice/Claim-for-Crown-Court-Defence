class CreateSchemeTenOffences
  # rubocop:disable all
  def self.run!

    FeeCategory.find_or_create_by(number: 1, description: 'Murder/Manslaughter')
    FeeCategory.find_or_create_by(number: 2, description: 'Terrorism')
    FeeCategory.find_or_create_by(number: 3, description: 'Serious Violence')
    FeeCategory.find_or_create_by(number: 4, description: 'Sexual Offences (Children)')
    FeeCategory.find_or_create_by(number: 5, description: 'Sexual Offences (Adult)')
    FeeCategory.find_or_create_by(number: 6, description: 'Dishonesty Offences')
    FeeCategory.find_or_create_by(number: 7, description: 'Property Damage')
    FeeCategory.find_or_create_by(number: 8, description: 'Offences Against the Public Interest')
    FeeCategory.find_or_create_by(number: 9, description: 'Drugs Offences')
    FeeCategory.find_or_create_by(number: 10, description: 'Driving Offences')
    FeeCategory.find_or_create_by(number: 11, description: 'Burglary and Robbery')
    FeeCategory.find_or_create_by(number: 12, description: 'Firearms Offences')
    FeeCategory.find_or_create_by(number: 13, description: 'Other Offences Against the Person')
    FeeCategory.find_or_create_by(number: 14, description: 'Exploitation and Human Trafficking Offences')
    FeeCategory.find_or_create_by(number: 15, description: 'Public Order Offences')
    FeeCategory.find_or_create_by(number: 16, description: 'Regulatory Offences')
    FeeCategory.find_or_create_by(number: 17, description: 'Standard Offences')

    [
      [1, 4],[2, 2], [3, 5], [4, 3], [5, 3], [6, 5], [7, 3], [8, 1], [9, 7],
      [10, 1], [11, 2], [12, 3], [13, 1], [14, 1], [15, 1], [16, 3], [17, 1]
    ].each do |k,v|
      category = FeeCategory.find_by(number: k)
      1.upto(v) do |i|
        FeeBand.find_or_create_by(fee_category: category, number: i, description: "#{k}.#{i}")
      end
    end

    agfs_fee_scheme_ten = FeeScheme.find_by(name: 'AGFS', number: '10')
    offence = Offence.find_or_create_by(
      description: 'Killing of a child (16 years old or under); killing of two or more persons; killing of a police officer, prison officer or equivalent public servant in the course of their duty; killing of a patient in a medical or nursing care context; corporate manslaughter; manslaughter by gross negligence; missing body killing.',
      offence_class_id: 1,
      unique_code: 'KILL10'
    )

    OffenceFeeScheme.find_or_create_by(offence: offence, fee_scheme: agfs_fee_scheme_ten)
  end
end
