class AddRequestBlobToRequests < ActiveRecord::Migration
  def change
    add_column :requests_requests, :request_json, :text
  end
end
