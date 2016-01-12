class ChangeAdvocatePersonaTypeToExternalUser < ActiveRecord::Migration
  def change
    User.all.each do |user|
      if user.persona_type == 'Advocate'
        user.update_column(:persona_type, 'ExternalUser')
      end
    end
  end
end
