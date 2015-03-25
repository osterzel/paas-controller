Feature: application lifecycle

    Scenario: create an new application
       Given I have a paas api service
       When I create an application "testapp"
       Then I get an application json document for "testapp" with variable "name" and value "testapp"


    Scenario: I build a test application slug
	     Given I have a slugbuilder service
       When I post a tarball to the slugbuilder service
       Then I get a slug for my application 

    Scenario: change application url 
       Given I have a paas api service
       When I set variable "urls" to "testapp.domain.com" for application "testapp"
       Then I get an application json document for "testapp" with variable "urls" and value "testapp.domain.com"

    Scenario: change application docker image
        Given I have a paas api service
        When I set variable "docker_image" to "flynn/slugrunner" for application "testapp"
        Then I get an application json document for "testapp" with variable "docker_image" and value "flynn/slugrunner"

    Scenario: change application command
        Given I have a paas api service
        When I set variable "command" to "start web" for application "testapp"
        Then I get an application json document for "testapp" with variable "command" and value "start web"

    Scenario: set application slug
        Given I have a paas api service
        When I update the slug url for application "testapp"
        Then I wait for application "testapp" to reach state "RUNNING"
        And I am able to access the site on "testapp.domain.com"

    Scenario: add additional container
        Given I have a paas api service
        When I set variable "container_count" to "2" for application "testapp"
        Then I wait for application "testapp" to reach state "RUNNING"
        And I am able to access the site on "testapp.domain.com"
        And I get an application json document for "testapp" with variable "container_count" and value "2"

    Scenario: decrease containers to 1
        Given I have a paas api service
        When I set variable "container_count" to "1" for application "testapp"
        Then I wait for application "testapp" to reach state "RUNNING"
        And I am able to access the site on "testapp.domain.com"
        And I get an application json document for "testapp" with variable "container_count" and value "1"

    Scenario: add environment variables
        Given I have a paas api service
        When I set environment variable "TEST_VARIABLE" to "myvalue" for application "testapp"
        Then I wait for application "testapp" to reach state "RUNNING"
        And I am able to access the site on "testapp.domain.com"
        And I get an application json document for "testapp" with environment variable "TEST_VARIABLE" and value "myvalue"

#    Scenario: delete an application
#	     Given I have a paas api service
#	     When I delete an application "testapp"	
#	     Then I get a message confirming the application is removed