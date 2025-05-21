#!/bin/bash

# Variáveis
RESOURCE_GROUP="rg-dashmottu"
LOCATION="eastus2"
VM_NAME="vm-dashmottu"
IMAGE="Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
SIZE="Standard_D2s_v3"
ADMIN_USERNAME="acode"
ADMIN_PASSWORD="Acode@2025vm"
DISK_SKU="StandardSSD_LRS"
PORT=8080

# Criar grupo de recursos
echo "Criando grupo de recursos: $RESOURCE_GROUP..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Criar a VM Linux
echo "Criando a máquina virtual: $VM_NAME..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $IMAGE \
  --size $SIZE \
  --authentication-type password \
  --admin-username $ADMIN_USERNAME \
  --admin-password $ADMIN_PASSWORD \
  --storage-sku $DISK_SKU \
  --public-ip-sku Standard

# Abrir portas necessárias
echo "Abrindo porta $PORT ..."
az vm open-port --port $PORT --resource-group $RESOURCE_GROUP --name $VM_NAME

# 04) Obter IP público da VM
IP_PUBLICO=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)
echo "IP público da VM: $IP_PUBLICO"

# 05) Instalar Docker via SSH
echo "Instalando Docker na VM..."
ssh -o StrictHostKeyChecking=no $ADMIN_USERNAME@$IP_PUBLICO << EOF
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $ADMIN_USERNAME
EOF


echo "✅ Provisionamento completo!"
