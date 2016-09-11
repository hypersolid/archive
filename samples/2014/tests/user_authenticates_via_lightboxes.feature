Feature: User Signs Up
  In order to use the site
  As a user
  I want to be able to sign in and up via lightboxes

  @javascript
  Scenario: User should see welcome lightbox when NOT signed in
    When I go to the home page
    And I follow "Member Offers"
    Then I should see "Join LUX FIX"

  @javascript
  Scenario: User should be able to sign IN through lightboxes
    Given a user "pat@freelancing-gods.com"
    When I go to the home page
      And I follow "SIGN IN"
      And I wait 1 second 
      And I fill in "user[email]" with "pat@freelancing-gods.com" within ".sign-in.lightbox"
      And I fill in "user[password]" with "123456" within ".sign-in.lightbox"
      And I press "Sign in" within ".sign-in.lightbox"
    Then I should see the link "Shopping Bag"

  @javascript
  Scenario: User should be able to sign UP through lightboxes on the second page
    When I go to the home page
      And I follow "Member Offers"
      And I wait 1 second
      And I follow "Sign up" in ".main.lightbox"
      And I wait 1 second
      And I fill in "user[email]" with "pat@freelancing-gods.com" within ".sign-up.lightbox"
      And I fill in "user[password]" with "monkeys" within ".sign-up.lightbox"
      And I fill in "user[password_confirmation]" with "monkeys" within ".sign-up.lightbox"
      And I press "Join now" within ".sign-up.lightbox"
    Then I should see the link "Shopping Bag"

  @javascript
  Scenario: User should be able to see errors on sign IN through lightboxes 
    Given a user "pat@freelancing-gods.com"
    When I go to the home page
      And I follow "SIGN IN"
      And I wait 1 second 
      And I fill in "user[email]" with "patERROR@freelancing-gods.com" within ".sign-in.lightbox"
      And I fill in "user[password]" with "123456" within ".sign-in.lightbox"
      And I press "Sign in" within ".sign-in.lightbox"
    Then I should see "Invalid email or password"

  @javascript
  Scenario: User should be able to see errors on sign UP through lightboxes on the second page
    Given a user "pat@freelancing-gods.com"
    When I go to the home page
      And I follow "Member Offers"
      And I wait 1 second 
      And I follow "Sign up" in ".main.lightbox"
      And I wait 1 second
      And I fill in "user[email]" with "pat@freelancing-gods.com" within ".sign-up.lightbox"
      And I fill in "user[password]" with "monkeys" within ".sign-up.lightbox"
      And I fill in "user[password_confirmation]" with "monkeys" within ".sign-up.lightbox"
      And I press "Join now" within ".sign-up.lightbox"
    Then I should see "Email has already been taken"
