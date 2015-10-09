json.item do
  json.array! [
    {
      value: @reporter.rejected[:percentage],
      text: 'Rejected'
    },
    {
      value: @reporter.authorised_in_part[:count],
      text: 'Part authorised'
    },
    {
      value: @reporter.authorised_in_full[:percentage],
      text: 'Authorised'
    }
  ]
end
