class ActiveModel::Errors

  alias_method :_full_messages, :full_messages

  def full_messages
   self.values.flatten
  end



end