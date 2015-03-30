module UserHelper
  def sign_in(user, password)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_on 'Log in'
  end
end

World(UserHelper)
