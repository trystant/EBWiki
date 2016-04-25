require 'rails_helper'

RSpec.describe Hashtag, type: :model do
  it "is invalid without a starting pound sign" do
    hashtag = build(:hashtag, letters: "hashtag")
    expect(hashtag).to be_invalid
  end
  it "is valid if it starts with a # sign" do
    hashtag = build(:hashtag)
    expect(hashtag).to be_valid
  end
end
