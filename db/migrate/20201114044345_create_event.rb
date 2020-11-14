class CreateEvent < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.references :button, null: false, type: :uuid
      t.timestamps
    end
  end
end
