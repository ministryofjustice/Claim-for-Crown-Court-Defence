json.item do
  json.array! [
    {
      value: @reporter.paid_in_full,
      text: 'Paid'
    },
    {
      value: @reporter.paid_in_part,
      text: 'Part paid'
    },
    {
      value: @reporter.rejected,
      text: 'Rejected'
    }
  ]
end
