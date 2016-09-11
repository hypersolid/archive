Feature: User searches compatable parts

  Background:
    Given part '0125-X2RH' by 'FEBEST' exists
      And part '0111-SXM10RH' by 'FEBEST' exists

  Scenario: Search by part exact part number
    When I'm on home page
      And I fill in the following within "#search-number-form":
        | keywords  | 0125-X2RH |
      And I press "search-number-form-commit"
    Then I should be on products page
   	  And I should see "0125-X2RH"
   	  And I should not see "0111-SXM10RH"

  Scenario: Search by mistyped part number
    When I'm on home page
      And I fill in the following within "#search-number-form":
        | keywords  | 01.25 X2 RH |
      And I press "search-number-form-commit"
    Then I should be on products page
   	  And I should see "0125-X2RH"
   	  And I should not see "0111-SXM10RH"
  	
  Scenario: Search by exact replacement part number
    When I'm on home page
      And I fill in the following within "#search-number-form":
        | keywords  | 48705-30100 |
      And I press "search-number-form-commit"
    Then I should be on products page
   	  And I should see "0125-X2RH"
   	  And I should not see "0111-SXM10RH"
   	  
  Scenario: Search by mistyped replacement part number
    When I'm on home page
      And I fill in the following within "#search-number-form":
        | keywords  | 48 705 30-100 |
      And I press "search-number-form-commit"
    Then I should be on products page
   	  And I should see "0125-X2RH"
   	  And I should not see "0111-SXM10RH"
   	  
  Scenario: Search product with no tecdoc binding
    When I'm on home page
      And part '2345 NO TECDOC' by 'FEBEST' exists
      And I fill in the following within "#search-number-form":
        | keywords  | 2345-NO-TECDOC |
      And I press "search-number-form-commit"
    Then I should be on products page
   	  And I should see "2345 NO TECDOC"

  Scenario: Search product replacement with no tecdoc binding
    When I'm on home page
      And part '2345 NO TECDOC' by 'FEBEST':'OE compatible: 4870530100, 4870530130' exists
      And I fill in the following within "#search-number-form":
        | keywords  | 4870530100 |
      And I press "search-number-form-commit"
    Then I should be on products page
   	  And I should see "2345 NO TECDOC"

  Scenario: Search product by incomplete part number
    When I'm on home page
      And I fill in the following within "#search-number-form":
        | keywords  | 0125 |
      And I press "search-number-form-commit"
    Then I should be on products page
   	  And I should not see "0125-X2RH"
   	  And I should not see "0111-SXM10RH"

  Scenario: Search product by incomplete part number with no tecdoc binding
    When I'm on home page
      And part '01001234' by 'FEBEST':'OE compatible: 4870530100, 4870530130' exists
      And I fill in the following within "#search-number-form":
        | keywords  | 0100 |
      And I press "search-number-form-commit"
    Then I should be on products page
   	  And I should not see "01001234"
   	  
  @javascript
  Scenario: Search product by model
  	Given part '01001234' by 'FEBEST' exists
      And part '01001234' is compatible to '1992 Toyota Corolla 123 ZXV'
      And part '01001235' by 'FEBEST' exists
      And part '01001235' is compatible to '2000 Subaru Outback 777 XYZ'
    When I'm on home page
      And I follow "ui-id-3"
      And I select "2000" from "year"
      And I select "Subaru" from "make"
      And I select "Outback" from "model"
      And I select "777 XYZ" from "spec"
      And I press "search-model-form-commit"
    Then I should be on products page
   	  And I should see "01001235"
   	  And I should not see "01001234"
   	  
  @javascript @vcr_search_by_vin
  Scenario: Search product by model
  	Given part '01001234' by 'FEBEST' exists
      And part '01001234' is compatible to '2007 TOYOTA FJ-CRUISER 123 ZXV'
      And part '01001235' by 'FEBEST' exists
      And part '01001235' is compatible to '2000 Subaru Outback 777 XYZ'
    When I'm on home page
      And I follow "ui-id-2"
      And I fill in "vin_code" with "JTEBU11F870058031"
    Then I should see "2007 TOYOTA FJ Cruiser"  
      And I press "search-vin-form-commit"
    Then I should be on products page
   	  And I should see "01001234"
   	  And I should not see "01001235"

   	  
   	  