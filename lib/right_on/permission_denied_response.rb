module RightOn
  class PermissionDeniedResponse
    attr_reader :right_allowed, :roles_allowed, :controller_name

    def initialize(params, controller_action_options)
      @params = params
      allower = RightAllowed.new(controller_action_options[:controller], controller_action_options[:action])
      @right_allowed = RightOn::Right.all.detect { |right| allower.allowed?(right) }
      @roles_allowed = @right_allowed.roles if @right_allowed
      @controller_name = @params[:controller] unless @right_allowed
    end

    def text_message
      if @right_allowed
        <<-MESSAGE
You are not authorised to perform the requested operation.
Right required: #{@right_allowed}
This right is given to the following roles: #{@roles_allowed.map(&:title).join(", ")}.
Contact your system manager to be given this right.
MESSAGE
      else
        no_right_for_page
      end
    end

    def to_json
      {
        error: 'Permission Denied',
        right_allowed: (@right_allowed ? @right_allowed.name : no_right_for_page),
        roles_for_right: (@roles_allowed ? @roles_allowed.map(&:title) : no_roles_for_page)
      }
    end

    private

    def no_right_for_page
      "No right is defined for this page: #{@controller_name}. Contact your system manager to notify this problem."
    end

    def no_roles_for_page
      'N/A (as no right is assigned for this action)'
    end
  end
end
