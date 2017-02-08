class AddRequestBlobToRequests < ActiveRecord::Migration
  def change
    add_column :requests_requests, :body, :text
  end
end
