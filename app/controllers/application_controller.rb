class ApplicationController < ActionController::Base
    before_action :authenticate_user!

    protect_from_forgery with: :exception
    before_action :update_allowed_parameters, if: :devise_controller?

    def after_sign_in_path_for(_resource)
        authenticated_root_path
    end

    def after_sign_out_path_for(_resource)
        unauthenticated_root_path
    end

    protected

    def update_allowed_parameters
        devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:username, :email, :password) }
        devise_parameter_sanitizer.permit(:account_update) do |u|
        u.permit(:username, :email, :password, :current_password)
        end
    end
end
