# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    reset_session
    new_user_session_path
  end
end
