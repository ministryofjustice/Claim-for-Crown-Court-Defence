module TransferBrainHelpers
  extend ActiveSupport::Concern
  #
  # Hash elements:
  #
  # litigator type (new, original)
  #   - elected case (boolean)
  #     - transfer stage id (int)
  #       - case conclusion id (int) - * means any
  #         - attributes:
  #              - validity (boolean): whether combination is valid - use in validators
  #              - transfer fee full name (string): the description to display to Case workers (only) on the claim details page (show action)
  #              - allocation type (string): what allocation filter "queue" this combination should fall into - use in scopes for allocation filters
  #              - bill scenario (string): what CCLF application bill scenario should be exposed in CCLF JSON API for injection into that application
  #
  DATA_ITEM_COLLECTION_HASH =
  {
    "new"=>
      {
        true=>
          {
            10=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"elected case - up to and including PCMH transfer (new)", :allocation_type=>"Fixed", :bill_scenario=>'ST4TS0T3' }},
            20=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"elected case - before trial transfer (new)", :allocation_type=>"Fixed", :bill_scenario=>'ST4TS0T5'}},
            30=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil, :bill_scenario=>nil}},
            40=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil, :bill_scenario=>nil}},
            50=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"elected case - transfer before retrial (new)", :allocation_type=>"Fixed", :bill_scenario=>'ST4TS0T7'}},
            60=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil, :bill_scenario=>nil}},
            70=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil, :bill_scenario=>nil}}
          },
        false=>
          {
            10=>
              {
                30=>{ :validity=>true, :transfer_fee_full_name=>"up to and including PCMH transfer (new) - cracked", :allocation_type=>"Grad", :bill_scenario=>'ST3TS1T3'},
                50=>{ :validity=>true, :transfer_fee_full_name=>"up to and including PCMH transfer (new) - guilty plea", :allocation_type=>"Grad", :bill_scenario=>'ST3TS1T2'},
                10=>{ :validity=>true, :transfer_fee_full_name=>"up to and including PCMH transfer (new) - trial", :allocation_type=>"Grad", :bill_scenario=>'ST3TS1T4'}
              },
            20=>
              {
                30=>{ :validity=>true, :transfer_fee_full_name=>"before trial transfer (new) - cracked", :allocation_type=>"Grad", :bill_scenario=>'ST3TS2T3'},
                10=>{ :validity=>true, :transfer_fee_full_name=>"before trial transfer (new) - trial", :allocation_type=>"Grad", :bill_scenario=>'ST3TS2T4'}
              },
            30=>
              {
                20=>{ :validity=>true, :transfer_fee_full_name=>"during trial transfer (new) - retrial", :allocation_type=>"Grad", :bill_scenario=>'ST3TS3TA'},
                10=>{ :validity=>true, :transfer_fee_full_name=>"during trial transfer (new) - trial", :allocation_type=>"Grad", :bill_scenario=>'ST3TS3T4'}
              },
            40=>
              {
                "*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer after trial and before sentence hearing (new)", :allocation_type=>"Grad", :bill_scenario=>'ST3TS7T4'}
              },
            50=>
              {
                40=>{ :validity=>true, :transfer_fee_full_name=>"transfer before retrial (new) - cracked retrial", :allocation_type=>"Grad", :bill_scenario=>'ST3TS4T9'},
                20=>{ :validity=>true, :transfer_fee_full_name=>"transfer before retrial (new) - retrial", :allocation_type=>"Grad", :bill_scenario=>'ST3TS4TA'}
              },
            60=>
              {
                20=>{ :validity=>true, :transfer_fee_full_name=>"transfer during retrial (new) - retrial", :allocation_type=>"Grad", :bill_scenario=>'ST3TS5TA'}
              },
            70=>
              {
                "*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer after retrial and before sentence hearing (new)", :allocation_type=>"Grad", :bill_scenario=>'ST3TS6TA'}
              }
          }
      },
    "original"=>
      {
        true=>
          {
            10=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"elected case - up to and including PCMH transfer (org)", :allocation_type=>"Fixed", :bill_scenario=>'ST4TS0T2'}},
            20=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"elected case - before trial transfer (org)", :allocation_type=>"Fixed", :bill_scenario=>'ST4TS0T4'}},
            30=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil, :bill_scenario=>nil}},
            40=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil, :bill_scenario=>nil}},
            50=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"elected case - transfer before retrial (org)", :allocation_type=>"Fixed", :bill_scenario=>'ST4TS0T6'}},
            60=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil, :bill_scenario=>nil}},
            70=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil, :bill_scenario=>nil}}
          },
        false=>
        {
          10=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"up to and including PCMH transfer (org)", :allocation_type=>"Grad", :bill_scenario=>'ST2TS1T0'}},
          20=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"before trial transfer (org)", :allocation_type=>"Grad", :bill_scenario=>'ST2TS2T0'}},
          30=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"during trial transfer (org) - trial", :allocation_type=>"Grad", :bill_scenario=>'ST2TS3T0'}},
          40=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer after trial and before sentence hearing (org)", :allocation_type=>"Grad", :bill_scenario=>'ST2TS7T4'}},
          50=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer before retrial (org) - retrial", :allocation_type=>"Grad", :bill_scenario=>'ST2TS4T0'}},
          60=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer during retrial (org) - retrial", :allocation_type=>"Grad", :bill_scenario=>'ST2TS5T0'}},
          70=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer after retrial and before sentence hearing (org)", :allocation_type=>"Grad", :bill_scenario=>'ST2TS6TA'}}
        }
      }
  }.freeze

  class_methods do
    def data_item_collection_hash
      DATA_ITEM_COLLECTION_HASH
    end

    def bill_scenarios
      data_item_collection_hash.
        all_values_for(:bill_scenario).
        reject { |scenario| scenario.nil? }
    end
  end

  included do
    def data_item_collection_hash
      self.class.data_item_collection_hash
    end
  end
end
