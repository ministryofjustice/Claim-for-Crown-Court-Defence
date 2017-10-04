class FeeSummarySection < SitePrism::Section
  element :captionna, '.table-cation visuallyhidden'
  elements :names, 'tbody > tr > th'
  elements :values, 'tbody > tr > td'
  # sections :rows, 'tbody > tr' do
  #   def names
  #     rows.map { |row| row['th'] }
  #   end

  #   def values
  #     rows.map { |row| row['td']}
  #   end
  # end
end
