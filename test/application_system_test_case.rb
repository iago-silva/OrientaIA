require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1440, 1100 ] do |options|
    options.add_argument("no-sandbox")
    options.add_argument("disable-dev-shm-usage")
  end

  def navigate_and_wait
    previous_document = page.evaluate_script("performance.timeOrigin")
    yield

    # Avoid holding a DOM element across navigation: recent Chrome versions
    # can report detached nodes as UnknownError instead of StaleElementReferenceError.
    wait = Selenium::WebDriver::Wait.new(timeout: Capybara.default_max_wait_time)
    wait.until do
      page.evaluate_script("performance.timeOrigin !== #{previous_document.to_json} && document.readyState === 'complete'")
    end
  end

  def after_teardown
    # A fresh browser also isolates storage on recent Chrome versions, which
    # reject the wildcard origin used by Capybara 3.40's storage reset.
    Capybara.current_session.driver.quit
    super
  end
end
