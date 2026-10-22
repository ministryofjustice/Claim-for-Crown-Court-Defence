require 'rails_helper'
require Rails.root.join('db', 'migrate', '20260902090000_create_legacy_login_routes')
require Rails.root.join('db', 'migrate', '20261015120000_create_login_routes')
require Rails.root.join('db', 'migrate', '20261020113000_add_dual_login_tester_to_login_routes')

# Exercise each migration history against real PostgreSQL tables without changing the application tables.
# rubocop:disable-next RSpec/ExampleLength
RSpec.describe CreateLoginRoutes, :aggregate_failures do
  let(:connection) { ActiveRecord::Base.connection }
  let(:id_column) { connection.columns(:login_routes).find { |column| column.name == 'id' } }
  let(:legacy_migration) { CreateLegacyLoginRoutes.new }
  let(:upstream_migration) { described_class.new }
  let(:tester_migration) { AddDualLoginTesterToLoginRoutes.new }

  around do |example|
    schema = "login_routes_spec_#{SecureRandom.hex(6)}"
    original_path = connection.schema_search_path
    connection.create_schema(schema)
    begin
      connection.schema_search_path = schema
      connection.create_table(:users, id: :integer)
      connection.execute('INSERT INTO users (id) VALUES (1), (2)')
      example.run
    ensure
      connection.schema_search_path = original_path
      connection.drop_schema(schema, force: :cascade)
    end
  end

  def routes
    connection.select_all('SELECT * FROM login_routes ORDER BY id').to_a
  end

  def expect_upstream_constraints
    expect(id_column.default_function).to be_nil
    expect(connection.check_constraint_exists?(:login_routes, name: 'login_routes_login_method_check')).to be true
    expect(connection.foreign_key_exists?(:login_routes, :users, column: :id)).to be true
  end

  it 'creates and backfills the table on a fresh installation' do
    legacy_migration.migrate(:up)
    upstream_migration.migrate(:up)
    tester_migration.migrate(:up)

    expect(routes.map { |route| route.slice('id', 'login_method', 'dual_login_tester') }).to eq(
      [
        { 'id' => 1, 'login_method' => 'legacy', 'dual_login_tester' => false },
        { 'id' => 2, 'login_method' => 'legacy', 'dual_login_tester' => false }
      ]
    )
    expect_upstream_constraints
  end

  it 'preserves deployed pilot routes and approvals while backfilling only missing users' do
    legacy_migration.migrate(:up)
    tester_migration.migrate(:up)
    connection.execute("UPDATE login_routes SET login_method = 'entra', dual_login_tester = TRUE WHERE id = 1")
    existing_routes = routes
    connection.execute('INSERT INTO users (id) VALUES (3)')

    upstream_migration.migrate(:up)

    expect(routes.first(2)).to eq existing_routes
    expect(routes.last.slice('id', 'login_method', 'dual_login_tester')).to eq(
      'id' => 3, 'login_method' => 'legacy', 'dual_login_tester' => false
    )
    expect_upstream_constraints
  end

  it 'leaves an already deployed upstream table unchanged when applying the older version' do
    upstream_migration.migrate(:up)
    connection.execute("UPDATE login_routes SET login_method = 'entra' WHERE id = 1")
    existing_routes = routes

    legacy_migration.migrate(:up)

    expect(routes).to eq existing_routes
    expect_upstream_constraints
  end

  it 'rejects invalid historical login methods rather than silently changing them' do
    legacy_migration.migrate(:up)
    connection.execute("UPDATE login_routes SET login_method = 'invalid' WHERE id = 1")

    expect do
      connection.transaction(requires_new: true) { upstream_migration.migrate(:up) }
    end.to raise_error(ActiveRecord::StatementInvalid, /login_routes_login_method_check/)
    expect(routes.first['login_method']).to eq 'invalid'
  end

  it 'can roll back both creation migrations in reverse order' do
    legacy_migration.migrate(:up)
    upstream_migration.migrate(:up)

    upstream_migration.migrate(:down)
    legacy_migration.migrate(:down)

    expect(connection.table_exists?(:login_routes)).to be false
  end

  it 'keeps migration names unique without changing the deployed version numbers' do
    migrations = ActiveRecord::MigrationContext.new(Rails.root.join('db', 'migrate')).migrations
    expect(migrations.map(&:name).uniq.size).to eq migrations.size
    expect(migrations.select { |migration| migration.name.match?(/Create.*LoginRoutes/) }.map(&:version))
      .to contain_exactly(20_260_902_090_000, 20_261_015_120_000)
  end
end
