class CreateRequestsRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :requests_requests do |t|
      t.string :title
      t.string :system_id
      t.string :status

      t.timestamps null: false
    end
  end
end
