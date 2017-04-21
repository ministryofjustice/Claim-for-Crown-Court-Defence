namespace :data do
  namespace :migrate do

    ########################################################################################################################
    ###########                                                                                               ##############
    ###########  DO NOT DELETE THIS TASK - IS NEEDED FOR THE BUILD UNTIL SUVH TIME AS THE BUILD IS CHANGED TO ##############
    ###########  USE THE DB SCHEMA RATHER THAN RUNNING ALL THE MIGRATIONS                                     ##############
    ###########                                                                                               ##############
    ########################################################################################################################
    desc 'Set fee types quantities to decimal for SPF, WPF, RNF, CAV, WOA'
    task :set_quantity_is_decimal => :environment do
      %w{ SPF WPF RNF RNL CAV WOA }.each do |code|
        recs = Fee::BaseFeeType.where(code: code).where.not(quantity_is_decimal: true)
        recs.each do |rec| rec.update(quantity_is_decimal: true)
        puts "Quantity is decimal set to TRUE for fee type #{code}"
        end
      end
    end

    desc 'update vat amounts'
    task :vat => :environment do
      Claim::BaseClaim.connection.execute('UPDATE disbursements SET vat_amount = 0.0 WHERE vat_amount IS NULL')
      Claim::BaseClaim.connection.execute('UPDATE expenses SET vat_amount = 0.0 WHERE vat_amount IS NULL')
      claim_ids = Claim::BaseClaim.pluck(:id)
      num_claims = claim_ids.size
      claim_ids.each_with_index do |claim_id, i|
        begin
          puts "Updated #{i} claims of #{num_claims}" if i % 1000 == 0
          claim = Claim::BaseClaim.find(claim_id)
          claim.update_disbursements_total
          claim.update_expenses_total
          claim.update_fees_total
          claim.save!
        rescue => err
          puts ">>>> ERROR saving #{claim_id} >>>>> #{err.class} :: #{err.message} "
        end
      end
    end

    desc 'Update the value band ids'
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

        original_fees_vat_amount = claim.fees_vat
        claim.fees.each { |f| f.save }
        claim.reload
        if claim.fees_vat != original_fees_vat_amount
          puts "    Original fees vat amount: #{original_fees_vat_amount}, newly calculated amount: #{claim.fees_vat}"
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

