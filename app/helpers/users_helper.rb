module UsersHelper
  def user_oauth?
    current_user.user_oauth_account.present?
  end
end
