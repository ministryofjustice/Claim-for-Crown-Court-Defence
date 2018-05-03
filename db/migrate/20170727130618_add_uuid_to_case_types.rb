class AddUuidToCaseTypes < ActiveRecord::Migration[4.2]

  UUIDS = %w(
    a05f6ee1-c9fb-4069-9789-1f68aea85fb8
    2c4bc4a3-9246-4841-9813-a1e03b8d3a05
    4e996aed-2dc9-424c-9862-b52b02fe48b3
    7c27f365-9cd3-4993-b78d-2065ecb97fd9
    b6d8bc8e-7238-458e-a645-c0e382a5afd1
    60e835cf-911f-49ef-9376-8b2a55494aa6
    5db5134a-afac-4f32-bc88-e9a6a54b4df9
    5d646fd1-b50b-4aba-9435-de5b9377bd8a
    03cb932c-d700-415b-a328-15839d88dc36
    b342a476-887d-46b3-b2dc-32da2dd138ec
    c6197718-08c5-4943-a2e1-2c5bf71bcfa8
    f96b265a-f972-4872-a598-e78de4fcab83
    5e1d62c4-b119-4b48-9811-3c92c93dee9e
  ).freeze

  def up
    add_column :case_types, :uuid, :uuid, default: 'uuid_generate_v4()', index: true

    # ensure all environment DBs have the same UUIDs because they will be required by CCR
    puts "-- updating case_types UUIDs to consistent values"
    CaseType.all.each do |ct|
      ct.update!(uuid: UUIDS[ct.id-1])
    end
  end

  def down
    remove_column :case_types, :uuid, :uuid, default: 'uuid_generate_v4()', index: true
  end
end
