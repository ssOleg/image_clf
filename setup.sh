PROPERTIES_FILE="~/test_flask/properties"
source "$PROPERTIES_FILE"
#Halyard installation
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh
. ~/.bashrc
#login
gcloud auth login
# set project
gcloud config set project $PROJECT
gcloud auth application-default login
# download kubeconfig to local computer from a cluster by name
gcloud container clusters get-credentials $GKE_NAME--zone $ZONE --project $PROJECT
# get kubeconfig context
CONTEXT=$(kubectl config current-context)
# this service account uses the ClusterAdmin role -- this is not necessary, more restrictive roles can by applied.
kubectl apply --context $CONTEXT -f https://spinnaker.io/downloads/kubernetes/service-account.yml
# get service token
TOKEN=$(kubectl get secret --context $CONTEXT \
   $(kubectl get serviceaccount spinnaker-service-account \
       --context $CONTEXT \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)
# set credentials
kubectl config set-credentials ${CONTEXT}-token-user --token $TOKEN
# set context
kubectl config set-context $CONTEXT --user ${CONTEXT}-token-user
# enable kubernetes
hal config provider kubernetes enable
# add in provider account
hal config provider kubernetes account add spinnaker-account --provider-version v2 --context ${CONTEXT}
# finally enable artifacts
hal config features edit --artifacts true
# gcs configuration
SERVICE_ACCOUNT_NAME=spinnaker-gcs-account
SERVICE_ACCOUNT_DEST=~/.gcp/gcs-account.json
# create service account
gcloud iam service-accounts create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME
# set service account email
SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')
# bind iam policy
gcloud projects add-iam-policy-binding $PROJECT \
    --role roles/storage.admin --member serviceAccount:$SA_EMAIL
mkdir -p $(dirname $SERVICE_ACCOUNT_DEST)
# create service account keys
gcloud iam service-accounts keys create $SERVICE_ACCOUNT_DEST --iam-account $SA_EMAIL
BUCKET_LOCATION=us
# set configuration
hal config storage gcs edit --project $PROJECT \
    --bucket-location $BUCKET_LOCATION \
    --json-path $SERVICE_ACCOUNT_DEST
# enable gcs
hal config storage edit --type gcs
# artifact account name
ARTIFACT_ACCOUNT_NAME1=my-gcs-artifact-account
# enable gcs artifact support
hal config artifact gcs account add $ARTIFACT_ACCOUNT_NAME1 \
    --json-path $SERVICE_ACCOUNT_DEST
hal config artifact gcs enable
ARTIFACT_ACCOUNT_NAME=my-github-artifact-account
hal config features edit --artifacts true
hal config artifact github enable
hal config artifact github account add  $ARTIFACT_ACCOUNT_NAME --token-file $TOKEN_FILE
#deploy your changes
hal config deploy edit --type distributed --account-name spinnaker-account
hal config version edit --version $(hal version latest -q)
# gcb & pubsub configuration
gcloud services enable cloudbuild.googleapis.com
SERVICE_ACCOUNT_NAME=spinnaker-account
SERVICE_ACCOUNT_DEST=~/.gcp/gcs-account.json
PROJECT=$(gcloud info --format='value(config.project)')
SUBSCRIPTION_NAME=cloud-builds
gcloud pubsub subscriptions create ${SUBSCRIPTION_NAME} \
    --topic projects/${PROJECT}/topics/cloud-builds \
    --project ${PROJECT}
hal config pubsub google subscription add $SUBSCRIPTION_NAME \
    --project ${PROJECT} \
    --subscription-name ${SUBSCRIPTION_NAME} \
    --message-format GCB
hal config pubsub google enable
hal config ci gcb enable
SERVICE_ACCOUNT_NAME=my-gcb-ci-account
SERVICE_ACCOUNT_DEST=~/.gcp/my-gcb-ci-account.json
# Create a new service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME
# Add roles
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com" --role "roles/pubsub.publisher"
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com" --role "roles/pubsub.subscriber"
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com" --role "roles/pubsub.admin"
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com" --role "roles/pubsub.editor"
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com" --role "roles/cloudbuild.builds.editor"
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com" --role "roles/cloudbuild.builds.viewer"
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com" --role "roles/cloudbuild.builds.builder"
gcloud projects add-iam-policy-binding ${PROJECT} --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com" --role "roles/cloudbuild.serviceAgent"
# Download a key file containing the credentials
gcloud iam service-accounts keys create ${SERVICE_ACCOUNT_DEST} --iam-account ${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com
SERVICE_ACCOUNT_NAME2=gcb-ci-account
hal config ci gcb account add $SERVICE_ACCOUNT_NAME2 --project ${PROJECT} --subscription-name $SUBSCRIPTION_NAME --json-key $SERVICE_ACCOUNT_DEST
# docker registry configuration
# login Docker with the below command
docker login -u _json_key -p "$(cat ~/.gcp/my-gcb-ci-account.json)"  https://gcr.io
# Create  a new file called, ‘.dockerconfigjson ‘ with the content of “auth” value from .docker/config.json file.
# Create a Secret based on existing Docker credentials
kubectl create secret generic regcred --from-file=.dockerconfigjson=~/.docker
/config.json --type=kubernetes.io/dockerconfigjson
hal config provider docker-registry account add my-docker-registry --address gcr.io --username _json_key --password-file ~/.gcp/my-gcb-ci-account.json
# Configure Spinnaker to work with Google Cloud Build
mkdir -p $(dirname ~/.hal/default/profiles/igor-local.yml)
tee -a ~/.hal/default/profiles/igor-local.yml << END
locking:
  enabled: true
END
hal deploy apply
