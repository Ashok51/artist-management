module DatabaseExecution
  def execute_sql(sql)
    ActiveRecord::Base.connection.execute(sql)
  end
end