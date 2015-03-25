class EventLogger
  @queue= :eventlogger
  
  def self.perform(event_type, data={})
  	p "Starting EventLogger"
    attributes = {event_type: event_type, created_at: Time.now}
    Analytics::Event.create(attributes.merge(data))
  end
end
