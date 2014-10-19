class AssignmentTypeWeightsController < ApplicationController

  # Students set their assignment type weights all at once
  def mass_edit
    @title =  "Editing #{current_student.name}'s #{term_for :weights}"
    @assignment_types = current_course.assignment_types
    respond_with @form = AssignmentTypeWeightForm.new(current_student, current_course)
  end

  def mass_update
    @form = AssignmentTypeWeightForm.new(current_student, current_course)
    @title =  "Editing #{current_student.name}'s #{term_for :weights}"

    @form.update_attributes(student_params)

    if @form.save
      if current_user_is_student?
        redirect_to syllabus_path , :notice => "You have successfully updated your #{(term_for :weight).titleize} choices!"
      else
        redirect_to multiplier_choices_path, :notice => "You have successfully updated #{current_student.name}'s #{(term_for :weight).capitalize} choices."
      end
    else
      render :mass_edit
    end
  end

  private

  def student_params
    params.require(:student).permit(:assignment_type_weights_attributes => [:assignment_type_id, :weight])
  end

  def interpolation_options
    { weights_term: term_for(:weights) }
  end
end
