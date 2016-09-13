module Claims::Cloner
  extend ActiveSupport::Concern
  include Duplicable

  EXCLUDED_FEE_ASSOCIATIONS = [
    :basic_fees, :fixed_fees, :misc_fees, :fixed_fee, :warrant_fee, :graduated_fee, :interim_fee, :transfer_fee
  ].freeze

  included do |klass|
    klass.duplicate_this do
      enable

      nullify :last_submitted_at
      nullify :last_edited_at
      nullify :original_submission_date
      nullify :uuid

      exclude_association :messages
      exclude_association :case_worker_claims
      exclude_association :case_workers
      exclude_association :claim_state_transitions
      exclude_association :versions
      exclude_association :determinations
      exclude_association :assessment
      exclude_association :redeterminations
      exclude_association :certification

      EXCLUDED_FEE_ASSOCIATIONS.each { |assoc| exclude_association assoc }

      clone [:fees, :documents, :defendants, :expenses, :disbursements]

      set form_id: SecureRandom.uuid

      customize(lambda { |original_claim, new_claim|
        new_claim.clone_source_id = original_claim.id
        new_claim.documents.each do |d|
          d.form_id = new_claim.form_id
        end
      })
    end

    Fee::BaseFee.class_eval do |klass|
      klass.duplicate_this do
        enable
        nullify :uuid
        clone [:dates_attended]
      end
    end

    Defendant.class_eval do |klass|
      klass.duplicate_this do
        enable
        nullify :uuid
        clone [:representation_orders]
      end
    end

    Expense.class_eval do |klass|
      klass.duplicate_this do
        enable
        nullify :uuid
        clone [:dates_attended]
      end
    end

    Disbursement.class_eval do |klass|
      klass.duplicate_this do
        enable
      end
    end

    RepresentationOrder.class_eval do |klass|
      klass.duplicate_this do
        enable
        nullify :uuid
      end
    end

    Document.class_eval do |klass|
      klass.duplicate_this do
        enable
        set verified: false

        nullify :uuid
        nullify :file_path
        nullify :verified_file_size

        exclude_association :document

        customize(lambda { |original_doc, new_doc|
          new_doc.copy_from(original_doc, verify: true)
        })
      end
    end

    DateAttended.class_eval do |klass|
      klass.duplicate_this do
        enable
        nullify :uuid
      end
    end
  end

  def clone_rejected_to_new_draft(author_id:)
    raise 'Can only clone claims in state "rejected"' unless rejected?
    draft = duplicate
    draft.transition_clone_to_draft!(author_id: author_id)
    draft
  end

  # `other_claim` can be a draft instance of any kind of claim scheme (agfs or lgfs).
  # Once this is implemented in the UI, this instance will need to be initialized with the creator
  # and external_user, which will be the logged-in user performing the action.
  #
  def clone_details_to_draft(other_claim)
    raise ArgumentError, 'Can only clone details to claims in state "draft"' unless other_claim.draft?

    other_claim.attributes = {
      court_id: court_id,
      defendants: defendants.map(&:duplicate)
    }

    other_claim.save(validate: false)
    other_claim
  end
end
