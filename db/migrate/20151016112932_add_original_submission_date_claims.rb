class AddOriginalSubmissionDateClaims < ActiveRecord::Migration
  def change
    add_column :claims, :original_submission_date, :datetime
  end
end
