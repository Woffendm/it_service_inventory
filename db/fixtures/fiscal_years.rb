FiscalYear.seed_once(:year) do |t|
  t.year = Date.today.year
  t.active = true
end


@year = FiscalYear.find_by_year(Date.today.year)
unless @year.blank?
  EmployeeAllocation.where(:fiscal_year_id => nil).each do |allocation|
    allocation.fiscal_year_id = @year.id
    allocation.save
  end
  EmployeeProduct.where(:fiscal_year_id => nil).each do |allocation|
    allocation.fiscal_year_id = @year.id
    allocation.save
  end
end