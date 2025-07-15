#!/bin/bash

# Check if a file was provided as an argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <json_file>"
  exit 1
fi

# Check if the file exists and is a file
if [ ! -f "$1" ]; then
  echo "Error: $1 is not a file"
  exit 1
fi

# Params
ENV="local" #local, dev, api_sandbox
LOG_LEVEL=0 # 0 - silent, 1 - verbose

# Create log file
LOG_DIR="${0}_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/${0}_$(date +%Y%m%d%H%M).log"
i=0
while [ -f "$LOG_FILE" ]; do
  ((i++))
  LOG_FILE="$LOG_DIR/${0}_$(date +%Y%m%d%H%M)_$i.log"
done
exec > "$LOG_FILE" 2>&1

urlEncode() {
  local string="$1"
  if [ -z "$string" ] || [ "$string" = "null" ]; then
    echo ""
  else
    local encoded_string=$(echo "$string" | tr -d '\n' | jq -sRr @uri)
    echo "$encoded_string"
  fi
}

debugLog() {
    if [ "$LOG_LEVEL" -ge 1 ]; then
       echo -e "$1"
    fi 
}

startInjection() {
    echo -e "\n===! claim($1) created, calling inject_test_case.sh at $(date +%Y%m%d%H%M)"
    if [ $POD_NAME == "local" ]; then
        echo -e "===! skip inject_test_case.sh in local..."
    else
        ./inject_test_case.sh "$1" "$POD_NAME" &
    fi
}

createAdvocateClaim() {
    echo -e "\n>>> Creating Advocate Claim..."

    QUERY_PARAMS="creator_email=$USER_EMAIL&court_id=$COURT_ID&case_type_id=$CASE_TYPE_ID&offence_id=$OFFENCE_ID&case_number=$CASE_NUMBER&apply_vat=$APPLY_VAT&estimated_length_of_trial=$E_LENGTH&actual_trial_length=$A_LENGTH&user_email=$USER_EMAIL&advocate_category=$ADVOCATE_TYPE&api_key=$API_KEY"

    if [ -n "$FIRST_TRIAL_DATE" ]; then
        debugLog "First trial date: $FIRST_TRIAL_DATE"
        QUERY_PARAMS+="&first_day_of_trial=$FIRST_TRIAL_DATE"
    fi

    if [ -n "$TRIAL_CONCLUDED_DATE" ]; then
        debugLog "Trial concluded date: $TRIAL_CONCLUDED_DATE"
        QUERY_PARAMS+="&trial_concluded_at=$TRIAL_CONCLUDED_DATE"
    fi

    if [ -n "$TRIAL_CRACKED_AT_THIRD" ]; then
        debugLog "Trial cracked at third: $TRIAL_CRACKED_AT_THIRD"
        QUERY_PARAMS+="&trial_cracked_at_third=$TRIAL_CRACKED_AT_THIRD"
    fi

    if [ -n "$TRIAL_CRACKED_AT" ]; then
        debugLog "Trial cracked at: $TRIAL_CRACKED_AT"
        QUERY_PARAMS+="&trial_cracked_at=$TRIAL_CRACKED_AT"
    fi

    if [ -n "$TRIAL_FIXED_NOTICE_AT" ]; then
        debugLog "Trial fixed notice at: $TRIAL_FIXED_NOTICE_AT"
        QUERY_PARAMS+="&trial_fixed_notice_at=$TRIAL_FIXED_NOTICE_AT"
    fi

    if [ -n "$TRIAL_FIXED_AT" ]; then
        debugLog "Trial fixed at: $TRIAL_FIXED_AT"
        QUERY_PARAMS+="&trial_fixed_at=$TRIAL_FIXED_AT"
    fi

    if [ -n "$RETRIAL_E_LENGTH" ]; then
        debugLog "Retrial estimated length: $RETRIAL_E_LENGTH"
        QUERY_PARAMS+="&retrial_estimated_length=$RETRIAL_E_LENGTH"
    fi

    if [ -n "$RETRIAL_A_LENGTH" ]; then
        debugLog "Retrial actual length: $RETRIAL_A_LENGTH"
        QUERY_PARAMS+="&retrial_actual_length=$RETRIAL_A_LENGTH"
    fi

    if [ -n "$RETRIAL_STARTED_AT" ]; then
        debugLog "Retrial started at: $RETRIAL_STARTED_AT"
        QUERY_PARAMS+="&retrial_started_at=$RETRIAL_STARTED_AT"
    fi

    if [ -n "$RETRIAL_CONCLUDED_AT" ]; then
        debugLog "Retrial concluded at: $RETRIAL_CONCLUDED_AT"
        QUERY_PARAMS+="&retrial_concluded_at=$RETRIAL_CONCLUDED_AT"
    fi

    RESPONSE=$(curl --location --globoff --request POST "$API_DOMAIN/api/external_users/claims/advocates/final?$QUERY_PARAMS")
    echo -e "\nRESPONSE:$RESPONSE"

    if jq -e 'type == "array" and .[0].error' <<< "$RESPONSE" > /dev/null; then
        ERROR_MSG=$(jq -r '.[0].error' <<< "$RESPONSE")
        echo -e "\n>>> Error creating claim: $ERROR_MSG"
    else
        echo -e "\n>>> Avocate claim created successfully."

        # Parse CLAIM_ID from response
        CLAIM_ID=$(jq -r '.id' <<< "$RESPONSE")
        debugLog "=> CLAIM_ID: $CLAIM_ID"
    fi

    unset RESPONSE
}

createLitigatorClaim() {
    echo -e "\n>>> Creating LitigatorClaim..."

    QUERY_PARAMS="creator_email=$USER_EMAIL&court_id=$COURT_ID&case_type_id=$CASE_TYPE_ID&offence_id=$OFFENCE_ID&case_number=$CASE_NUMBER&apply_vat=$APPLY_VAT&actual_trial_length=$A_LENGTH&user_email=$USER_EMAIL&supplier_number=$SUPPLIER_NUMBER&api_key=$API_KEY"

    if [ -n "$PROSECUTION_EVIDENCE" ]; then
        debugLog "Prosecution evidence: $PROSECUTION_EVIDENCE"
        QUERY_PARAMS+="&prosecution_evidence=$PROSECUTION_EVIDENCE"
    fi

    if [ -n "$CASE_CONCLUDED_DATE" ]; then
        debugLog "Case concluded date: $CASE_CONCLUDED_DATE"
        QUERY_PARAMS+="&case_concluded_at=$CASE_CONCLUDED_DATE"
    fi

    RESPONSE=$(curl --location --globoff --request POST "$API_DOMAIN/api/external_users/claims/final?$QUERY_PARAMS")
    echo -e "\nRESPONSE:$RESPONSE"

    if jq -e 'type == "array" and .[0].error' <<< "$RESPONSE" > /dev/null; then
        ERROR_MSG=$(jq -r '.[0].error' <<< "$RESPONSE")
        echo -e "\n>>> Error creating claim: $ERROR_MSG"
    else
        echo -e "\n>>> Litigator claim created successfully."

        # Parse CLAIM_ID from response
        CLAIM_ID=$(jq -r '.id' <<< "$RESPONSE")
        debugLog "=> CLAIM_ID: $CLAIM_ID"
    fi

    unset RESPONSE
}

createDefendant() {
    echo -e "\n>>> Creating Defendant..."
    RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/defendants?claim_id=$CLAIM_ID&first_name=$FIRST&last_name=$LAST&date_of_birth=$DOB&api_key=$API_KEY")

    debugLog "\nRESPONSE:$RESPONSE"

    if jq -e 'type == "array" and .[0].error' <<< "$RESPONSE" > /dev/null; then
        ERROR_MSG=$(jq -r '.[0].error' <<< "$RESPONSE")
        echo -e "\n>>> Error creating claim: $ERROR_MSG"
    else
        echo -e "\n>>> Defendant created successfully."

        # Parse DEFENDANT_ID from response
        DEFENDANT_ID=$(jq -r '.id' <<< "$RESPONSE")
        debugLog "=> DEFENDANT_ID: $DEFENDANT_ID"
    fi

    unset RESPONSE
}

createRepOrder() {
    echo -e "\n>>> Creating Representation Order..."
    RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/representation_orders?defendant_id=$DEFENDANT_ID&maat_reference=$MAAT_REF&representation_order_date=$REP_ORDER_DATE&api_key=$API_KEY")
    
    debugLog "\nRESPONSE:$RESPONSE"

    if jq -e 'type == "array" and .[0].error' <<< "$RESPONSE" > /dev/null; then
        ERROR_MSG=$(jq -r '.[0].error' <<< "$RESPONSE")            
        echo -e "\n>>> Error creating claim: $ERROR_MSG"
    else
        echo -e "\n>>> Representation Order created successfully."
    fi

    unset RESPONSE
}

createFee() {
    echo -e "\n>>> Creating Fee..."
    
    QUERY_PARAMS="claim_id=$CLAIM_ID&fee_type_id=$FEE_TYPE_ID&api_key=$API_KEY"

    if [ -n "$QUANTITY" ]; then
        debugLog "Quantity: $QUANTITY"
        QUERY_PARAMS+="&quantity=$QUANTITY" 
    fi

    if [ -n "$RATE" ]; then
        debugLog "Rate: $RATE"
        QUERY_PARAMS+="&rate=$RATE" 
    fi

    if [ -n "$AMOUNT" ]; then
        debugLog "Amount: $AMOUNT"
        QUERY_PARAMS+="&amount=$AMOUNT" 
    fi

    RESPONSE=$(curl -s --location --globoff --request POST "$API_DOMAIN/api/external_users/fees/?$QUERY_PARAMS")

    debugLog "\nRESPONSE:$RESPONSE"

    if jq -e 'type == "array" and .[0].error' <<< "$RESPONSE" > /dev/null; then
        ERROR_MSG=$(jq -r '.[0].error' <<< "$RESPONSE")        
        echo -e "\n>>> Error creating claim: $ERROR_MSG"
    else
        echo -e "\n>>> Fee created successfully."
    fi

    unset RESPONSE
}

# Start
echo -e "!=== ${0} started..."

# Parse the configuration file
CONFIG_FILE="config_${ENV}.json"
API_KEY=$(jq -r '.api_key' $CONFIG_FILE) # Can be found in providers table
API_DOMAIN=$(jq -r '.api_domain' $CONFIG_FILE) # env url
POD_NAME=$(jq -r '.pod_name' $CONFIG_FILE) # Obtained by "kubectl -n (env) get pods"

# Get maat ref mask list
maat_refrence_ids=()
while IFS= read -r line; do
    maat_refrence_ids+=("$line")
done < maat_refrence_ids_$ENV.txt
debugLog "=> maat_refrence_ids: ${maat_refrence_ids[@]}"
  
# Use jq to parse the JSON data
DATA_FILE="$1"
LAST_CASE_ID="00000"
LAST_FEE_ID="00000"
LAST_DEFENDANT_ID="00000"
LAST_CLAIM_ID="00000"
IS_ALL_FEE_ADDED="FALSE"
IS_ALL_DEFNANT_ADDED="FALSE"

# Count the number of items in the second level
ITEM_COUNT=$(jq '.[] | length' "$DATA_FILE" | head -n 1)
echo -e "\n==== Number of items: $ITEM_COUNT"

for ((i=0; i<ITEM_COUNT; i++)); do
    echo -e "\n==== Start of item: $i"

    CLAIM_FLAG="TRUE"
    FEE_FLAG="TRUE"
    DEFENDANT_FLAG="TRUE"
    DEFENDANT_ADDED=0

    # Extract the values from the JSON file
    case_id=$(jq -r '.[] | .['$i'].case_id' "$DATA_FILE")
    fee_id=$(jq -r '.[] | .['$i'].fee_id' "$DATA_FILE")
    defendant_id=$(jq -r '.[] | .['$i'].defendant_id' "$DATA_FILE")
    type=$(jq -r '.[] | .['$i'].type' "$DATA_FILE")
    court_id=$(jq -r '.[] | .['$i'].court_id' "$DATA_FILE")
    case_type_id=$(jq -r '.[] | .['$i'].case_type_id' "$DATA_FILE")
    offence_id=$(jq -r '.[] | .['$i'].offence_id' "$DATA_FILE")
    case_number=$(jq -r '.[] | .['$i'].case_number' "$DATA_FILE")
    apply_vat=$(jq -r '.[] | .['$i'].apply_vat' "$DATA_FILE")
    first_day_of_trial=$(jq -r '.[] | .['$i'].first_day_of_trial' "$DATA_FILE")
    trial_concluded_at=$(jq -r '.[] | .['$i'].trial_concluded_at' "$DATA_FILE")
    estimated_trial_length=$(jq -r '.[] | .['$i'].estimated_trial_length' "$DATA_FILE")
    actual_trial_length=$(jq -r '.[] | .['$i'].actual_trial_length' "$DATA_FILE")
    advocate_category=$(jq -r '.[] | .['$i'].advocate_category' "$DATA_FILE")
    trial_cracked_at_third=$(jq -r '.[] | .['$i'].trial_cracked_at_third' "$DATA_FILE")
    trial_cracked_at=$(jq -r '.[] | .['$i'].trial_cracked_at' "$DATA_FILE")
    trial_fixed_notice_at=$(jq -r '.[] | .['$i'].trial_fixed_notice_at' "$DATA_FILE")
    trial_fixed_at=$(jq -r '.[] | .['$i'].trial_fixed_at' "$DATA_FILE")
    retrial_estimated_length=$(jq -r '.[] | .['$i'].retrial_estimated_length' "$DATA_FILE")
    retrial_actual_length=$(jq -r '.[] | .['$i'].retrial_actual_length' "$DATA_FILE")
    retrial_started_at=$(jq -r '.[] | .['$i'].retrial_started_at' "$DATA_FILE")
    retrial_concluded_at=$(jq -r '.[] | .['$i'].retrial_concluded_at' "$DATA_FILE")
    supplier_number=$(jq -r '.[] | .['$i'].supplier_number' "$DATA_FILE")
    prosecution_evidence=$(jq -r '.[] | .['$i'].prosecution_evidence' "$DATA_FILE")
    case_concluded_at=$(jq -r '.[] | .['$i'].case_concluded_at' "$DATA_FILE")
    first_name=$(jq -r '.[] | .['$i'].first_name' "$DATA_FILE")
    last_name=$(jq -r '.[] | .['$i'].last_name' "$DATA_FILE")
    date_of_birth=$(jq -r '.[] | .['$i'].date_of_birth' "$DATA_FILE")
    maat_reference=$(jq -r '.[] | .['$i'].maat_reference' "$DATA_FILE")
    representation_order_date=$(jq -r '.[] | .['$i'].representation_order_date' "$DATA_FILE")
    quantity=$(jq -r '.[] | .['$i'].quantity' "$DATA_FILE")
    rate=$(jq -r '.[] | .['$i'].rate' "$DATA_FILE")
    amount=$(jq -r '.[] | .['$i'].amount' "$DATA_FILE")
    fee_type_id=$(jq -r '.[] | .['$i'].fee_type_id' "$DATA_FILE")

    # Create Claim PARAMS
    USER_EMAIL=$(jq -r '.user_email' $CONFIG_FILE)
    debugLog "=> USER_EMAIL: $USER_EMAIL"
    CASE_ID=$(urlEncode "$case_id")
    debugLog "=> CASE_ID: $CASE_ID"
    FEE_ID=$(urlEncode "$fee_id")
    debugLog "=> FEE_ID: $FEE_ID"
    DEFENDANT_ID=$(urlEncode "$defendant_id")
    debugLog "=> DEFENDANT_ID: $DEFENDANT_ID"
    TYPE=$(urlEncode "$type")
    debugLog "=> TYPE: $TYPE"
    COURT_ID=$(urlEncode "$court_id")
    debugLog "=> COURT_ID: $COURT_ID"
    CASE_TYPE_ID=$(urlEncode "$case_type_id")
    debugLog "=> CASE_TYPE_ID: $CASE_TYPE_ID"
    OFFENCE_ID=$(urlEncode "$offence_id")
    debugLog "=> OFFENCE_ID: $OFFENCE_ID"
    CASE_NUMBER=$(urlEncode "$case_number")
    debugLog "=> CASE_NUMBER: $CASE_NUMBER"
    APPLY_VAT=$(urlEncode "$apply_vat")
    debugLog "=> APPLY_VAT: $APPLY_VAT"
    FIRST_TRIAL_DATE=$(urlEncode "$first_day_of_trial")
    debugLog "=> FIRST_TRIAL_DATE: $FIRST_TRIAL_DATE"
    TRIAL_CONCLUDED_DATE=$(urlEncode "$trial_concluded_at")
    debugLog "=> TRIAL_CONCLUDED_DATE: $TRIAL_CONCLUDED_DATE"
    E_LENGTH=$(urlEncode "$estimated_trial_length")
    debugLog "=> E_LENGTH: $E_LENGTH"
    A_LENGTH=$(urlEncode "$actual_trial_length")
    debugLog "=> A_LENGTH: $A_LENGTH"
    ADVOCATE_TYPE=$(urlEncode "$advocate_category")
    debugLog "=> ADVOCATE_TYPE: $ADVOCATE_TYPE"
    TRIAL_CRACKED_AT_THIRD=$(urlEncode "$trial_cracked_at_third")
    debugLog "=> TRIAL_CRACKED_AT_THIRD: $TRIAL_CRACKED_AT_THIRD"
    TRIAL_CRACKED_AT=$(urlEncode "$trial_cracked_at")
    debugLog "=> TRIAL_CRACKED_AT: $TRIAL_CRACKED_AT"
    TRIAL_FIXED_NOTICE_AT=$(urlEncode "$trial_fixed_notice_at")
    debugLog "=> TRIAL_FIXED_NOTICE_AT: $TRIAL_FIXED_NOTICE_AT"
    TRIAL_FIXED_AT=$(urlEncode "$trial_fixed_at")
    debugLog "=> TRIAL_FIXED_AT: $TRIAL_FIXED_AT"
    RETRIAL_E_LENGTH=$(urlEncode "$retrial_estimated_length")
    debugLog "=> RETRIAL_E_LENGTH: $RETRIAL_E_LENGTH"
    RETRIAL_A_LENGTH=$(urlEncode "$retrial_actual_length")
    debugLog "=> RETRIAL_A_LENGTH: $RETRIAL_A_LENGTH"
    RETRIAL_STARTED_AT=$(urlEncode "$retrial_started_at")
    debugLog "=> RETRIAL_STARTED_AT: $RETRIAL_STARTED_AT"
    RETRIAL_CONCLUDED_AT=$(urlEncode "$retrial_concluded_at")
    debugLog "=> RETRIAL_CONCLUDED_AT: $RETRIAL_CONCLUDED_AT"
    SUPPLIER_NUMBER=$(urlEncode "$supplier_number")
    debugLog "=> SUPPLIER_NUMBER: $SUPPLIER_NUMBER"
    PROSECUTION_EVIDENCE=$(urlEncode "$prosecution_evidence")
    debugLog "=> PROSECUTION_EVIDENCE: $PROSECUTION_EVIDENCE"
    CASE_CONCLUDED_DATE=$(urlEncode "$case_concluded_at")
    debugLog "=> CASE_CONCLUDED_DATE: $CASE_CONCLUDED_DATE"

    # Create Defendant PARAMS
    FIRST=$(urlEncode "$first_name")
    debugLog "=> FIRST: $FIRST"
    LAST=$(urlEncode "$last_name")
    debugLog "=> LAST: $LAST"
    DOB=$(urlEncode "$date_of_birth")
    debugLog "=> DOB: $DOB"

    # Create Rep Order PARAMS
    REP_ORDER_DATE=$(urlEncode "$representation_order_date")
    debugLog "=> REP_ORDER_DATE: $REP_ORDER_DATE"
    MAAT_REF=$(urlEncode "$maat_reference")
    debugLog "=> MAAT_REF: $MAAT_REF"

    # Create Fee PARAMS
    QUANTITY=$(urlEncode "$quantity")
    debugLog "=> QUANTITY: $QUANTITY"
    RATE=$(urlEncode "$rate")
    debugLog "=> RATE: $RATE"
    AMOUNT=$(urlEncode "$amount")
    debugLog "=> AMOUNT: $AMOUNT"
    FEE_TYPE_ID=$(urlEncode "$fee_type_id")
    debugLog "=> FEE_TYPE_ID: $FEE_TYPE_ID"

    # PARAMS GET FROM API
    CLAIM_ID=""
    DEFENDANT_ID=""

    # FLOW START
    declare -a RESPONSE

    # FLAGS SET
    if [ "$CASE_ID" == "$LAST_CASE_ID" ]; then
        CLAIM_ID=$LAST_CLAIM_ID
        debugLog "=> Same Case ID as last item"
        CLAIM_FLAG="FALSE"
    else
        debugLog "=> New Case ID"
        IS_ALL_FEE_ADDED="FALSE"
        IS_ALL_DEFNANT_ADDED="FALSE"
        DEFENDANT_ADDED=0
        if [ "$LAST_CASE_ID" != "00000" ]; then
            startInjection "$LAST_CLAIM_ID"
        fi
    fi 
    
    if [ "$CASE_ID" == "$LAST_CASE_ID" ] && [ "$FEE_ID" == "$LAST_FEE_ID" ]; then
        debugLog "=> Same Fee ID as last item"
        FEE_FLAG="FALSE"
        DEFENDANT_ADDED+=1
        debugLog "=> Defendant added: $DEFENDANT_ADDED"
        if [ "$IS_ALL_DEFNANT_ADDED" == "TRUE" ]; then
            DEFENDANT_FLAG="FALSE"    
        fi
    elif [ "$CASE_ID" == "$LAST_CASE_ID" ] && [ "$FEE_ID" != "$LAST_FEE_ID" ]; then
        DEFENDANT_FLAG="FALSE"
        if [ "$IS_ALL_DEFNANT_ADDED" == "FALSE" ]; then
            debugLog "=> All Defendant ID are being added"
            IS_ALL_DEFNANT_ADDED="TRUE"
        fi
    fi

    # Masking MAAT_REF
    index=$(( DEFENDANT_ADDED < ${#maat_refrence_ids[@]} ? DEFENDANT_ADDED : ${#maat_refrence_ids[@]}-1 ))
    MAAT_REF=$(urlEncode "${maat_refrence_ids[$index]}")
    debugLog "=> Masked MAAT_REF: $MAAT_REF"

    # Create Claim
    if [ "$CLAIM_FLAG" == "TRUE" ]; then
        createAdvocateClaim
    fi

    # Create Defendant and Rep Order
    if [ "$DEFENDANT_FLAG" == "TRUE" ]; then
        createDefendant
        createRepOrder
    fi

    # Create Fee
    if [ "$FEE_FLAG" == "TRUE" ]; then
        createFee
    fi

    # PARAM SET
    LAST_CLAIM_ID=$CLAIM_ID
    LAST_CASE_ID=$case_id
    LAST_FEE_ID=$fee_id
    LAST_DEFENDANT_ID=$defendant_id

    echo -e "\n==== End of item: $i"

    if [ $i -eq $((ITEM_COUNT-1)) ]; then
        startInjection "$LAST_CLAIM_ID"
    fi
done

echo -e "\n!=== ${0} ended..."