class ChangeAdvocatePersonaTypeToExternalUser < ActiveRecord::Migration
  def change
    execute(%q{UPDATE users SET persona_type = 'ExternalUser' WHERE persona_type = 'Advocate'} )
  end
end