# Storage Demo

## Blob SMB demo

Based on [MS Docs NFS on Blob](https://docs.microsoft.com/en-us/azure/storage/blobs/network-file-system-protocol-support-how-to)

NOTE:
- The subnet of the vnet will need to have service endpoint microsoft.storage turned on.
- The storage account has to use LRZ or ZRS.
- The storage account needs to have firewall turned on.

### Define env variables

~~~ text
prefix=cptdstorage
myip=$(curl ifconfig.io)
myobjectid=$(az ad user list --query '[?displayName==`ga`].objectId' -o tsv)
az group create -n $prefix -l eastus
az deployment group create -n $prefix -g $prefix --template-file bicep/deploy.bicep -p myobjectid=$myobjectid myip=$myip
mkdir test
echo 'Hello World' > test/test.txt
az storage blob upload-batch --account-name $prefix --auth-mode login -d $prefix -s test
~~~

### Create Azure resources

~~~ text
az group create -n $prefix -l eastus
az deployment group create -n $prefix -g $prefix --template-file bicep/deploy.bicep -p myobjectid=$myobjectid myip=$myip
mkdir test
echo 'Hello World' > test/test.txt
az storage blob upload-batch --account-name $prefix --auth-mode login -d $prefix -s test
~~~

### Upload content to blob storage

~~~ text
az storage blob upload-batch --account-name $prefix --auth-mode login -d $prefix -s test
~~~

### SSH into VM via azure bastion client

> IMPORTANT:The following commands need to executed on powershell.

~~~ text
$prefix="cptdstorage"
$vmid=az vm show -g $prefix -n ${prefix}lin --query id -o tsv
az network bastion ssh -n ${prefix}bastion -g $prefix --target-resource-id $vmid --auth-type "AAD"
~~~

### Mount the blob storage container

Inside the vm execute the following commands.

~~~ text
sudo -i
apt install nfs-common -y
prefix=cptdstorage
mkdir -p /mnt/test
mount -o sec=sys,vers=3,nolock,proto=tcp ${prefix}.blob.core.windows.net:/${prefix}/${prefix}  /mnt/test
ls /mnt/test
cat /mnt/test/test.txt
~~~

Outcome should be "hello world".

clean up

~~~ text
az group delete -n $prefix -y
~~~

# Misc

## Show Storage Account firewall settings

~~~ text
az storage account show -n $prefix -g $prefix --query networkRuleSet
~~~

## How to verify if all resources have been deployed 

You can list them via cli.

~~~ text
az resource list -g $prefix -o table
~~~

## How to find the deployment error message?

~~~ text
az deployment operation group list -g $prefix -n create-vnet --query "[?properties.provisioningState=='Failed'].properties.statusMessage.error"
~~~

## How to know the log analytic settings?

You need to look it up in the corresponding Diagnostig Settings here:
https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/resource-manager-diagnostic-settings#diagnostic-setting-for-azure-storage

## git tips

~~~ text
git init -m master
gh repo create cptdstorage --public
git remote add origin https://github.com/cpinotossi/cptdstorage.git
git remote get-url --all origin
git status
git add *
git push origin master

