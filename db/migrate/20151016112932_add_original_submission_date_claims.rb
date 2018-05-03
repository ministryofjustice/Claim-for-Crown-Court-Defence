class AddOriginalSubmissionDateClaims < ActiveRecord::Migration[4.2]
  def change
    add_column :claims, :original_submission_date, :datetime
  end
end
