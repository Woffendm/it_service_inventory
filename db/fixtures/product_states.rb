ProductState.seed_once(:seed_id) do |t|
  t.name = "Alpha"
  t.seed_id = 1
end

ProductState.seed_once(:seed_id) do |t|
  t.name = "Beta"
  t.seed_id = 2
end

ProductState.seed_once(:seed_id) do |t|
  t.name = "Release Candidate"
  t.seed_id = 3
end

ProductState.seed_once(:seed_id) do |t|
  t.name = "General Availability (GA)"
  t.seed_id = 4
end

ProductState.seed_once(:seed_id) do |t|
  t.name = "Discontinued"
  t.seed_id = 5
end