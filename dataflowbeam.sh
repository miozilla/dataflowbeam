# activate cloud shell
gcloud auth list
gcloud config list project
# create cloud storage bucket
PROJECT=`gcloud config list --format 'value(core.project)'`
USER_EMAIL=`gcloud config list account --format "value(core.account)"`
REGION="REGION"
gcloud storage buckets create gs://$PROJECT --project=$PROJECT
# launch dataflow job
gcloud projects get-iam-policy $PROJECT  \
--format='table(bindings.role)' \
--flatten="bindings[].members" \
--filter="bindings.members:$USER_EMAIL"
gcloud dataflow jobs run job1 \
--gcs-location gs://dataflow-templates-"REGION"/latest/Word_Count \
--region $REGION \
--staging-location gs://$PROJECT/tmp \
--parameters inputFile=gs://dataflow-samples/shakespeare/kinglear.txt,output=gs://$PROJECT/results/outputs
gcloud projects add-iam-policy-binding $PROJECT --member=user:$USER_EMAIL --role=roles/dataflow.admin
gcloud dataflow jobs run job1 \
--gcs-location gs://dataflow-templates-"REGION"/latest/Word_Count \
--region $REGION \
--staging-location gs://$PROJECT/tmp \
--parameters inputFile=gs://dataflow-samples/shakespeare/kinglear.txt,output=gs://$PROJECT/results/outputs
gcloud dataflow jobs run job2 \
--gcs-location gs://dataflow-templates-"REGION"/latest/Word_Count \
--region $REGION \
--staging-location gs://$PROJECT/tmp \
--parameters inputFile=gs://dataflow-samples/shakespeare/kinglear.txt,output=gs://$PROJECT/results/outputs --disable-public-ips
gcloud projects add-iam-policy-binding $PROJECT --member=user:$USER_EMAIL --role=roles/compute.networkAdmin
gcloud compute networks subnets update default \
--region=$REGION \
--enable-private-ip-google-access
# launch private ip
gcloud dataflow jobs run job2 \
--gcs-location gs://dataflow-templates-"REGION"/latest/Word_Count \
--region $REGION \
--staging-location gs://$PROJECT/tmp \
--parameters inputFile=gs://dataflow-samples/shakespeare/kinglear.txt,output=gs://$PROJECT/results/outputs --disable-public-ips
