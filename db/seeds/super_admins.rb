if User.find_by(email: 'superadmin@example.com').blank?
  user = User.create!(
    first_name: 'Adam',
    last_name: 'Smith',
    email: ENV['SUPERADMIN_USERNAME'],
    password: ENV['SUPERADMIN_PASSWORD'],
    password_confirmation: ENV['SUPERADMIN_PASSWORD']
  )

  super_admin = SuperAdmin.new
  super_admin.user = user
  super_admin.save!
end
