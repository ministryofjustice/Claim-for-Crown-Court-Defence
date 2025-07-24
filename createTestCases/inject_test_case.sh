#!/bin/bash

# Check if a file was provided as an argument
if [ $# -ne 3 ]; then
  echo "Usage: $0 <uuid> <pod_name> <env>"
  exit 1
fi

# Params
LOG_LEVEL=1 # 0 - silent, 1 - verbose
UUID=${1}
POD_NAME=${2}
ENV=${3}

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

if [ $LOG_LEVEL -eq 1 ]; then
  LOG_FLAG=""
else
  LOG_FLAG="> /dev/null"
fi

echo -e "!=== ${0} started..."

kubectl exec -n $ENV -it $POD_NAME -- rails c $LOG_FLAG <<EOF
claim=Claim::BaseClaim.find_by(uuid: '$UUID')
claim.build_certification(
  certification_type_id: 7,
  certified_by: 'Test',
  certification_date: Date.today
)
claim.certification.save
claim_updater = Claims::ExternalUserClaimUpdater.new(claim, current_user: claim.external_user.user)
claim_updater.submit
DataInjection::Injector.new([claim]).call
EOF

echo -e "\n!=== ${0} ended..."