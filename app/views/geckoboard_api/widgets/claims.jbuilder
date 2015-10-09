json.item do
  json.array! [
    {
      value: @reporter.rejected[:percentage],
      text: 'Rejected'
    },
    {
      value: @reporter.authorised_in_part[:percentage],
      text: 'Part authorised'
    },
    {
      value: @reporter.authorised_in_full[:percentage],
      text: 'Authorised'
    }
  ]
end
