select
	c.id as case_id,
	f.id as fee_id,
	d.id as defendant_id,
	c.type,
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
	c.trial_cracked_at_third,
	c.trial_cracked_at,
	c.trial_fixed_notice_at,
	c.trial_fixed_at,
	c.retrial_estimated_length,
	c.retrial_actual_length,
	c.retrial_started_at,
	c.retrial_concluded_at,
	c.supplier_number,
	c.prosecution_evidence,
	c.case_concluded_at,
	d.first_name,
	d.last_name,
	d.date_of_birth,
	ro.maat_reference,
	ro.representation_order_date,
	f.quantity,
	f.rate,
	f.amount,
	f.fee_type_id,
	f.case_numbers as fee_case_numbers,
	f.date as fee_date
from claims c, fees f, defendants d, representation_orders ro
where 
	c.state = 'authorised' and
	c.case_type_id is not null and
	c.offence_Id is not null and
	c.type in ('Claim::AdvocateClaim', 'Claim::LitigatorClaim') and 
	f.claim_id  = c.id and
	d.claim_id  = c.id and
	ro.defendant_id = d.id
order by c.created_at desc 
limit 10;