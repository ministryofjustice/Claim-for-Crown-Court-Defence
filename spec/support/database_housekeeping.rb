module DatabaseHousekeeping
	def clean_database
    models = [
      CaseType,
      CaseWorker,
      CaseWorkerClaim,
      Certification,
      CertificationType,
      ClaimIntention,
      ClaimStateTransition,
      Claim::BaseClaim,
      Claim::TransferDetail,
      Court,
      DateAttended,
      Defendant,
      Determination,
      Disbursement,
      DisbursementType,
      Document,
      Establishment,
      Expense,
      ExpenseType,
      ExternalUser,
      FeeScheme,
      Fee::BaseFee,
      Fee::BaseFeeType,
      InjectionAttempt,
      InterimClaimInfo,
      Location,
      Message,
      Offence,
      OffenceClass,
      OffenceBand,
      OffenceCategory,
      OffenceFeeScheme,
      Provider,
      RepresentationOrder,
      Stats::Statistic,
      Stats::StatsReport,
      Stats::MIData,
      SuperAdmin,
      SupplierNumber,
      User,
      UserMessageStatus
    ]

    models.each do |model|
      model.delete_all
    end
  end

  def report_record_counts
    tables = ActiveRecord::Base.connection.tables
    tables.each do |t|
      next if t == 'schema_migrations'
      next if t == 'versions'
      puts "#{t.classify} #{t.classify.constantize.count}"
    end
  end
end
