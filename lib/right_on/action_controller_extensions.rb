module RightOn

  module ActionControllerExtensions

    def self.included(base)
      base.module_eval do
        helper_method :access_allowed?
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
      @right_allowed = Right.all.detect{|right| right.allowed?(controller_action_options)}
      @roles_allowed = @right_allowed.roles if @right_allowed
      @controller_name = params[:controller] unless @right_allowed

      respond_to do |format|
        format.html { render :status => 550, :template => 'permission_denied', :layout => (permission_denied_layout || false) }
        format.json do
          render :status => 550, :json => {
            :error => 'Permission Denied',
            :right_allowed => @right_allowed.try(:name) || 'No right assigned for this action. Please contact your system administrator',
            :roles_for_right => @roles_allowed ? @roles_allowed.map(&:title) : 'N/A (as no right is assigned for this action)'
          }
        end
        format.js do
          render :update, :status => 550 do |page|
            msg = if @right_allowed
              <<-MESSAGE
You are not authorised to perform the requested operation.
Right required: #{@right_allowed}
This right is given to the following roles: #{@roles_allowed.map(&:title).join(", ")}.
Contact your system manager to be given this right.
MESSAGE
            else
              <<-MESSAGE
No right is defined for this page: #{@controller_name}
Contact your system manager to notify this problem.
MESSAGE
            end
            page.alert(msg)
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
