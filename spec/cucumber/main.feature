Feature: Using the MailFred extension

  @dev
  Scenario: First start
    Then I should see the welcome dialog
    When I click the welcome dialog OK button
    When I click the auth dialog OK button
    Then I should see the auth popup
    When I open the first email in the conversation view
    Then I should see the MailFred button
