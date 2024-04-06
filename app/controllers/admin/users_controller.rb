# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :set_user, only: %i[edit update destroy]
    before_action :sanitize_gender, only: %i[create update]

    include DatabaseExecution
    include UsersSqlHandler
    require_relative '../concerns/sql_queries'

    rescue_from ActiveRecord::StatementInvalid, with: :handle_database_error

    def index
      fetch_users
    end

    def new
      @admin_user = User.new
    end

    def create
      ActiveRecord::Base.transaction do
        create_user_with_email
      end
      redirect_to admin_users_path, notice: 'User created successfully.'
    end

    def show
      fetch_user
    end

    def edit; end

    def update
      ActiveRecord::Base.transaction do
        update_user_record
      end
      redirect_to admin_users_url, notice: 'User updated successfully.'
    end

    def destroy
      ActiveRecord::Base.transaction do
        delete_user_record
      end
      redirect_to admin_users_url, notice: 'User deleted successfully.'
    end

    private

    def fetch_users
      @page_number = params[:page].to_i || 1
      per_page = 5

      @total_pages = total_page_of_user_table(per_page)

      query = SQLQueries::ORDERD_USERS_RECORD

      result = Pagination.paginate(query, @page_number, per_page)

      @admin_users = User.build_user_objects_from_json(result)
    end

    def create_user_with_email
      generated_password = Devise.friendly_token.first(8)
      user_hash = create_new_user(generated_password)
      @admin_user = User.new(user_hash.first)

      # Send welcome email
      UserMailer.welcome_email(@admin_user, generated_password).deliver_now
    end

    def fetch_user
      user_hash = show_user
      @user = User.new(user_hash.first)
    end

    def update_user_record
      update_user
    end

    def delete_user_record
      delete_user
    end

    def set_user
      @admin_user = User.find(params[:id])
    end

    def sanitize_gender
      params[:user][:gender] = User.genders[params[:user][:gender].to_sym]
    end

    def user_params
      params.require(:user)
            .permit(:first_name, :last_name, :email, :phone, :date_of_birth, :gender, :address)
    end

    def generated_params_with_password(generated_password)
      user_params.merge(password: generated_password,
                        password_confirmation: generated_password)
    end

    def handle_database_error(exception)
      Rails.logger.error("Database error: #{exception.message}")
      flash.now[:alert] = 'Database operation failed.'
      render :new
    end
  end
end
