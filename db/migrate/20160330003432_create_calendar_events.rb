class CreateCalendarEvents < ActiveRecord::Migration
  def change
    create_table :calendar_events do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.text :description
      t.string :title

      t.timestamps null: false
    end
  end
end
