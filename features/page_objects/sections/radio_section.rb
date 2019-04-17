class RadioSection < SitePrism::Section
    element :label, 'label'
  
    def click
      label.click
    end
 end