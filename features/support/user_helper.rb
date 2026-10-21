module UserHelper
  def sign_in(user, password)
    identify_legacy_email(user)

    using_wait_time 6 do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      click_on 'Sign in'
    end
  end

  def identify_legacy_email(user)
    using_wait_time 10 do
      visit sign_in_path
      fill_in 'Email address', with: user.email
      click_on 'Continue'
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end

World(UserHelper)
