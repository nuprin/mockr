class MockView < ActiveRecord::Base
  def self.log_view(mock, user)
    mock_view = self.find_or_create_by_mock_id_and_user_id(mock.id, user.id)
    mock_view.update_attribute(:updated_at, Time.now)
  end
  
  def self.last_viewed_at(mock, user)
    mock_view = self.find_by_mock_id_and_user_id(mock.id, user.id)
    mock_view ? mock_view.updated_at : nil
  end
end
