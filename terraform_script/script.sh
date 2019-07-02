#!/bin/bash
VARSTMP="terraform.tfvars"

info ()
{
clear
echo "Selecione o vcenter: "
echo "1 - vcenter1 (fqdn)"
echo "2 - vcenter2 (fqdn)"

read -p "vCenter [ 1/2 ]: " vsphere_server

if [ $vsphere_server = 1 ] ; then

 echo "vsphere_server = \"vcenter1\"" > $VARSTMP

	elif [ $vsphere_server = 2 ] ; then
	echo "vsphere_server = \"vcenter2\"" > $VARSTMP
fi
read -p "usuario: " vsphere_user ; echo "vsphere_user = \"$vsphere_user\"" >> $VARSTMP
stty -echo
read -p "Pass: " vsphere_password ; echo "vsphere_password = \"$vsphere_password\"" >> $VARSTMP
stty sane
echo 
read -p "Data Center: " vsphere_dc ; echo "vsphere_dc = \"$vsphere_dc\"" >> $VARSTMP
read -p "Datastore: " datastore_name ; echo "datastore_name = \"$datastore_name\"" >> $VARSTMP
echo "pool_name = \"Resources\"" >> $VARSTMP
read -p "portgroup: " vlan_name; echo "vlan_name = \"$vlan_name\"" >> $VARSTMP
read -p "nome do template de maquina virtual: " template_name ; echo "template_name = \"$template_name\"" >> $VARSTMP
read -p "nome da VM: " vm_name ; echo "vm_name = \"$vm_name\"" >> $VARSTMP
read -p "IP: " ipv4 ; echo "ipv4 = \"$ipv4\"" >> $VARSTMP
read -p "mask ID: " mask_id ; echo "mask_id = \"$mask_id\"" >> $VARSTMP
read -p "gateway: " ipv4_gateway ; echo "ipv4_gateway = \"$ipv4_gateway\"" >> $VARSTMP
read -p "DNS1: " dns_server ; echo "dns_server = \"$dns_server\"" >> $VARSTMP
read -p "DNS2: " dns_server2 ; echo "dns_server2 = \"$dns_server2\"" >> $VARSTMP
read -p "SUFIX DNS: " dns_suffix ; echo "dns_suffix = \"$dns_suffix\"" >> $VARSTMP
echo
clear
echo "######################################"
echo "Confirmar informações: "
echo
cat $VARSTMP | grep -v vsphere_password
}
 delete ()
                {
                rm -rf $VARSTMP
                rm -rf *tfstate
                }


info
deploy ()
{
clear
cat $VARSTMP | grep -v vsphere_password

echo "----------------------------------------"
read -p "Confirmar informações? Pressione \"e\" para editar alguma informação: [y/n/e]: " RES
        if [ $RES = Y -o $RES = y ] ;then
                echo "Confirmado."
                echo "Prosseguindo..."
		rm -rf *tfstate
		terraform plan
		read -p "Deseja continuar o deploy? [Y/n]: " RES2
			if [ $RES2 = y -o $RES2 = Y ] ;then
			terraform apply -auto-approve
				elif [ $RES2 = n -o $RES2 = N ] ; then
				echo "Saindo..."
				delete
			fi
	elif [ $RES = e -o $RES = E ] ; then
		altera ()
		{
		clear 
		echo "----------------------------------"
        	echo "Qual informação deseja alterar? "
 		cat $VARSTMP 
		echo "----------------------------------"
		read -p "Digite o nome da variavel: " VAR
		read -p "Digite o valor da variavel: " VARV
		sed -i 's/^'$VAR' .*/'$VAR' = \"'$VARV'\"/g' $VARSTMP
		cat $VARSTMP
		echo "Substituição realizada. Deseja alterar algo mais?"
	        }
		altera	
		deploy
		delete

         elif [ $RES = n -o $RES = N ] ;then
                        echo "Digitar novamente as informações: "
			echo "Saindo... Voce digitou: $RES"
			delete
			exit 0
         else
                                echo "Opcao nao reconhecida. Saindo... Voce digitou: $RES"
				delete
                                exit 1
        fi
}

deploy
delete

