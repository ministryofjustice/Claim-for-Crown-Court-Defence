require 'rails_helper'

RSpec.describe Stats::Graphs::SixMonthPeriod do
  subject(:graph_data) { described_class.new }

  describe '#call' do
    subject(:data_hash) { graph_data.call }

    let(:mon_name) do
      output = []
      6.times do |offset|
        month = (Time.current.end_of_month - offset.month).strftime('%b')
        output << month
      end
      output.reverse
    end

    let(:agfs_example) do
      [
        { name: 'AGFS 9', data: { mon_name[0] => 2, mon_name[1] => 0, mon_name[2] => 0,
                                  mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 10', data: { mon_name[0] => 0, mon_name[1] => 2, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 11', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 2,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 12', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 2, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 13', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 2, mon_name[5] => 0 } },
        { name: 'AGFS 14', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 2 } },
        { name: 'AGFS 15', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 1 } },
        { name: 'AGFS 16', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 2 } },
        { name: 'LGFS 9', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                  mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'LGFS 10', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'LGFS 11', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } }
      ]
    end

    let(:lgfs_example) do
      [
        { name: 'AGFS 9', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                  mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 10', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 11', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 12', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 13', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 14', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 15', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 16', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'LGFS 9', data: { mon_name[0] => 2, mon_name[1] => 1, mon_name[2] => 2,
                                  mon_name[3] => 1, mon_name[4] => 2, mon_name[5] => 1 } },
        { name: 'LGFS 10', data: { mon_name[0] => 1, mon_name[1] => 2, mon_name[2] => 1,
                                   mon_name[3] => 2, mon_name[4] => 1, mon_name[5] => 2 } },
        { name: 'LGFS 11', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } }
      ]
    end

    let(:mixed_example) do
      [
        { name: 'AGFS 9', data: { mon_name[0] => 1, mon_name[1] => 0, mon_name[2] => 0,
                                  mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 10', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 11', data: { mon_name[0] => 0, mon_name[1] => 2, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 12', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 1,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 13', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 2, mon_name[4] => 0, mon_name[5] => 0 } },
        { name: 'AGFS 14', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 1, mon_name[5] => 0 } },
        { name: 'AGFS 15', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 3 } },
        { name: 'AGFS 16', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 2 } },
        { name: 'LGFS 9', data: { mon_name[0] => 2, mon_name[1] => 0, mon_name[2] => 2,
                                  mon_name[3] => 0, mon_name[4] => 2, mon_name[5] => 0 } },
        { name: 'LGFS 10', data: { mon_name[0] => 0, mon_name[1] => 2, mon_name[2] => 0,
                                   mon_name[3] => 2, mon_name[4] => 0, mon_name[5] => 2 } },
        { name: 'LGFS 11', data: { mon_name[0] => 0, mon_name[1] => 0, mon_name[2] => 0,
                                   mon_name[3] => 0, mon_name[4] => 0, mon_name[5] => 0 } }
      ]
    end

    context 'when there are only agfs claims' do
      before do
        travel_to(5.months.ago) { create_list(:advocate_claim, 2, :agfs_scheme_9, :submitted) }
        travel_to(4.months.ago) { create_list(:advocate_claim, 2, :agfs_scheme_10, :submitted) }
        travel_to(3.months.ago) { create_list(:advocate_claim, 2, :agfs_scheme_11, :submitted) }
        travel_to(2.months.ago) { create_list(:advocate_claim, 2, :agfs_scheme_12, :submitted) }
        travel_to(1.month.ago) { create_list(:advocate_claim, 2, :agfs_scheme_13, :submitted) }
        create_list(:advocate_claim, 2, :agfs_scheme_14, :submitted)
        create_list(:advocate_claim, 1, :agfs_scheme_15, :submitted)
        create_list(:advocate_claim, 2, :agfs_scheme_16, :submitted)
      end

      it 'returns the correct fee scheme keys and results, including zeroed entries for LGFS' do
        is_expected.to eq(agfs_example)
      end
    end

    context 'when there are only lgfs claims' do
      before do
        travel_to(5.months.ago) do
          create_list(:litigator_claim, 2, :lgfs_scheme_9, :submitted)
          create_list(:litigator_claim, 1, :lgfs_scheme_10, :submitted)
        end
        travel_to(4.months.ago) do
          create_list(:litigator_claim, 1, :lgfs_scheme_9, :submitted)
          create_list(:litigator_claim, 2, :lgfs_scheme_10, :submitted)
        end
        travel_to(3.months.ago) do
          create_list(:litigator_claim, 2, :lgfs_scheme_9, :submitted)
          create_list(:litigator_claim, 1, :lgfs_scheme_10, :submitted)
        end
        travel_to(2.months.ago) do
          create_list(:litigator_claim, 1, :lgfs_scheme_9, :submitted)
          create_list(:litigator_claim, 2, :lgfs_scheme_10, :submitted)
        end
        travel_to(1.month.ago) do
          create_list(:litigator_claim, 2, :lgfs_scheme_9, :submitted)
          create_list(:litigator_claim, 1, :lgfs_scheme_10, :submitted)
        end
        create_list(:litigator_claim, 1, :lgfs_scheme_9, :submitted)
        create_list(:litigator_claim, 2, :lgfs_scheme_10, :submitted)
      end

      it 'returns the correct fee scheme keys and results, including zeroed entries for AGFS' do
        is_expected.to eq(lgfs_example)
      end
    end

    context 'when there are both agfs and lgfs claims' do
      before do
        travel_to(5.months.ago) do
          create_list(:litigator_claim, 2, :lgfs_scheme_9, :submitted)
          create_list(:advocate_claim, 1, :agfs_scheme_9, :submitted)
        end
        travel_to(4.months.ago) do
          create_list(:litigator_claim, 2, :lgfs_scheme_10, :submitted)
          create_list(:advocate_claim, 2, :agfs_scheme_11, :submitted)
        end
        travel_to(3.months.ago) do
          create_list(:litigator_claim, 2, :lgfs_scheme_9, :submitted)
          create_list(:advocate_claim, 1, :agfs_scheme_12, :submitted)
        end
        travel_to(2.months.ago) do
          create_list(:litigator_claim, 2, :lgfs_scheme_10, :submitted)
          create_list(:advocate_claim, 2, :agfs_scheme_13, :submitted)
        end
        travel_to(1.month.ago) do
          create_list(:litigator_claim, 2, :lgfs_scheme_9, :submitted)
          create_list(:advocate_claim, 1, :agfs_scheme_14, :submitted)
        end
        create_list(:litigator_claim, 2, :lgfs_scheme_10, :submitted)
        create_list(:advocate_claim, 3, :agfs_scheme_15, :submitted)
        create_list(:advocate_claim, 2, :agfs_scheme_16, :submitted)
      end

      it 'returns the correct fee scheme keys and results, including zeroed entries for AGFS' do
        is_expected.to eq(mixed_example)
      end
    end
  end

  describe '#title' do
    subject(:graph_title) { graph_data.title }

    before { travel_to(Time.zone.parse('2023-10-10')) }

    it { is_expected.to eq('May - October') }
  end
end
