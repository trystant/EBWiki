class AddColumnsToCalendarEvents < ActiveRecord::Migration
  def change
    add_column :calendar_events, :website_url, :string
    add_column :calendar_events, :street_address, :string
    add_column :calendar_events, :city, :string
    add_column :calendar_events, :state_id, :integer
    add_column :calendar_events, :zipcode, :string
    add_column :calendar_events, :longitude, :float
    add_column :calendar_events, :latitude, :float
    add_column :calendar_events, :slug, :string
  end
end
