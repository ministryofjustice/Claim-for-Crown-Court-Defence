class CreateSchemeTenOffences
  # rubocop:disable all
  def self.run!
    agfs_fee_scheme_ten = FeeScheme.find_by(name: 'AGFS', number: '10')
    offence = Offence.create(
      description: 'Killing of a child (16 years old or under); killing of two or more persons; killing of a police officer, prison officer or equivalent public servant in the course of their duty; killing of a patient in a medical or nursing care context; corporate manslaughter; manslaughter by gross negligence; missing body killing.',
      offence_class_id: 1,
      unique_code: 'KILL10'
    )

    OffenceFeeScheme.create(offence: offence, fee_scheme: agfs_fee_scheme_ten)
  end
end
