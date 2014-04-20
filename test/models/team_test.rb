require "test_helper"

class TeamTest < ActiveSupport::TestCase

  def valid_params 
    { name: "Kirby Your Enthusiasm", course: courses(:videogames) }
  end

  def test_valid
    team = Team.new valid_params

    assert team.valid?, "Can't create with valid params: #{team.errors.messages}"
  end

  def test_invalid
    team = Team.new

    assert !team.valid?, "Can't create with valid params: #{team.errors.messages}"
  end

end
