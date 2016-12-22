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

