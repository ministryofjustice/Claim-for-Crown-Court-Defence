# EXAMPLE_DOC_TYPES is a hash of example files (locates in spec/fixtures/files) and their doctype
#
EXAMPLE_DOC_TYPES = {
  'repo_order_1.pdf'                      => 1,
  'repo_order_2.pdf'                      => 1,
  'repo_order_3.pdf'                      => 1,
  'LAC_1.pdf'                             => 2,
  'commital_bundle.pdf'                   => 3,
  'indictment.pdf'                        => 4,
  'judicial_appointment_order.pdf'        => 5,
  'invoices.pdf'                          => 6,
  'hardship.pdf'                          => 7,
  'previous_fee_advancements.pdf'         => 8,
  'other_supporting_evidence.pdf'         => 9,
  'justification_for_late_submission.pdf' => 10
}

STATES_TO_ADD_EVIDENCE_FOR = ['allocated',
                              'submitted',
                              'paid',
                              'redetermination',
                              'part_paid',
                              'awaiting_further_info',
                              'awaiting_info_from_court']

namespace :claims do

  desc "Delete all dummy docs after dropping the DB"
  task :delete_docs do
    FileUtils.rm_rf('./public/assets/dev/images/')
    FileUtils.rm_rf('./public/assets/test/images/')
  end

  
  desc 'Loads dummy claims'
  task :demo_data => 'db:seed' do
    require File.dirname(__FILE__) + '/../demo_data/claim_generator'
    DemoData::ClaimGenerator.new.run
  end
end


  