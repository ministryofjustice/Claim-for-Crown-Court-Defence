module Claims::Cloner
  extend ActiveSupport::Concern

  included do |klass|
    klass.amoeba do
      enable
      nullify :submitted_at
      nullify :uuid
      clone [:fees, :documents, :defendants, :expenses]
    end

    Fee.class_eval do |klass|
      klass.amoeba do
        enable
        nullify :uuid
        clone [:dates_attended]
      end
    end

    Defendant.class_eval do |klass|
      klass.amoeba do
        enable
        nullify :uuid
        clone [:representation_orders]
      end
    end

    Expense.class_eval do |klass|
      klass.amoeba do
        enable
        nullify :uuid
        clone [:dates_attended]
      end
    end

    RepresentationOrder.class_eval do |klass|
      klass.amoeba do
        enable
        nullify :uuid
      end
    end

    Document.class_eval do |klass|
      klass.amoeba do
        enable
        nullify :uuid
      end
    end

    DateAttended.class_eval do |klass|
      klass.amoeba do
        enable
        nullify :uuid
      end
    end
  end

  def clone_rejected_to_new_draft
    raise 'Can only clone claims in state "rejected"' unless rejected?

    draft = amoeba_dup
    draft.state = 'draft'
    draft.save!
    draft
  end
end
