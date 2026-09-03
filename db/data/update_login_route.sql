UPDATE login_routes
SET login_method = 'entra',
    updated_at = CURRENT_TIMESTAMP
FROM users
WHERE login_routes.id = users.id
  AND LOWER(users.email) = LOWER('vince.chiu-test@devl.justice.gov.uk');
