module UserHelper
  def sign_in(user, password)
    using_wait_time 10 do
      visit sign_in_path
      expect(page).to have_current_path(sign_in_path)
    end

    using_wait_time 6 do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: password
      click_on 'Sign in'
    end
  end
end

World(UserHelper)
