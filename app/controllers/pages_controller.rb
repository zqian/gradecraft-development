class PagesController < ApplicationController
  skip_before_filter :require_login

  def ping
    respond_to do |format|
      format.json { render json: { 'pong' => true } }
      format.html { render text: 'pong' }
    end
  end
end
