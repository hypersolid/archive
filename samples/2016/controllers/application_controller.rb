module Core
  class ApplicationController < ::ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    # protect_from_forgery with: :exception
    protect_from_forgery with: :null_session

    before_action :authenticate_user!
    before_action :include_current_user
    before_action :include_settings
    after_action :prolongate_access_token

    rescue_from ActiveRecord::RecordNotFound do |exception|
      logger.error("Error: #{exception.message}")
      logger.error(exception.backtrace) if Settings.debug_mode
      @error_message = '404'
      render template: 'core/errors/404', status: 404
    end

    private

    def include_current_user
      return unless request.format.html?
      return unless current_user
      gon.current_user = current_user
    end

    def include_settings
      return unless request.format.html?
      gon.settings = settings
    end

    def settings
      {
        frontend_host: Settings.frontend.host,
        users: ::ActiveModel::ArraySerializer.new(users).as_json,
        user_roles: Core::User::ROLES
      }
    end

    def users
      @users ||= User.all
    end

    # get default mate resource
    def mate_resource
      # backward compatibility. @todo remove it after use "mate_for" for every element
      return controller_path.classify.constantize unless Mate.allow_override

      resource_name = controller_name.to_sym
      fail "Resource '#{resource_name}' not defined in lib/mate.rb" unless Mate.mappings[controller_name.to_sym].present?
      Mate.mappings[controller_name.to_sym].model
    end

    def user_token
      request.headers[Mate::User.token_header]
    end

    def prolongate_access_token
      Mate::AccessToken.prolongate(user_token)
    end
  end
end
