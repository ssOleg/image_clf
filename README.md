# image_clf


## Description

The project provides a solution that helps to classify images by TensorFlow models.

It is an easy way to run web application locally on any device or to deploy it to cloud providers like Google Cloud in a few steps.

The solution includes docker images/containers that serve TensorFlow server and web application to quickly load data into the system, recognize data and provide information about that data based on output from machine learning models.


## Usage

It is required to make next steps to start using ImageCLF:

0. Clone or download an app repository
1. Go into the folder where the app is cloned/downloaded
2. Build a docker image by running the command -> `docker build . -t image_clf`
3. Do something useful while the build is running
4. After build is finished start a container to serve solution by running the command -> `docker run -p <your port for example 5000 or any free port on your system>:5000 -it --name image_clf_container image_clf`
5. In opened container terminal run command -> `start_services`
6. Go to `localhost:<your port for example 5000 or any free port on your system>` in your browser
7. Enjoy usage


## Configuring deployment pipeline

Use spin to create an app in Spinnaker.
```
spin application save --application-name test \
                      --owner-email example@example.com \
                      --cloud-providers kubernetes \
                      --gate-endpoint <your-gate-endpoint>
```
Run the following commands to upload an example pipeline to your Spinnaker instance
```
PROPERTIES_FILE="~/image_clf/properties"
source "$PROPERTIES_FILE"

sed -i s/PROJECT/$PROJECT/g sample.yaml
sed -i s/PROJECT/$PROJECT/g cloudbuild.yaml
sed s/PROJECT/$PROJECT/g pipeline.json > pipeline-final.json
sed s/SECRET/$SECRET/g pipeline.json > pipeline-final.json

spin pipeline save --gate-endpoint <your-gate-endpoint> -f pipeline-final.json
```


