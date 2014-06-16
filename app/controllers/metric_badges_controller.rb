class MetricBadgesController< ApplicationController
  before_action :find_metric_badge, only: [:update, :destroy]

  respond_to :html, :json

  def new
    @metric = Metric.new params[:metric]
    respond_with @metric, layout: false
  end

  def edit
  end

  def create
    @metric_badge = MetricBadge.create params[:metric_badge]
    respond_with @metric_badge, layout: false, serializer: ExistingMetricBadgeSerializer
  end

  def destroy
    @metric_badge.destroy
    respond_with @metric_badge, layout: false
  end

  def show
  end

  def update
    @metric.update_attributes params[:metric]
    respond_with @metric, layout: false
  end

  def update_order
    Metric.update params[:metric_order].keys, params[:metric_order].values
    render nothing: true
  end

  private

  def serialized_metric
    ExistingMetricSerializer.new(@metric.includes(:tiers)).to_json
  end

  def find_metric_badge
    @metric_badge = MetricBadge.find params[:id]
  end
end
