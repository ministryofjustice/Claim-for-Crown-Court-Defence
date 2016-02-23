require 'rails_helper'

describe CaseType do
  it_behaves_like 'roles', CaseType, CaseType::ROLES

end