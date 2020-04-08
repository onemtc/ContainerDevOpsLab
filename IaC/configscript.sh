#!/bin/bash
# exit when any command fails
set -e

Prefix="xxx"   # must be globally unique; replace xxx with your initials
rg="${Prefix}devopscontainerlabRG"
location="EastUS"
reg="${Prefix}devopslab" 
appplan="containerlabplan"
appname="${Prefix}labapp"
sqlservername="${Prefix}sqllab"

az group create --name $rg --location $location

az acr create -n $reg -g $rg --sku Standard --admin-enabled true

az appservice plan create -n $appplan -g $rg --is-linux
az webapp create -n $appname -g $rg -p $appplan -i "${reg}.azurecr.io/myhealth.web:latest"
az webapp config container set -n $appname -g $rg \
       --docker-registry-server-url "https://${reg}.azurecr.io" \
       --docker-registry-server-user ${reg}
az webapp config connection-string set -g $rg -n $appname -t SQLAzure --settings \
     defaultConnection="Data Source=tcp:${sqlservername}.database.windows.net,1433;Initial Catalog=mhcdb;User Id=sqladmin;Password=P2ssw0rd1234;"

az sql server create -l $location -g $rg -n $sqlservername -u sqladmin -p P2ssw0rd1234
az sql db create -g $rg -s $sqlservername -n mhcdb --service-objective S0
az sql server firewall-rule create --resource-group $rg --server $sqlservername \
       --name AllowAllAzureIps --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
