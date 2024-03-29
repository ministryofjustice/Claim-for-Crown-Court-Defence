World(FactoryBot::Syntax::Methods)

require Rails.root.join('spec', 'support', 'factory_helpers')
require Rails.root.join('spec', 'support', 'scheme_date_helpers')

# FactoryBot::SyntaxRunner can be extended to add helpers
FactoryBot::SyntaxRunner.include(FactoryHelpers,
                                 SchemeDateHelpers,
                                 ActiveSupport::Testing::TimeHelpers)
