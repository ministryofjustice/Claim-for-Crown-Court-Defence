json.item do
  json.array! [
    {
      value: "#{@reporter.rejected[:percentage].round(2)}% (#{@reporter.rejected[:count]})",
      text: 'Rejected'
    },
    {
      value: "#{@reporter.authorised_in_part[:percentage].round(2)}% (#{@reporter.authorised_in_part[:count]})",
      text: 'Part authorised'
    },
    {
      value: "#{@reporter.authorised_in_full[:percentage].round(2)}% (#{@reporter.authorised_in_full[:count]})",
      text: 'Authorised'
    }
  ]
end
