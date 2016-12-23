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

    desc 'Run all outstanding data migrations'
    task :all => :environment do
      {
        'value_bands' => 'Recacalculate value bands where wrong',
      }.each do |task, comment|
        puts comment
        Rake::Task["data:migrate:#{task}"].invoke
      end
    end
  end
end

