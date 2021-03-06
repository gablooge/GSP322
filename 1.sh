#!/bin/bash
gcloud auth revoke --all

while [[ -z "$(gcloud config get-value core/account)" ]]; 
do echo "waiting login" && sleep 2; 
done

while [[ -z "$(gcloud config get-value project)" ]]; 
do echo "waiting project" && sleep 2; 
done

gcloud compute firewall-rules delete "open-access" --quiet
gcloud compute instances start bastion --zone=us-central1-b
gcloud compute instances add-tags bastion --tags=bastion --zone=us-central1-b
gcloud compute instances add-tags juice-shop --tags=juice-shop --zone=us-central1-b

gcloud compute firewall-rules create "allow-ssh-from-iap" --network=acme-vpc --target-tags=bastion --allow=tcp:22 --source-ranges="35.235.240.0/20" --description="Narrowing SSH traffic"

gcloud compute firewall-rules create "allow-http-juice-shop" --network=acme-vpc --target-tags=juice-shop --allow=tcp:80 --source-ranges="0.0.0.0/0" --description="Narrowing HTTP traffic"

gcloud compute firewall-rules create "allow-ssh-mgmt-subnet" --network=acme-vpc --target-tags=juice-shop --allow=tcp:22 --source-ranges="192.168.10.0/24" --description="Narrowing SSH traffic"


# gcloud beta compute ssh --zone "us-central1-b" "bastion" 

# dosn't work ssh trough terminal just using the console
export PROJECT_ID=$(gcloud info --format='value(config.project)')
open "https://console.cloud.google.com/compute/instances?project=$PROJECT_ID"

# ssh 192.168.11.2
