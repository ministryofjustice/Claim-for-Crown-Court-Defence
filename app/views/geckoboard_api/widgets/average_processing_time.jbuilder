json.item do
  json.array! [
    {
      text: "Average processing time: #{@reporter.average_processing_time_in_words}",
      type: 0
    }
  ]
end
