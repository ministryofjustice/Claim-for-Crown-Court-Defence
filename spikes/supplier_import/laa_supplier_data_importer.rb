require 'xmlsimple'

class LaaImportedSupplier < ApplicationRecord
end

class LaaSupplierDataImporter
  def initialize
    file_path = File.join(ENV['HOME'], 'Downloads', 'DtSuppData1.xml')
    @doc = XmlSimple.xml_in(file_path)
  end

  def run
    @doc['record'].each do |rec|
      lis = LaaImportedSupplier.new
      rec.each do |attr, values|
        lis.send "#{attr}=", values.first
      end
      lis.save!
      puts "saved #{lis.accCode}"
    end
  end
end

# load "#{Rails.root}/spikes/supplier_import/laa_supplier_data_importer.rb"
# LaaSupplierDataImporter.new.run
