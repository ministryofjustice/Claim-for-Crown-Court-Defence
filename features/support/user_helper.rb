module UserHelper
  def sign_in(user, password)
    visit new_user_session_path
    using_wait_time 6 do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      click_on 'Sign in'
    end
  end
end

World(UserHelper)
