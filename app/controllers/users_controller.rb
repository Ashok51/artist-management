class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    # Generate a random password
    generated_password = Devise.friendly_token.first(8)
    
    # Arrange parameters with the generated password
    user_params_with_password = user_params.merge(password: generated_password, password_confirmation: generated_password)

    @user = User.new(user_params_with_password)
    if @user.save
      redirect_to users_path, notice: 'User created successfully.'
    else
      render :new
    end
  end

  def update 
  end

  def delete
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name,
                                  :gender, :date_of_birth, :address,
                                  :phone)
  end
end