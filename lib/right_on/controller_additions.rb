module RightOn
  module ControllerAdditions
    def self.included(base)
      base.module_eval do
        class_attribute :rights_from
        class_attribute :permission_denied_layout
      end
    end

    private

    def authorize_action!
      controller = (self.rights_from || params[:controller]).to_s
      action = params[:action].to_s

      return if can_access_controller_action?(controller, action)

      fail CanCan::AccessDenied, "You are not authorized to access this page."
    end

    def can_access_controller_action?(controller, action)
      (can?(:access, controller) && !Right.where(ccr_subject: controller + '#' + action).exists?) ||
        can?(:access, controller + '#' + action)
    end

    def access_granted?
      can? :access, [params[:controller], params[:action]].join('#')
    end

    def rescue_access_denied(exception)
      @permission_denied_response = RightOn::PermissionDeniedResponse.new(params, controller_action_options)

      respond_to do |format|
        format.html do
          render status:   :unauthorized,
                 template: 'permission_denied',
                 layout:   ( permission_denied_layout || false )
        end

        format.json do
          render status: :unauthorized, json: @permission_denied_response.to_json
        end
      end
    end

    def controller_action_options
      opts = params.slice(:controller, :action)
      opts[:controller] = rights_from.to_s if rights_from
      opts
    end
  end
end
