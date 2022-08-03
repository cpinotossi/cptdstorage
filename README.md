# Storage Demo

## Blob NFS demo

Based on [MS Docs NFS on Blob](https://docs.microsoft.com/en-us/azure/storage/blobs/network-file-system-protocol-support-how-to)

NOTE:
- The subnet of the vnet will need to have service endpoint microsoft.storage turned on.
- The storage account has to use LRZ or ZRS.
- The storage account needs to have firewall turned on.
- Storage Blob Index does not work.

Please keept in mind, by turning on NFS support some of the Blob Storage feature will not work. See [here](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-feature-support-in-storage-accounts) for further details.

### Define env variables

~~~ bash
prefix=cptdstorage
myip=$(curl ifconfig.io)
myobjectid=$(az ad user list --query '[?displayName==`ga`].objectId' -o tsv)
~~~

### Create Azure resources

~~~ bash
az group delete -n $prefix -y
az group create -n $prefix -l eastus
az deployment group create -n $prefix -g $prefix --template-file bicep/deploy.bicep -p myobjectid=$myobjectid myip=$myip
~~~

### Upload content to blob storage

~~~ bash
az storage blob upload-batch --account-name $prefix --auth-mode login -d $prefix -s test
~~~

### SSH into VM via azure bastion client

> IMPORTANT: The following commands need to executed on powershell.

~~~ bash
$prefix="cptdstorage"
$vmid=az vm show -g $prefix -n ${prefix}lin --query id -o tsv
az network bastion ssh -n ${prefix}bastion -g $prefix --target-resource-id $vmid --auth-type "AAD"
~~~

### Mount the blob storage container

Inside the vm execute the following commands.

~~~ bash
sudo -i
apt install nfs-common -y
prefix=cptdstorage
mkdir -p /mnt/test
mount -o sec=sys,vers=3,nolock,proto=tcp ${prefix}.blob.core.windows.net:/${prefix}/${prefix}  /mnt/test
ls /mnt/test/
chgrp -R chpinoto /mnt/test/
~~~

### xRDP into VM via azure bastion client

Based on https://docs.microsoft.com/en-us/azure/virtual-machines/linux/use-remote-desktop?WT.mc_id=Portal-Microsoft_Azure_HybridNetworking

> IMPORTANT:The following commands need to executed on powershell.

~~~ bash
$prefix="cptdstorage"
$vmid=az vm show -g $prefix -n ${prefix}lin --query id -o tsv
az network bastion rdp -n ${prefix}bastion -g $prefix --target-resource-id $vmid
~~~

### clean up

~~~ text
az group delete -n $prefix -y
~~~

## Archive Demo

TBD


## todo

- Demo https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-index-how-to?tabs=azure-portal
- Use Bicep script resource to upload test file.

# Misc

## How to delete VM and all resources

> NOTE: You will need to have setup the property "deleteOption: 'Delete'" inside the vm resource subresources nic and os-storage.

~~~ bash
az vm delete -g $prefix -n ${prefix}lin -y
~~~

## Show Storage Account firewall settings

~~~ bash
az storage account show -n $prefix -g $prefix --query networkRuleSet
~~~

## How to verify if all resources have been deployed 

You can list them via cli.

~~~ bash
az resource list -g $prefix -o table
~~~

## How to find the deployment error message?

~~~ bash
az deployment operation group list -g $prefix -n create-vnet --query "[?properties.provisioningState=='Failed'].properties.statusMessage.error"
~~~

## How to know the log analytic settings?

You need to look it up in the corresponding Diagnostig Settings here:
https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/resource-manager-diagnostic-settings#diagnostic-setting-for-azure-storage

## Linux user rights assignment

~~~ bash
ls -la /mnt/test/
~~~

Output: 
~~~ text
total 4
drwxr-x--- 2 root root    0 Feb 23 07:33 .
drwxr-xr-x 4 root root 4096 Feb 23 07:32 ..
~~~

figure out your group

~~~ bash
groups
~~~

Add group chpinoto to folder /mnt/test/

~~~ bash
chgrp -R chpinoto /mnt/test/
~~~

~~~ bash
root@cptdstoragelin:~# ls -la /mnt/test/
total 4
drwxr-x--- 2 root chpinoto    0 Feb 23 07:33 .
drwxr-xr-x 4 root root     4096 Feb 23 07:32 ..
~~~

## git tips

~~~ bash
git init -m master
gh repo create cptdstorage --public
git remote add origin https://github.com/cpinotossi/cptdstorage.git
git remote get-url --all origin
git status
git add *
git add .gitignore
git commit -m"SMB via Azure blob storage account"
git tag v1.0
git push --atomic origin master v1.0
~~~

