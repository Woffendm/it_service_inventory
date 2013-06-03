AppSetting.seed_once(:code) do |s|
  s.code = "fte_hours_per_week"
  s.value = 40.0
end

AppSetting.seed_once(:code) do |t|
  t.code = "allocation_precision"
  t.value = 1.0
end

AppSetting.seed_once(:code) do |t|
  t.code = "current_fiscal_year"
  t.value = Date.today.year
end

AppSetting.seed_once(:code) do |t|
  t.code = "rest_api_key"
  t.value = "default"
end

AppSetting.seed_once(:code) do |t|
  t.code = "theme"
  t.value = ""
end