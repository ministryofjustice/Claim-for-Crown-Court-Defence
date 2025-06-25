#!/bin/bash -e

# Example usage:
# ./create_test_cases.sh "agfs_scheme_16" "misc" "MISTE" "advocate@example.com" "1" "12" "1093" "AGFS16S28" "true" "2023-10-16" "1" "1" "Junior" "Joe" "Bloggs" "2000-01-01" "2023-10-16" "6015685" "1" "1000" "MISTE"

API_KEY="" # PLEASE ADD YOUR API KEY
API_DOMAIN="http://localhost:3001"

# BILL_SCENARIOS = {
#     FXACV: 'AS000005', # Appeal against conviction
#     FXASE: 'AS000006', # Appeal against sentence
#     FXCBR: 'AS000009', # Breach of Crown Court order
#     FXCSE: 'AS000007', # Committal for Sentence
#     FXCON: 'AS000008', # Contempt
#     GRRAK: 'AS000003', # Cracked Trial
#     GRCBR: 'AS000010', # Cracked before retrial
#     GRDIS: 'AS000001', # Discontinuance
#     FXENP: 'AS000014', # Elected cases not proceeded
#     GRGLT: 'AS000002', # Guilty plea
#     GRRTR: 'AS000011', # Retrial
#     GRTRL: 'AS000004'  # Trial
# }

# # GET Fee Types PARAMS
# ROLE=${1} # fs.DESCRIPTION AS FEE_SCHEME
# CATEGORY=${2} # bt.DESCRIPTION AS BILL_TYPE
# CODE=${3} # 

# Create AGFS 16 Claim PARAMS
USER_EMAIL=${4} # advocate@example.com
COURT_ID=${5} # c.COUR_COURT_CODE
CASE_TYPE_ID=${6} # bs.SCENARIO AS BILL_SCENARIO
OFFENCE_ID=${7} # oc.UNIQUE_CODE AS OFFENCE_UNIQUE_CODE, then map to id in cccd?
CASE_NUMBER=${8} # c.CASE_NO
APPLY_VAT=${9} # b.VAT_INCLUDED
DATE=${10} # c.TRIAL_DATE_START
E_LENGTH=${11} # c.EST_TRIAL_LENGTH
A_LENGTH=${12} # c.ACT_TRAIL_LENGTH
ADVOCATE_TYPE=${13} # PSTY_PERSON_TYPE

# Create Defendant PARAMS
FIRST=${14} # c.CLIENT_FORENAME
LAST=${15} # c.CLIENT_SURNAME
DOB=${16} # c.CLIENT_DOB

# Create Rep Order PARAMS
REP_ORDER_DATE=${17} # REP_ORD_DATE
MAAT_REF=${18} # cr.MAAT_REFERENCE

# Create Fee PARAMS
QUANTITY=${19} # b.QUANTITY
RATE=${20} # b.RATE
FEE_UNIQUE_CODE=${21} # bt.BILL_TYPE, bst.BILL_SUB_TYPE pair

# PARAMS GET FROM API
CLAIM_ID=""
DEFENDANT_ID=""

# FLOW START
echo -e "create_test_cases.sh started!"
declare -a RESPONSE

# # GET Fee Type
# echo -e "\n>>> Getting Fee Type..."
# RESPONSE=$(curl -s --location --globoff "$API_DOMAIN/api/fee_types?role=$ROLE&category=$CATEGORY&unique_code=$CODE&api_key=$API_KEY")
# echo -e "\nRESPONSE:$RESPONSE"
# echo -e "\n>>> Fee Type found successfully."

# # Parse FEE_ID from response
# FEE_ID=$(jq -r '.[0].id' <<< "$RESPONSE")
# echo -e "\n==== FEE_ID: $FEE_ID"
# unset RESPONSE

# Create AGFS 16 Claim
echo -e "\n>>> Creating AGFS 16 Claim..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/claims/advocates/final?creator_email=$USER_EMAIL&court_id=$COURT_ID&case_type_id=$CASE_TYPE_ID&offence_id=$OFFENCE_ID&case_number=$CASE_NUMBER&apply_vat=$APPLY_VAT&first_day_of_trial=$DATE&estimated_length_of_trial=$E_LENGTH&trial_concluded_at=$DATE&actual_trial_length=$A_LENGTH&user_email=$USER_EMAIL&advocate_category=$ADVOCATE_TYPE&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> AGFS 16 Claim created successfully."

# Parse CLAIM_ID from response
CLAIM_ID=$(jq -r '.id' <<< "$RESPONSE")
echo -e "\n==== CLAIM_ID: $CLAIM_ID"
unset RESPONSE

# Create Defendant
echo -e "\n>>> Creating Defendant..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/defendants?claim_id=$CLAIM_ID&first_name=$FIRST&last_name=$LAST&date_of_birth=$DOB&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Defendant created successfully."

# Parse DEFENDANT_ID from response
DEFENDANT_ID=$(jq -r '.id' <<< "$RESPONSE")
echo -e "\n==== DEFENDANT_ID: $DEFENDANT_ID"
unset RESPONSE

# Create Rep Order
echo -e "\n>>> Creating Representation Order..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/representation_orders?defendant_id=$DEFENDANT_ID&maat_reference=$MAAT_REF&representation_order_date=$REP_ORDER_DATE&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Representation Order created successfully."

unset RESPONSE

# Create Fee
echo -e "\n>>> Creating Fee..."
RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/fees/?claim_id=$CLAIM_ID&fee_type_unique_code=$FEE_UNIQUE_CODE&quantity=$QUANTITY&rate=$RATE&api_key=$API_KEY")
echo -e "\nRESPONSE:$RESPONSE"
echo -e "\n>>> Fee created successfully."

unset RESPONSE

echo -e "\ncreate_test_cases.sh finished!"