require 'json'
require 'caliper'
require 'caliper/entities/learning_context'
require 'caliper/entities/session'
require 'caliper/event/session_event'

require 'caliper/entities/lis/course_section'
require 'caliper/entities/lis/person'
require 'caliper/profiles/session_profile'


# integrates with IMS Caliper library
module Caliper_Integration

	def log_gradecraft_login_event(current_user, current_course)
		# caliper
		session_profile = Caliper::Profiles::SessionProfile.new

		# use default hostname and port of localhost:1180
		cube = Cube::Client.new 'localhost'

		## Build the gradecraft Learning Context
		learning_context = build_gradecraft_learning_context(current_user.id, current_course)

		## Action
		key = Caliper::Profiles::SessionActions::LOGGED_IN

		## Build target
		target = build_gradecraft_app()

		## Build generated session
		session_id = "#{current_course.id}-#{current_user.id}-#{current_student.try(:id)}"
		generated = build_session_start(session_id, current_user.id)

		## Build event
		event = build_gradecraft_login_event(learning_context, key, target, generated)

		json_str = JSON.generate(event).to_s

		cube.send "request", Time.now.utc, session_id, value: JSON.generate(event).to_s
	end

	def build_gradecraft_learning_context(current_user_id, current_course)
		learning_context = Caliper::Entities::LearningContext.new
		learning_context.ed_app = build_gradecraft_app()
		learning_context.lis_organization = build_gradecraft_course_section(current_course)
		learning_context.agent = build_user(current_user_id)
		return learning_context
	end

	def build_gradecraft_course_section(current_course)
		course_section = Caliper::Entities::LIS::CourseSection.new
		course_section.id = current_course.id
		course_section.semester = current_course.semester
		course_section.name = current_course.name
		course_section.course_number = current_course.courseno
		course_section.label = current_course.name
		course_section.date_created = ""
		course_section.date_modified = ""
		return course_section
	end

	def build_gradecraft_app
		software_application = Caliper::Entities::SoftwareApplication.new
		software_application.id = "https://github.com/UM-USElab/gradecraft-development"
		software_application.name = "Gradecraft"
		software_application.date_created = Time.now.utc
		software_application.date_modified = Time.now.utc
		software_application.description = nil
		return software_application
	end

	def build_user(current_user_id)
		person = Caliper::Entities::LIS::Person.new
		person.id = current_user_id
		person.name = nil
		person.date_modified = Time.now.utc
		return person
	end

	def build_session_start(session_id, user_id)
		session = Caliper::Entities::Session.new
		p ActiveRecord::SessionStore::Session
		session.id = session_id
		session.name = "gradecraft session #{session_id}"
		session.actor = build_user(user_id)
		now_time = Time.now.utc
		session.date_created = now_time
		session.date_modified = now_time
		session.started_at_time = now_time
		return session
	end

	def build_gradecraft_login_event(learning_context, action_key, target, generated)
		session_event = Caliper::Event::SessionEvent.new
		session_event.ed_app = learning_context.ed_app
		session_event.lis_organization = learning_context.lis_organization
		session_event.actor = learning_context.agent
		session_event.action = action_key
		session_event.object = learning_context.ed_app
		session_event.target = learning_context.lis_organization
		session_event.generated = generated
		session_event.started_at_time = Time.now.utc
		session_event.ended_at_time = nil
		session_event.duration = nil
		return session_event
	end
end
