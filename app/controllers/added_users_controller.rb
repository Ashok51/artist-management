class AddedUsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]

  include SQLQueries
  include DatabaseExecution
  include UsersSqlHandler
  require_relative './concerns/sql_queries'

  def index
    @page_number = params[:page].to_i || 1
    per_page = 5

    @total_pages = total_page_of_user_table(per_page)

    query = SQLQueries::ORDERD_USERS_RECORD

    result = Pagination.paginate(query, @page_number, per_page)

    @added_users = User.build_user_objects_from_json(result)

  end

  def new
    @added_user = User.new
  end

  def create
    generated_password = Devise.friendly_token.first(8)
    @added_user = User.new(generated_params_with_password(generated_password))
    if @added_user.save
      # Send welcome email
      UserMailer.welcome_email(@added_user, generated_password).deliver_now

      redirect_to added_users_path, notice: 'User created successfully.'
    else
      render :new
    end
  end

  def edit
    @added_user = User.find(params[:id])
  end

  def update
    @added_user = User.find(params[:id])
    if @added_user.update(user_params)
      redirect_to root_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @added_user.destroy!

    redirect_to added_users_url, notice: 'User deleted successfully.'
  end

  private

  def generated_params_with_password(generated_password)
    user_params.merge(password: generated_password,
                      password_confirmation: generated_password)
  end

  def set_user
    @added_user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :phone, :date_of_birth, :gender, :address)
  end
end
