require 'json'
require 'caliper'
require 'caliper/entities/learning_context'
require 'caliper/entities/session/session'
require 'caliper/entities/assessment/assessment'
require 'caliper/entities/outcome/predicted_grade'
require 'caliper/event/session_event'
require 'caliper/event/navigation_event'
require 'caliper/event/grade_predict_event'

require 'caliper/entities/lis/course_section'
require 'caliper/entities/lis/membership'
require 'caliper/entities/lis/roles'
require 'caliper/entities/lis/status'
require 'caliper/entities/agent/person'
require 'caliper/profiles/session_profile'
require 'caliper/profiles/assessment_profile'
require 'caliper/options'
require 'caliper/sensor'
require 'time'

# integrates with IMS Caliper library
module CaliperIntegration

	def log_gradecraft_course_navigation_event(current_user, current_course)
		p "caliper log"
               	# caliper
                options = get_options

                ## Build the gradecraft Learning Context
                learning_context = build_gradecraft_learning_context(current_user.id, current_course)

                ## Action
                key = Caliper::Profiles::ProfileActions::NAVIGATED_TO

                ## Build target
                target = build_gradecraft_app()

                ## no generated event
		generated = nil 

                ## Build event
                event = build_course_navigation_event(learning_context, key, target, generated)

                json_str = JSON.generate(event).to_s

                File.open('/usr/local/ctools/user/zqian/gradecraft-development/app/controllers/caliper_navigate_gradecraft.json', 'w') {|file| file.truncate(0) }
                File.open('/usr/local/ctools/user/zqian/gradecraft-development/app/controllers/caliper_navigate_gradecraft.json', 'w') { |file| file.write(json_str) }
                file = File.read('/usr/local/ctools/user/zqian/gradecraft-development/app/controllers/caliper_navigate_gradecraft.json')
                event_hash = JSON.parse(file)
                event = Caliper::Event::NavigationEvent.new
                event.from_json event_hash

                sensor = Caliper::Sensor.new( options)
		puts JSON.pretty_generate event

                # NOTE: To test sending events to an actual endpoint,
                response = sensor.send event
                p response
        end

	def build_course_navigation_event(learning_context, action_key, target, generated)
                navigate_event = Caliper::Event::NavigationEvent.new
                navigate_event.edApp = learning_context.ed_app
                navigate_event.group = learning_context.group
                navigate_event.actor = learning_context.agent
                navigate_event.action = action_key
                navigate_event.object = learning_context.ed_app
                navigate_event.target = learning_context.group
                navigate_event.generated = generated
                navigate_event.startedAtTime = get_now_time
                navigate_event.endedAtTime = get_now_time
                navigate_event.duration = nil
                return navigate_event
        end

	def log_gradecraft_login_event(current_user, current_course)
		p "caliper log"
		# caliper
		session_profile = Caliper::Profiles::SessionProfile.new
		
		options = get_options
		
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

		File.open('/usr/local/ctools/user/zqian/gradecraft-development/app/controllers/caliper_session_gradecraft.json', 'w') {|file| file.truncate(0) }
	 	File.open('/usr/local/ctools/user/zqian/gradecraft-development/app/controllers/caliper_session_gradecraft.json', 'w') { |file| file.write(json_str) }

		file = File.read('/usr/local/ctools/user/zqian/gradecraft-development/app/controllers/caliper_session_gradecraft.json')
		event_hash = JSON.parse(file)
		event = Caliper::Event::SessionEvent.new
		event.from_json event_hash

      		sensor = Caliper::Sensor.new( options)

      		# NOTE: To test sending events to an actual endpoint, 
		response = sensor.send event
		p response		
	end

        def log_gradecraft_predict_grade_event(current_course, current_user, user_role, assignment_id, predicted_score, possible_score)
               	# caliper
                options = get_options

                ## Build the gradecraft Learning Context
                learning_context = build_gradecraft_learning_context(current_user.id, current_course)

                ## Action
                key = "http://purl.imsglobal.org/vocab/caliper/v1/action#PredictedGrade"
                ## Build target
                target = build_gradecraft_app()
                ## Build generated session
                session_id = "#{current_course.id}-#{current_user.id}-#{current_student.try(:id)}"
		generated = Caliper::Entities::PredictedGrade.new
		generated.type = "http://purl.imsglobal.org/caliper/v1/PredictedGrade"
		generated.course_id = current_course.id
		generated.scored_by = "https://mcommunity.umich.edu/profile/#{current_user.id}"
		generated.student_id = "https://mcommunity.umich.edu/profile/#{current_user.id}" #TODO
		generated.user_role = user_role
		generated.assignment_id = assignment_id
		generated.predicted_score = predicted_score
		generated.possible_score = possible_score 
		# The Object being interacted with by the Actor  = Assessment)
		assessment = Caliper::Entities::Assessment::Assessment.new
		assessment.id = "http://gradecraft.deluxe.ctools.org/assignment/#{assignment_id}"
		assessment.name = "http://gradecraft.deluxe.ctools.org/assignment/#{assignment_id}"
		assessment.dateModified =  nil
		assessment.dateCreated =  nil
		assessment.datePublished =  nil
		assessment.version = "1.0"
		assessment.dateToActivate = nil
		assessment.dateToShow =  nil
		assessment.dateToStartOn = nil
		assessment.dateToSubmit = nil
		assessment.maxAttempts = 1
		assessment.maxSubmits = 1
		assessment.maxScore = possible_score

                ## Build event
                event = build_gradecraft_predict_grade_event(learning_context, key, target, generated, assessment)

                json_str = JSON.generate(event).to_s
                File.open('/usr/local/ctools/user/zqian/gradecraft-development/app/controllers/caliper_predict_gradecraft.json', 'w') {|file| file.truncate(0) }
                File.open('/usr/local/ctools/user/zqian/gradecraft-development/app/controllers/caliper_predict_gradecraft.json', 'w') { |file| file.write(json_str) }
                file = File.read('/usr/local/ctools/user/zqian/gradecraft-development/app/controllers/caliper_predict_gradecraft.json')
                event_hash = JSON.parse(file)
             	event = Caliper::Event::GradePredictEvent.new
                event.from_json event_hash

                sensor = Caliper::Sensor.new( options)

                # NOTE: To test sending events to an actual endpoint,
                response = sensor.send event
                p response
        end

	def get_options
		options = Caliper::Options.new
		options = {
                        'host'  => 'http://dev1.intellifylearning.com/v1custom/eventdata',
                        'sensorId' => '0945062D-C8A1-40D7-9834-C1659705EC5B',
                        'apiKey' => '_-kJMcjiSymICwhUaHULbg'
                }
		return options
	end

	def build_gradecraft_learning_context(current_user_id, current_course)
		learning_context = Caliper::Entities::LearningContext.new
		learning_context.ed_app = build_gradecraft_app()
		learning_context.group = build_gradecraft_course_section(current_course)
		learning_context.agent = build_user(current_user_id)
		return learning_context
	end

	def get_now_time
                return Time.now.utc.iso8601(3)
        end

	def build_gradecraft_course_section(current_course)
		course_section = Caliper::Entities::LIS::CourseSection.new
		course_section.id = "http://gradecraft.deluxe.ctools.org/courses/#{current_course.id}"
		course_section.academicSession = current_course.semester
		course_section.name = current_course.name
		course_section.courseNumber = current_course.courseno
		course_section.category = nil
		course_section.membership= []
		course_section.subOrganizationOf = nil
		course_section.dateCreated = get_now_time
		course_section.dateModified = nil
		return course_section
	end

	def build_gradecraft_app
		software_application = Caliper::Entities::Agent::SoftwareApplication.new
		software_application.id = "https://github.com/UM-USElab/gradecraft-development"
		software_application.name = "Gradecraft"
		software_application.hasMembership = []
		software_application.dateCreated = get_now_time
		software_application.dateModified = nil
		software_application.description = nil
		return software_application
	end

	def build_user(current_user_id)
		person = Caliper::Entities::Agent::Person.new
		person.id = "https://mcommunity.umich.edu/profile/#{current_user_id}"
		person.name = "#{current_user_id}"
		person.dateModified = nil
		membership1 = Caliper::Entities::LIS::Membership.new
    		membership1.id = "https://some-university.edu/membership/003"
   		membership1.member = "#{current_user_id}"
    		membership1.organization = "https://some-university.edu/politicalScience/2015/american-revolution-101/section/001/group/001"
    		membership1.roles = [Caliper::Entities::LIS::Roles::LEARNER]
    		membership1.status = Caliper::Entities::LIS::Status::ACTIVE
    		membership1.dateCreated = get_now_time
    		membership1.dateModified = nil
    		person.hasMembership = nil
		return person
	end

	def build_session_start(session_id, user_id)
		session = Caliper::Entities::Session::Session.new
		p ActiveRecord::SessionStore::Session
		session.id = session_id
		session.name = "gradecraft session #{session_id}"
		session.actor = build_user(user_id)
		session.dateCreated = get_now_time
		session.dateModified = get_now_time
		session.startedAtTime = get_now_time
		return session
	end

	def build_gradecraft_login_event(learning_context, action_key, target, generated)
		session_event = Caliper::Event::SessionEvent.new
		session_event.edApp = learning_context.ed_app
		session_event.group = learning_context.group
		session_event.actor = learning_context.agent
		session_event.action = action_key
		session_event.object = learning_context.ed_app
		session_event.target = learning_context.group
		session_event.generated = generated
		session_event.startedAtTime = get_now_time
		session_event.endedAtTime = get_now_time
		session_event.duration = nil
		return session_event
	end

	def build_gradecraft_predict_grade_event(learning_context, action_key, target, generated, assessment)
		predict_event = Caliper::Event::GradePredictEvent.new
               	predict_event.edApp = learning_context.ed_app
               	predict_event.group = learning_context.group
               	predict_event.actor = learning_context.agent
               	predict_event.action = action_key
               	predict_event.object = assessment
              	predict_event.target = learning_context.group
               	predict_event.generated = generated
                predict_event.startedAtTime = get_now_time
               	predict_event.endedAtTime = get_now_time
               	predict_event.duration = nil
               	return predict_event
        end
end
