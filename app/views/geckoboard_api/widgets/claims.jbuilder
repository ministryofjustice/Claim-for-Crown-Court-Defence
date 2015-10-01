json.item do
  json.array! [
    {
      value: @reporter.authorised_in_full,
      text: 'Authorised'
    },
    {
      value: @reporter.authorised_in_part,
      text: 'Part authorised'
    },
    {
      value: @reporter.rejected,
      text: 'Rejected'
    }
  ]
end
