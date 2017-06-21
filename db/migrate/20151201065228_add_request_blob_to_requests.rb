class AddRequestBlobToRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :requests_requests, :body, :text
  end
end
