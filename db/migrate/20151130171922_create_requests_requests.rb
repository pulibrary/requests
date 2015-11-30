class CreateRequestsRequests < ActiveRecord::Migration
  def change
    create_table :requests_requests do |t|
      t.string :title
      t.string :system_id

      t.timestamps null: false
    end
  end
end
