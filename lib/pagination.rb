module Pagination
  def self.paginate(query, page_number, per_page)
    page_number = [page_number.to_i, 1].max  # Ensure page number is not negative
    offset = (page_number - 1) * per_page

    paginated_query = <<-SQL
      #{query}
      LIMIT #{per_page}
      OFFSET #{offset}
    SQL

    ActiveRecord::Base.connection.execute(paginated_query)
  end
end
