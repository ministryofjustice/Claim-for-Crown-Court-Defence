namespace :data do
  namespace :migrate do

    desc 'Update the disbursement vat amount on all claims'
    task :value_bands => :environment do
      i = 0
      Claim::BaseClaim.find_each do |claim|
        i += 1
        vbid = Claims::ValueBands.band_id_for_claim(claim)
        if claim.value_band_id != vbid
          puts ">>>>>>>>>>>>>> updating claim #{claim.id} to value band #{vbid} #{__FILE__}:#{__LINE__} <<<<<<<<<<<<<<<<<\n"
          claim.update_columns(value_band_id: vbid)
        end
      end
      puts "#{i} claims examined"
    end


    desc 're-save all expenses in order to calculate VAT'
    task :save_expenses => :environment do
      ids = Claim::BaseClaim.where(state: ['draft', 'allocated', 'submitted', 'refused', 'redetermination', 'awaiting_written_reasons']).pluck(:id)
      ids.each do |claim_id|
        claim = Claim::BaseClaim.find claim_id
        puts "Processing claim #{claim_id} in state #{claim.state}"
        claim.expenses.each do |ex|
          original_vat_amount = ex.vat_amount
          ex.__send__(:calculate_vat)
          begin
            if ex.vat_amount != original_vat_amount
              puts "    Original vat amount: #{original_vat_amount}, newly calculated amount: #{ex.vat_amount}"
              puts "    Saving expense"
              ex.save!
            end
          rescue => err
            puts "ERROR #{err}"
            puts err.message
          end
        end
      end
    end

    desc 'Run all outstanding data migrations'
    task :all => :environment do
      {
        'value_bands' => 'Recalcalculate value bands where wrong',
      }.each do |task, comment|
        puts comment
        Rake::Task["data:migrate:#{task}"].invoke
      end
    end
  end
end

