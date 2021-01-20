# This is necessary in order to stub out ApplicationController
# methods that are declared as helpers.
#
# Declare the method here to raise an exception, and
# then in the spec, stub out the behaviour you need.
#
# Remember to include ViewSpecHelper in the spec, and call
# initialize_view_helpers, probably as a before(:each)
#

module ViewSpecHelper
  module ControllerViewHelpers
    def current_user_persona_is?(klass)
      raise 'Stub current_user if you want to test the behavior.'
    end
  end

  def initialize_view_helpers(view)
    view.extend ControllerViewHelpers
  end

  def within(selector)
    begin
      if scopes.empty?
        scopes << Capybara.string(rendered).find(selector)
      else
        scopes << rendered.find(selector)
      end
      yield rendered
    ensure
      scopes.pop
    end
  end

  def rendered
    scopes.last() || @rendered
  end

  def scopes
    @scopes ||= []
  end
end
