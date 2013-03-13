ProductType.seed_once(:seed_id) do |t|
  t.name = "Commercial"
  t.seed_id = 1
end

ProductType.seed_once(:seed_id) do |t|
  t.name = "Open Source"
  t.seed_id = 2
end

ProductType.seed_once(:seed_id) do |t|
  t.name = "In-House"
  t.seed_id = 3
end

ProductType.seed_once(:seed_id) do |t|
  t.name = "SAAS"
  t.seed_id = 4
end

ProductType.seed_once(:seed_id) do |t|
  t.name = "PAAS"
  t.seed_id = 5
end