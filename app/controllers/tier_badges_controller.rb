class TierBadgesController< ApplicationController
  before_action :find_tier_badge, only: [:update, :destroy]

  respond_to :html, :json

  def new
    @tier = Tier.new params[:tier]
    respond_with @tier, layout: false
  end

  def edit
  end

  def create
    @tier_badge = TierBadge.create params[:tier_badge]
    respond_with @tier_badge, layout: false, serializer: ExistingTierBadgeSerializer
  end

  def destroy
    @tier_badge.destroy
    respond_with @tier_badge, layout: false
  end

  def show
  end

  def update
    @tier.update_attributes params[:tier]
    respond_with @tier, layout: false
  end

  def update_order
    Tier.update params[:tier_order].keys, params[:tier_order].values
    render nothing: true
  end

  private

  def serialized_tier
    ExistingTierSerializer.new(@tier.includes(:tiers)).to_json
  end

  def find_tier_badge
    @tier_badge = TierBadge.find params[:id]
  end
end
