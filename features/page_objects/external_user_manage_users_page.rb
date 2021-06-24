class ExternalUserManageUsersPage < BasePage
  set_url "/external_users/admin/external_users"

  section :user_table, 'table.report' do
    sections :rows, 'tbody > tr' do
    end
  end
end
