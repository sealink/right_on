module RightOn
  module ControllerAdditions
    def authorize_action!
      controller = (self.rights_from || params[:controller]).to_s
      action = params[:action].to_s

      return if can_access_controller_action?(controller, action)

      fail CanCan::AccessDenied, "You are not authorized to access this page."
    end

    def can_access_controller_action?(controller, action)
      (can?(:access, controller) && !Right.where(subject: controller + '#' + action).exists?) ||
        can?(:access, controller + '#' + action)
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include RightOn::ControllerAdditions
  end
end
