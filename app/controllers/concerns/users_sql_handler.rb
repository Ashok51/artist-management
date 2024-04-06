module UsersSqlHandler
  extend ActiveSupport::Concern

  def total_page_of_user_table(per_page)
    query = SQLQueries::COUNT_USERS

    total_count = execute_sql(query).first['total_count'].to_i

    (total_count.to_f / per_page).ceil
  end

  # def total_page_of_a_table(per_page)
  #   query = SQLQueries::COUNT_ARTISTS

  #   total_count = execute_sql(query).first['total_count'].to_i

  #   (total_count.to_f / per_page).ceil
  # end
end