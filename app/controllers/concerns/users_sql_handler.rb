module UsersSqlHandler
  extend ActiveSupport::Concern

  def total_page_of_user_table(per_page)
    query = SQLQueries::COUNT_USERS

    total_count = execute_sql(query).first['total_count'].to_i

    (total_count.to_f / per_page).ceil
  end

  def create_new_user(generated_password)
    user_sql = SQLQueries::CREATE_NEW_USER
    generated_params = generated_params_with_password(generated_password)

    query_with_field_values = query_and_field_values_array_of_user(user_sql, generated_params)
    
    sanitize_and_execute_sql(query_with_field_values)
  end

  def show_user
    user_id = params[:id]

    user_sql = SQLQueries::SELECT_USER

    query_with_field_values = [user_sql, user_id]

    sanitize_and_execute_sql(query_with_field_values).to_a
  end

  def update_user
    user_id = params[:id]

    update_user_sql = SQLQueries::UPDATE_USER

    query_with_updated_field_values =  query_with_updated_field_values(update_user_sql, user_id)

    sanitize_and_execute_sql(query_with_updated_field_values)
  end

  def delete_user
    user_id = params[:id]

    delete_user_sql = SQLQueries::DELETE_USER

    sanitize_and_execute_sql([delete_user_sql, user_id])
  end

  private

  def query_and_field_values_array_of_user(query, generated_params)
    [
      query,
      generated_params[:first_name],
      generated_params[:last_name],

      generated_params[:date_of_birth],
      generated_params[:gender],
      generated_params[:address],
      generated_params[:password],
      generated_params[:email],
      generated_params[:phone],
      Time.current,
      Time.current
    ]
  end

  def query_with_updated_field_values(update_user_sql, user_id)
    update_user_params = user_params
    [
      update_user_sql,
      update_user_params[:first_name],
      update_user_params[:last_name],
      update_user_params[:date_of_birth],
      update_user_params[:gender],
      update_user_params[:address],
      update_user_params[:email],
      update_user_params[:phone],
      Time.current,
      user_id
    ]
  end

  def sanitize_and_execute_sql(field_values_with_query)
    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, field_values_with_query)
    execute_sql(sanitized_sql)
  end
end