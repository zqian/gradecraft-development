# spec/models/user_spec.rb

require 'spec_helper'

describe User do

  it "is valid with a first name, a last name, a username, and an email address" do
    user = User.new(first_name: 'Hermione', last_name: 'Granger', email: 'hermione.granger@hogwarts.edu', username: 'crookshanks')
    expect(user).to be_valid
  end

  it "is invalid without a first name" do
    expect(User.new(first_name: nil)).to have(1).errors_on(:first_name)
  end

  it "is invalid without a last name" do
    expect(User.new(last_name: nil)).to have(1).errors_on(:last_name)
  end

  it "is invalid without a username" do
    expect(User.new(username: nil)).to have(1).errors_on(:username)
  end

  it "is invalid without an email address" do
    pending
    expect(User.new(email: nil)).to have(3).errors_on(:email)
  end

  it "returns a user's full name as a string" do
    user = User.new(first_name: 'Hermione', last_name: 'Granger', email: 'hermione.granger@hogwarts.edu', username: 'crookshanks')
    expect(user.name).to eq 'Hermione Granger'
  end

end
