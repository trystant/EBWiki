json.array!(@calendar_events) do |calendar_event|
  json.extract! calendar_event, :id
  json.url calendar_event_url(calendar_event, format: :json)
end
