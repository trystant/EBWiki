# https://semaphoreci.com/community/tutorials/setting-up-the-bdd-stack-on-a-new-rails-4-application
# This is not finished

Given(/^I am on the show page$/) do
	@state = FactoryGirl.create(:state)
	@article = FactoryGirl.create(:article, state_id: @state.id)
  visit article_path(@article)
end

When(/^visit the history page$/) do
  pending # express the regexp above with the code you wish you had
end