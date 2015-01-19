class EventLogger
  include Sidekiq::Worker

  def perform(event_type, data={})
    attributes = {event_type: event_type, created_at: Time.now}
    Granalytics::Event.create(attributes.merge(data))
  end
end
