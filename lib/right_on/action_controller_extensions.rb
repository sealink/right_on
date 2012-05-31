module RightOn

  module ActionControllerExtensions

    def self.included(base)
      base.module_eval <<-EVAL
        helper_method :access_allowed?
      EVAL
    end

    # Checks the access privilege of the user and renders permission_denied page if required
    def verify_rights
      access_allowed?(params.slice(:controller, :action)) || permission_denied
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
      @right_allowed = Right.all.detect{|right| right.allowed?(params.slice(:controller, :action))}
      @roles_allowed = @right_allowed.roles if @right_allowed
      @controller_name = params[:controller] unless @right_allowed

      if request.xhr?
        render :update do |page|
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
      else
        respond_to do |format|
          format.html { render :template => 'permission_denied' }
          format.json do
            render :json => {
              :error => 'Permission Denied',
              :right_allowed => @right_allowed.try(:name),
              :roles_for_right => @roles_allowed.map(&:title)
            }
          end
        end
      end

      false
    end

  end

end
