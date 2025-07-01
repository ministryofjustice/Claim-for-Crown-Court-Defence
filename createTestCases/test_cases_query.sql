select
	c.id as case_id,
	f.id as fee_id,
	d.id as defendant_id,
	c.court_id,
	c.case_type_id,
	c.offence_id,
	c.case_number,
	c.apply_vat, 
	c.first_day_of_trial, 
	c.trial_concluded_at,
	c.estimated_trial_length, 
	c.actual_trial_length,
	c.advocate_category, 
	d.first_name,
	d.last_name,
	d.date_of_birth,
	ro.maat_reference,
	ro.representation_order_date,
	f.quantity,
	f.rate,
	f.amount,
	f.fee_type_id
from claims c, fees f, defendants d, representation_orders ro
where 
	c.state = 'authorised' and
	f.claim_id  = c.id and
	d.claim_id  = c.id and
	ro.defendant_id = d.id
order by c.created_at desc 
limit 5;