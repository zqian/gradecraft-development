require "test_helper"

describe MetricBadge do
  before do
    @metric_badge = MetricBadge.new
  end

  it "must be valid" do
    @metric_badge.valid?.must_equal true
  end
end
