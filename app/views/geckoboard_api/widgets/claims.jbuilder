json.item do
  json.array! [
    {
      value: @reporter.rejected,
      text: 'Rejected'
    },
    {
      value: @reporter.authorised_in_part,
      text: 'Part authorised'
    },
    {
      value: @reporter.authorised_in_full,
      text: 'Authorised'
    }
  ]
end
