Feature: My bootstrapped app kinda works
  In order to get going on coding my awesome app
  I want to have aruba and cucumber setup
  So I don't have to do it myself

  Scenario: App just runs
    When I get help for "pmirror"
    Then the exit status should be 0
    And the banner should be present
    And the banner should document that this app takes options
    And the following options should be documented:
      |--pattern|
      |--debug|
      |--localdir|
      |--exec|
      |--version|
    And the banner should document that this app's arguments are:
      |url|which is required|


  Scenario: Download a file
    When I successfully run `pmirror -p meh -l ../foo http://localhost:55555`
    Then the exit status should be 0
    And the following files should exist:
      |../foo/meh.txt|

  Scenario: Execute on local directory
    When I successfully run `pmirror -p meh -l ../foo -e "touch test" http://localhost:55555`
    Then the exit status should be 0
    And the following files should exist:
      |../foo/meh.txt|
      |../foo/test   |

  Scenario: Match multiple files
    When I successfully run `pmirror -p floo -l ../foo http://localhost:55555`
    Then the exit status should be 0
    And the following files should exist:
      | ../foo/floober.txt|
      | ../foo/floobah.txt|
    And the following files should not exist:
      | ../foo/mah.txt|
      | ../foo/meh.txt|

  Scenario: Match multiple patterns
    When I successfully run `pmirror -p '^floo.*','^mah.*' -l ../foo http://localhost:55555`
    Then the exit status should be 0
    And the following files should exist:
      | ../foo/floober.txt|
      | ../foo/floobah.txt|
      | ../foo/mah.txt|
    And the following files should not exist:
      | ../foo/meh.txt|



