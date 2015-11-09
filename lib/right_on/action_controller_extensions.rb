module RightOn

  module ActionControllerExtensions

    def self.included(base)
      base.module_eval do
        helper_method :access_allowed?, :access_allowed_to_controller?
        class_attribute :rights_from
        class_attribute :permission_denied_layout
      end
    end

    # Checks the access privilege of the user and renders permission_denied page if required
    def verify_rights
      access_allowed?(controller_action_options) || permission_denied
    end

    # Checks the access privilege for a controller
    def access_allowed_to_controller?(controller)
      controller_class = "#{controller.to_s.camelcase}Controller".safe_constantize

      # Handle inheritance of rights
      if controller_class && controller_class.rights_from.present?
        controller = controller_class.rights_from.to_s
      end

      access_allowed?(controller)
    end

    # Checks the access privilege of the user and returns true or false
    def access_allowed?(opts={})
      if opts.is_a?(String)
        controller, action = opts.split('#')
        opts = {:controller => controller, :action => action}
      end
      opts[:controller] ||= params[:controller]
      opts[:action]     ||= params[:action]
      current_user.rights.any? { |r| r.allowed?(opts.slice(:controller, :action)) }
    end

    # Called if a security check determines permission is denied
    def permission_denied
      @permission_denied_response = RightOn::PermissionDeniedResponse.new(params, controller_action_options)

      respond_to do |format|
        format.html { render status: 401, template: 'permission_denied', layout: (permission_denied_layout || false) }
        format.json do
          render status: 401, json: @permission_denied_response.to_json
        end
        format.js do
          render :update, status: 401 do |page|
            page.alert(@permission_denied_layout.text_message)
          end
        end
      end

      false
    end

    def controller_action_options
      opts = params.slice(:controller, :action)
      opts[:controller] = rights_from.to_s if rights_from
      opts
    end

  end

end
