class MetricsController < ApplicationController
  before_action :find_metric, except: [:new, :create]

  respond_to :html, :json

  def new
    @metric = Metric.new params[:metric]
    respond_with @metric, layout: false
  end

  def edit
  end

  def create
    @metric = Metric.create params[:metric]
    respond_with @metric, layout: false
  end

  def destroy
    @metric.destroy
  end

  def show
  end

  def update
    @metric.update_attributes params[:metric]
    respond_with @metric, layout: false, status: :ok
  end

  private
  def find_metric
    @metric = Metric.find params[:id]
  end
end
