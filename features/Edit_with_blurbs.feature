Feature: Edit article with blurbs
  In order to send a clear update
  As an editor
  I want to add a summary of my edits

Scenario: Article Edit With Blurb
  Given I am on the show page
  And I follow "Edit"
  When I fill in "blurb" with "This is my edit summary"
  And I press "Update Article"
  And visit the history page
  Then I should see "This is my edit summary"
