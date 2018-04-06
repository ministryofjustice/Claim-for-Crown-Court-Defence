ActiveRecord::Base.establish_connection(
  :adapter  => "postgresql",
  :host     => "ar1ptn3voexnu0i.cefwt7a3h2hb.eu-west-1.rds.amazonaws.com",
  :username => "adp_disaster",
  :password => "uFkjagrA4rBLKpNoTfUXi9CpuobrmAfwuyVJtKQd2g",
  :database => "adp_disaster"
)

ActiveRecord::Base.establish_connection(
  :adapter  => "postgresql",
  :host     => "cccd-disaster-db-restored.cefwt7a3h2hb.eu-west-1.rds.amazonaws.com",
  :username => "adp_disaster",
  :password => "uFkjagrA4rBLKpNoTfUXi9CpuobrmAfwuyVJtKQd2g",
  :database => "adp_disaster"
)

ActiveRecord::Base.connection.execute("select count(*) from claims").to_a

