module CCR
  module TestExpenses
    module_function

    def for_car_travel
      [
        { source_expense: { location: 'Court -', quantity: nil, rate: nil, amount: 13, reason_id: 1, reason_text: nil, schema_version: 2, distance: 52, mileage_rate_id: 1, date: '2017-08-23', hours: nil, vat_amount: 2.6 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_CR', "date_incurred": '2017-08-23', "description": 'Court -', "quantity": '52', "rate": '0.25' } },
        { source_expense: { location: 'HMP Highdown', quantity: nil, rate: nil, amount: 54, reason_id: 2, reason_text: nil, schema_version: 2, distance: 120, mileage_rate_id: 2, date: '2017-08-22', hours: nil, vat_amount: 0 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2017-08-22', "description": 'HMP Highdown', "quantity": '120', "rate": '0.45' } },
        { source_expense: { location: 'Groves Farm, Colworth', quantity: nil, rate: nil, amount: 27, reason_id: 3, reason_text: nil, schema_version: 2, distance: 60, mileage_rate_id: 2, date: '2016-09-02', hours: nil, vat_amount: 5.4 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2016-09-02', "description": 'Groves Farm, Colworth', "quantity": '60', "rate": '0.45' } },
        { source_expense: { location: 'Bradbury Hall', quantity: nil, rate: nil, amount: 51.75, reason_id: 4, reason_text: nil, schema_version: 2, distance: 115, mileage_rate_id: 2, date: '2016-07-07', hours: nil, vat_amount: 10.35 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2016-07-07', "description": 'Bradbury Hall', "quantity": '115', "rate": '0.45' } },
        { source_expense: { location: 'HMP Oakwood', quantity: nil, rate: nil, amount: 39.6, reason_id: 5, reason_text: 'Prison visit', schema_version: 2, distance: 88, mileage_rate_id: 2, date: '2017-02-13', hours: nil, vat_amount: 0 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_CR', "date_incurred": '2017-02-13', "description": 'HMP Oakwood Prison visit', "quantity": '88', "rate": '0.45' } }
      ]
    end

    def for_parking
      [
        { source_expense: { location: nil, quantity: nil, rate: nil, amount: 2.92, reason_id: 1, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-06-05', hours: nil, vat_amount: 0.58 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_CR', "date_incurred": '2017-06-05', "description": 'Parking', "quantity": '1', "rate": '2.92' } },
        { source_expense: { location: nil, quantity: nil, rate: nil, amount: 10, reason_id: 2, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-05-24', hours: nil, vat_amount: 0 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2017-05-24', "description": 'Parking', "quantity": '1', "rate": '10' } },
        { source_expense: { location: nil, quantity: nil, rate: nil, amount: 27, reason_id: 3, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2015-09-03', hours: nil, vat_amount: 5.4 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2015-09-03', "description": 'Parking', "quantity": '1', "rate": '27' } },
        { source_expense: { location: nil, quantity: nil, rate: nil, amount: 1, reason_id: 4, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-04-21', hours: nil, vat_amount: 0.2 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2017-04-21', "description": 'Parking', "quantity": '1', "rate": '1' } },
        { source_expense: { location: nil, quantity: nil, rate: nil, amount: 1.41, reason_id: 5, reason_text: "conference with client's parents", schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-07-06', hours: nil, vat_amount: 0.29 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_CR', "date_incurred": '2017-07-06', "description": "conference with client's parents", "quantity": '1', "rate": '1.41' } }
      ]
    end

    def for_hotel_accommodation
      [
        { source_expense: { location: 'NORTHAMPTON CC', quantity: nil, rate: nil, amount: 162, reason_id: 1, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-04-26', hours: nil, vat_amount: 32.4 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_HOT_ST', "date_incurred": '2017-04-26', "description": 'NORTHAMPTON CC', "quantity": '1', "rate": '162' } },
        { source_expense: { location: 'Macclesfield', quantity: nil, rate: nil, amount: 99, reason_id: 3, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-04-25', hours: nil, vat_amount: 19.8 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_HOT_ST', "date_incurred": '2017-04-25', "description": 'Macclesfield', "quantity": '1', "rate": '99' } },
        { source_expense: { location: 'HOTEL BIRMINGHAM', quantity: nil, rate: nil, amount: 155, reason_id: 5, reason_text: 'HOTEL FOR 20/06 - 21/06', schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-06-20', hours: nil, vat_amount: 31 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_HOT_ST', "date_incurred": '2017-06-20', "description": 'HOTEL BIRMINGHAM HOTEL FOR 20/06 - 21/06', "quantity": '1', "rate": '155' } }
      ]
    end

    def for_train_public_transport
      [
        { source_expense: { location: 'SOUTHWARK C C', quantity: nil, rate: nil, amount: 7, reason_id: 1, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-07-25', hours: nil, vat_amount: 1.4 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_TR', "date_incurred": '2016-07-25', "description": 'SOUTHWARK C C', "quantity": '1', "rate": '7' } },
        { source_expense: { location: 'Hmp Pentonville', quantity: nil, rate: nil, amount: 4.8, reason_id: 2, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-03-03', hours: nil, vat_amount: 0.96 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_TR', "date_incurred": '2017-03-03', "description": 'Hmp Pentonville', "quantity": '1', "rate": '4.8' } },
        { source_expense: { location: 'HMP BELMARSH', quantity: nil, rate: nil, amount: 9.6, reason_id: 3, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-07-12', hours: nil, vat_amount: 1.92 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_TR', "date_incurred": '2017-07-12', "description": 'HMP BELMARSH', "quantity": '1', "rate": '9.6' } },
        { source_expense: { location: 'Site visit, Lincoln', quantity: nil, rate: nil, amount: 132.5, reason_id: 4, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-07-29', hours: nil, vat_amount: 26.5 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_TR', "date_incurred": '2016-07-29', "description": 'Site visit, Lincoln', "quantity": '1', "rate": '132.5' } },
        { source_expense: { location: 'HMP Wandsworth', quantity: nil, rate: nil, amount: 12.3, reason_id: 5, reason_text: 'Initial Proof', schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-12-05', hours: nil, vat_amount: 2.46 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_TR', "date_incurred": '2016-12-05', "description": 'HMP Wandsworth Initial Proof', "quantity": '1', "rate": '12.3' } }
      ]
    end

    def for_travel_time
      [
        { source_expense: { location: 'Prison - HMP Forest Bank', quantity: nil, rate: nil, amount: 37.33, reason_id: 2, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-03-02', hours: 0.8, vat_amount: 7.47 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_CNF_VW', "date_incurred": '2017-03-02', "description": 'Prison - HMP Forest Bank', "quantity": '1', "rate": '0' } },
        { source_expense: { location: 'HMP Walton', quantity: nil, rate: nil, amount: 39, reason_id: 3, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-01-29', hours: 1, vat_amount: 7.8 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_CNF_VW', "date_incurred": '2016-01-29', "description": 'HMP Walton', "quantity": '1', "rate": '0' } },
        { source_expense: { location: 'Site Visit, Lincoln', quantity: nil, rate: nil, amount: 195, reason_id: 4, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-07-29', hours: 5.3, vat_amount: 39 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_CNF_VW', "date_incurred": '2016-07-29', "description": 'Site Visit, Lincoln', "quantity": '5.5', "rate": '0' } }
      ]
    end

    def for_road_or_tunnel_tolls
      [
        { source_expense: { location: 'Humber Bridge Toll', quantity: nil, rate: nil, amount: 3, reason_id: 1, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-09-14', hours: nil, vat_amount: 0.6 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_CR', "date_incurred": '2017-09-14', "description": 'Humber Bridge Toll', "quantity": '1', "rate": '3' } },
        { source_expense: { location: 'CENTRAL LONDON CONGESTION CHARGE', quantity: nil, rate: nil, amount: 11.5, reason_id: 2, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-06-01', hours: nil, vat_amount: 2.3 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2017-06-01', "description": 'CENTRAL LONDON CONGESTION CHARGE', "quantity": '1', "rate": '11.5' } },
        { source_expense: { location: 'HULL CC', quantity: nil, rate: nil, amount: 3, reason_id: 3, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-06-12', hours: nil, vat_amount: 0 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2017-06-12', "description": 'HULL CC', "quantity": '1', "rate": '3' } },
        { source_expense: { location: 'EXETER', quantity: nil, rate: nil, amount: 6.6, reason_id: 4, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-12-11', hours: nil, vat_amount: 1.32 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2016-12-11', "description": 'EXETER', "quantity": '1', "rate": '6.6' } },
        { source_expense: { location: 'hmp belmasrsh', quantity: nil, rate: nil, amount: 5, reason_id: 5, reason_text: 'attend client', schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-07-25', hours: nil, vat_amount: 1 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_CR', "date_incurred": '2017-07-25', "description": 'hmp belmasrsh attend client', "quantity": '1', "rate": '5' } }
      ]
    end

    def for_cab_fares
      [
        { source_expense: { location: 'Court - Old Bailey', quantity: nil, rate: nil, amount: 8.4, reason_id: 1, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-09-19', hours: nil, vat_amount: 1.68 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_CR', "date_incurred": '2016-09-19', "description": 'Court - Old Bailey', "quantity": '1', "rate": '8.4' } },
        { source_expense: { location: 'HMP Pentonville', quantity: nil, rate: nil, amount: 9.2, reason_id: 2, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-03-14', hours: nil, vat_amount: 0 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2017-03-14', "description": 'HMP Pentonville', "quantity": '1', "rate": '9.2' } },
        { source_expense: { location: 'HOTEL TO WATERLOO STATION', quantity: nil, rate: nil, amount: 7, reason_id: 3, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-02-15', hours: nil, vat_amount: 1.4 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2017-02-15', "description": 'HOTEL TO WATERLOO STATION', "quantity": '1', "rate": '7' } },
        { source_expense: { location: 'St Heliers, Sherbourne Road', quantity: nil, rate: nil, amount: 26.72, reason_id: 4, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-12-01', hours: nil, vat_amount: 5.34 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_TRV_CR', "date_incurred": '2016-12-01', "description": 'St Heliers, Sherbourne Road', "quantity": '1', "rate": '26.72' } },
        { source_expense: { location: 'Return journey Huntingdon Train Station to HMP Littlehey', quantity: nil, rate: nil, amount: 7, reason_id: 5, reason_text: 'Advise on sentence and Appeal  HMP Littlehay', schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-04-04', hours: nil, vat_amount: 1.4 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_CR', "date_incurred": '2017-04-04', "description": 'Return journey Huntingdon Train Station to HMP Littlehey Advise on sentence and Appeal  HMP Littlehay', "quantity": '1', "rate": '7' } }
      ]
    end

    def for_subsistence
      [
        { source_expense: { location: 'Liverpool - personal allowance', quantity: nil, rate: nil, amount: 5, reason_id: 1, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-11-11', hours: nil, vat_amount: 1 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_HOT_ST', "date_incurred": '2016-11-11', "description": 'Liverpool - personal allowance', "quantity": '1', "rate": '5' } },
        { source_expense: { location: 'HMP', quantity: nil, rate: nil, amount: 8.6, reason_id: 3, reason_text: nil, schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2016-03-08', hours: nil, vat_amount: 1.72 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_TCT_HOT_ST', "date_incurred": '2016-03-08', "description": 'HMP', "quantity": '1', "rate": '8.6' } },
        { source_expense: { location: 'France', quantity: nil, rate: nil, amount: 15, reason_id: 5, reason_text: 'Food in France', schema_version: 2, distance: nil, mileage_rate_id: nil, date: '2017-03-06', hours: nil, vat_amount: 3 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_HOT_ST', "date_incurred": '2017-03-06', "description": 'France Food in France', "quantity": '1', "rate": '15' } }
      ]
    end

    def for_bike_travel
      [
        { source_expense: { location: 'Stafford', quantity: nil, rate: nil, amount: 12, created_at: '2017-06-28 06:27:41', updated_at: '2017-06-28 06:27:41', uuid: '5f9a4ae0-8b4d-4335-85d3-b220aa7557be', reason_id: 1, reason_text: nil, schema_version: 2, distance: 60, mileage_rate_id: 3, date: '2017-05-12', hours: nil, vat_amount: 2.4 }, expected_return: { "bill_type": 'AGFS_EXPENSES', "bill_subtype": 'AGFS_THE_TRV_BK', "date_incurred": '2017-05-12', "description": 'Stafford', "quantity": '60', "rate": '0.2' } }
      ]
    end
  end
end
