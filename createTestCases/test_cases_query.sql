SELECT * 
  FROM (SELECT  c.ID AS CASE_ID,
  				fs.DESCRIPTION AS FEE_SCHEME,
                c.COUR_COURT_CODE,
                bs.SCENARIO AS BILL_SCENARIO,
                oc.UNIQUE_CODE AS OFFENCE_UNIQUE_CODE,
                c.CASE_NO,
                b.VAT_INCLUDED,
                c.TRIAL_DATE_START,
                c.EST_TRIAL_LENGTH,
                c.ACT_TRIAL_LENGTH,
                b.PSTY_PERSON_TYPE,
                c.CLIENT_FORENAME,
                c.CLIENT_SURNAME,
                c.CLIENT_DOB,
                c.REP_ORD_DATE,
                cr.MAAT_REFERENCE,
                b.QUANTITY,
                b.RATE,
                b.BASIC_CASE_FEE,
                bt.BILL_TYPE,
                bst.BILL_SUB_TYPE
  FROM BILLS b, CASES c, BILL_TYPES bt, BILL_SUB_TYPES bst, BILL_SCENARIOS bs, FEE_SCHEMES fs, CASES_REPORDERS cr, OFFENCE_CODES oc, OFFENCE_TYPES ot
  WHERE b.CASE_ID = c.ID
          AND b.BITY_BILL_TYPE = bt.BILL_TYPE
          AND b.BIST_BILL_SUB_TYPE = bst.BILL_SUB_TYPE
          AND b.BISC_BILL_SCENARIO_ID = bs.ID
          AND b.FSTH_FEE_STRUCTURE_ID = fs.FESH_FIRST_ID
          AND c.id = cr.CASE_ID
          AND c.OFCD_ID = oc.id
          AND c.OFTY_OFFENCE_TYPE = ot.OFFENCE_TYPE
          AND b.CIS_EXTERNAL_REF IS NOT NULL
  ORDER BY c.DATE_CREATED DESC)
WHERE ROWNUM <= 10;