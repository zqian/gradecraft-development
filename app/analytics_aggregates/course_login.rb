# TODO: refactor as CourseLoginFrequency type Aggregate::Average
class CourseLogin
  include Analytics::Aggregate

  field :course_id, type: Integer

  scope_by :course_id

  increment_keys "%{granular_key}.total" => lambda { |event, granularity, interval| self.frequency(interval, event.last_login_at, event.created_at) },
                 "%{granular_key}.count" => 1

  ## No 'all_time' key since frequency for all-time would be 0
  # course_id: 1,
  # yearly: {
  #   key: {
  #     total: %,
  #     count: %,
  #     average: %%
  #   }
  # },
  # monthly: {
  #   key: {
  #     total: %,
  #     count: %,
  #     average: %%
  #   }
  # },
  # weekly: {
  #   key: {
  #     total: %,
  #     count: %,
  #     average: %%
  #   }
  # },
  # daily: {
  #   key: {
  #     total: %,
  #     count: %,
  #     average: %%
  #   }
  # },
  # hourly: {
  #   key: {
  #     total: %,
  #     count: %,
  #     average: %%
  #   }
  # },
  # minutely: {
  #   key: {
  #     total: %,
  #     count: %,
  #     average: %%
  #   }
  # }

  def self.incr(event)
    super
    # TODO: calculage cached average
    # This is not yet possible in an update command without first performing a separate find() command.
    # See open MongoDB support request:
    # https://jira.mongodb.org/browse/SERVER-458
  end

  def self.frequency(interval, last_time, this_time)
    interval.to_f / (this_time.to_i - last_time.to_i)
  end
end
