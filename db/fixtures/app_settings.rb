AppSetting.seed_once do |s|
  s.code = "fte_hours_per_week"
  s.value = 40.0
end

AppSetting.seed_once do |t|
  t.code = "allocation_precision"
  t.value = 1.0
end

AppSetting.seed_once do |t|
  t.code = "current_fiscal_year"
  t.value = 2013
end