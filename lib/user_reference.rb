module UserReference
  def user=(user)
    self.user_id = user.user_id
    self.company_id = user.company_id
  end
end