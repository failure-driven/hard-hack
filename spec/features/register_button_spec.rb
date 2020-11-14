require "rails_helper"

feature "Register Button and view results from pressing it", js: true do
  scenario "User registers a button and clicks it" do
    When "Sam visits the remote button site" do
      visit root_path
    end

    Then "Sam sees all the related information about the fine product" do
      # not really worth testing all the things just yet
    end

    When "Sam decides to check out the software button" do
      page.find("[data-testid=\"try-software-button-action\"]").click
    end

    And "registers a new software button" do
      fill_in "Email", with: "sam@button.com"
      current_host_and_port = URI::HTTP.build(
        host: Capybara.current_session.server.host,
        port: Capybara.current_session.server.port,
      )
      fill_in "Site", with: current_host_and_port
      # fill_in "SSID", with: "home-ssid"
      # fill_in "password", with: "home-ap-password"
      fill_in "External reference", with: "default_external_reference"
      # pending "add register button to the form"
      click_on "register"

      # binding.pry # uncomment this to pause the test prior to a failure
    end

    Then "He sees a success message and recievs an email with the link"
    # you get an email with a link
    # http://localhost/button/uuid-code-here

    When "he follows the link from the email and completes registration of his button"
    # code: unique-button-mac-address-identifier
    # name: _________________________________
    # mode: COUNTER
    # SUBMIT

    Then "he gets a success message and a link to his button and report page"
    # you get a success message and a link to the software button
    # http://localhost/software_button/uuid-code-here
    # [PRESS]
    # and a report link
    # http://localhost/button/uuid-code-here/report

    When "he visits the report page"

    Then "he sees no activity"

    When "he views the button and presses it 2 times"

    And "he visits the report page"

    Then "he sees 2 entries with time stamps"
    # pressed 8:01pm
    # pressed 8:00pm
    # < page 1, 2, 3 ...n >
  end

  scenario "User registers a button which is already registerd"

  scenario "Hardware button sends invalid registration request" do
    When "a hardware button makes a HTTP POST to register itself" do
      uri = URI(Capybara.current_session.server.base_url)
      @response = Net::HTTP.post_form(uri, {})
    end

    Then "I get a json resonse with error and status 422 unprocessable entity" do
      wait_for { @response.code }.to eq "422"
      wait_for { JSON.parse(@response.body) }.to eq(
        {
          "error" => "Validation failed: Email can't be blank, Site can't be blank, External reference can't be blank",
        },
      )
    end
  end

  scenario "Hardware button sends valid registration request" do
    When "a hardware button makes a HTTP POST to register itself" do
      uri = URI(Capybara.current_session.server.base_url)
      @response = Net::HTTP.post_form(
        uri,
        { "button[email]" => "m@m",
          "button[site]" => Capybara.current_session.server.base_url,
          "button[external_reference]" => "1234", },
      )
    end

    Then "I get a json response with success and status 201 successfully created" do
      wait_for { @response.code }.to eq "201"
      wait_for { JSON.parse(@response.body) }.to eq(
        {
          "button_url" => "#{Capybara.current_session.server.base_url}/buttons/#{Button.first.id}",
        },
      )
    end
  end

  scenario "User attempts to register software a button with invalid input" do
    When "Sam registers a software button not filling in anything" do
      visit new_software_button_path
      click_on "register"
    end

    Then "he is show validation errors" do
      wait_for do
        page.find(".alert [data-testid=\"message\"]").text
      end.to eq "Creating button is currently not implemented"
    end
  end
end
