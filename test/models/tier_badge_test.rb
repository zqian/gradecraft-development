require "test_helper"

describe TierBadge do
  before do
    @tier_badge = TierBadge.new
  end

  it "must be valid" do
    @tier_badge.valid?.must_equal true
  end
end
