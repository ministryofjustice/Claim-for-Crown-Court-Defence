module XpathHelper


# examples;
# last_xpath_index("/html/body/div[4]/div[3]")
#  => 3
# last_xpath_index("/html/body/div[4]/div[3]/main/table/thead/tr/th[9999]")
#  => 9999
# last_xpath_index("/html/body/div[4]/div[3]/main/table/thead/tr/th[9999]/a")
# => 9999
  def last_xpath_index(path)
    path.slice(path.rindex(/\[\d+\]/)+1,path.length).partition(/\d+/)[1]
  end

end

World(XpathHelper)