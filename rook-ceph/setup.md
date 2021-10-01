## Step1
kubectl apply -f ./common.yaml

## Step2
kubectl apply -f ./operator.yaml

## Step3
sh images.sh
kubectl apply -f ./cluster.yaml

## Step4
kubectl apply -f ./dashboard-external-http.yaml

## Step5
kubectl apply -f ./toolbox.yaml
