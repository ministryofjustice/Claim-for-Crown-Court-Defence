module DemoData

  def self.random_case_number
    ('A'..'Z').to_a.sample + rand(1..99999999).to_s.rjust(8,'0')
  end


  def self.random_advocate_category
    Settings.advocate_categories.sample
  end


  def self.random_indictment_number
    "INDICT-#{rand(10000)}"
  end

  def self.random_cms_number
    "CMS-#{rand(99)}-#{rand(999)}"
  end


end