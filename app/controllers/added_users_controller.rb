class AddedUsersController < ApplicationController

  def index
    @added_users = User.all
  end

  def new
    @added_user = User.new
  end

  def create
    generated_password = Devise.friendly_token.first(8)
    user_params_with_password = user_params.merge(password: generated_password, password_confirmation: generated_password)
    @added_user = User.new(user_params_with_password)
    if @added_user.save
      # Send welcome email
      UserMailer.welcome_email(@added_user, generated_password).deliver_now

      redirect_to added_users_path, notice: 'User created successfully.'
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :phone, :date_of_birth, :gender, :address)
  end
end
