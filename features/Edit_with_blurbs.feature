Feature: Edit article with blurbs
  In order to edit an article
  As an editor
  I want to add a summary of my edits

Scenario: Article Edit
  Given I have an article that needs an edit to the overview
  When I open the edit page,
  Then I should see the overview field