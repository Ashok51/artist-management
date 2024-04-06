# frozen_string_literal: true

class AddedUsersController < ApplicationController
  before_action :set_user, only: %i[edit update destroy]
  before_action :sanitize_gender, only: %i[create update]

  include DatabaseExecution
  include UsersSqlHandler
  require_relative './concerns/sql_queries'

  def index
    ActiveRecord::Base.transaction do
      @page_number = params[:page].to_i || 1
      per_page = 5

      @total_pages = total_page_of_user_table(per_page)

      query = SQLQueries::ORDERD_USERS_RECORD

      result = Pagination.paginate(query, @page_number, per_page)

      @added_users = User.build_user_objects_from_json(result)
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error("Error while fetching users: #{e.message}")
  end

  def new
    @added_user = User.new
  end

  def create
    ActiveRecord::Base.transaction do
      generated_password = Devise.friendly_token.first(8)
      user_hash = create_new_user(generated_password)
      @added_user = User.new(user_hash.first)

      # Send welcome email
      UserMailer.welcome_email(@added_user, generated_password).deliver_now
    end
    redirect_to added_users_path, notice: 'User created successfully.'
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error("Error while creating user: #{e.message}")

    render :new
  end

  def show
    user_hash = show_user

    @user = User.new(user_hash.first)
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      update_user
    end
    redirect_to added_users_url, notice: 'User updated successfully.'
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error("Error updating user: #{e.message}")

    redirect_to added_users_url, alert: 'Unable to update user.'
  end

  def destroy
    ActiveRecord::Base.transaction do
      delete_user
    end
    redirect_to added_users_url, notice: 'User deleted successfully.'
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error("Error while deleting user: #{e.message}")

    redirect_to added_users_url, alert: 'Unable to delete user.'
  end

  private

  def update_user_params
    user_params
  end

  def generated_params_with_password(generated_password)
    user_params.merge(password: generated_password,
                      password_confirmation: generated_password)
  end

  def set_user
    @added_user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :date_of_birth, :gender, :address)
  end

  def sanitize_gender
    params[:user][:gender] = User.genders[params[:user][:gender].to_sym]
  end
end
