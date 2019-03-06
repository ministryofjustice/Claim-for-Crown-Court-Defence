module UserHelper
  def sign_in(user, password)
    using_wait_time 10 do
      visit new_user_session_path
      expect(current_path).to eql(new_user_session_path)
    end

    using_wait_time 6 do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      click_on 'Sign in'
    end
  end
end

World(UserHelper)
