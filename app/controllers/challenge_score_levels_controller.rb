class ChallengeScoreLevelsController < ApplicationController

  before_filter :ensure_staff?

  def create
    @challenge_score_level = current_course.challenge_score_levels.new(params[:challenge_score_level])
    @challenge_score_level.save
  end

  def update
    @challenge_score_level = current_course.challenge_score_levels.find(params[:id])
    @challenge_score_level.update_attributes(params[:challenge_score_level])
    respond_with @challenge_score_level
  end

  def destroy
    @challenge_score_level = current_course.challenge_score_levels.find(params[:id])
    @challenge_score_level.destroy
    respond_with @challenge_score_level
  end
end