module LoginHelpers
  def login_as(role)
    raise 'Only :user allowed' unless role == :user

    @user = User.create(
      email: 'test@test.com',
      password: '123456',
      password_confirmation: '123456'
    )

    login_with(@user)
  end

  # Internal: Login as the specified user
  #
  # user - User instance to login with
  def login_with(user)
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "123456"
    click_button "Sign in"
  end

  def logout
    click_link "Logout" rescue nil
  end
end
