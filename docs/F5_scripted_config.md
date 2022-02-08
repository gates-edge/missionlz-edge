# Post-deployment F5 BIG-IP configuration

## Table of Contents

1. [Introduction](#introduction)
1. [Prerequisites](#prerequisites)
1. [Accessing the F5](#accessing-the-f5)
1. [Configuring the F5 BIG-IP](#configuring-the-f5-big-ip)
1. [Applying Network and STIG Configurations to F5](#applying-network-and-stig-configurations-to-f5)

## Introduction

This guide will walk the MLZ-Edge deployer thru the steps to configure the F5 BIG-IP with the base configurations that will implement the following functionalities:

- Spoke-to-Spoke (East-West) traffic routing
- Spoke-to-Platform (North-South) traffic routing
- Allow Inbound RDP traffic to the Windows management VM
- Apply applicable DoD compliance related configurations

## Prerequisites

- Public IP address of the Windows 2019 management VM deployed as part of the MLZ solution.
- Password of `azureuser` account created on Windows 2019 management VM (created and stored in Key Vault at deployment time).
- IP assigned to the network interface card of the F5 BIG-IP attached to the `mgmt` subnet (This is normally `.4` of the subnet assigned to the `mgmt` subnet. The default is `10.90.0.4`). This value is referred to as `<mgmt-ip-of-f5>` in the documentation sections below.
- F5 BIG-IP license key.
- Password or SSH private key for `f5admin` account. When deploying using `password` for the value of the `f5VmAuthenticationType` parameter, the password gets created and stored in Key Vault at deployment time. When using `sshPublicKey` for the value of the `f5VmAuthenticationType` parameter, the SSH private key will be stored in the repo of the system used to deploy the MLZ instance.

## Accessing the F5

From the system used to deploy the instance, RDP into the Windows 2019 management VM using the public IP. The credentials to use to authenticate to the VM are `azureuser` along with the password retrieved from the Key Vault.

Once logged onto the Windows 2019 VM, the administrator will be presented with the Server Manager application. On the left hand side of the `Server Manager` application, click on the `Local Server` blade. In the `PROPERTIES` pane for the `Local Server`, click the `IE Enhanced Security Configuration` setting and select `Off` for both `Administrators` and `Users`. Close the `Server Manager` application.

From the Windows 2019 management VM, open Internet Explorer and enter the URL `https://<private_management_ip_of_the_F5_BIG-IP>`. The URL for a default deployment would be (<https://10.90.0.4>). A page stating `This site is not secure` should appear. Click the `More information` drop down on the page and then click on `Go on to the webpage (not recommended)` link.

The `F5 BIG-IP Configuration Utility` page should appear. Login to the page with `f5admin` along with the password retrieved from the Key Vault.

## Configuring the F5 BIG-IP

Once logged into the F5 BIG-IP, the screen displayed will be the `Welcome` page of the `Setup Utility`. Click `Next` on the page.

On the `General Properties`, click `Activate` to enter the license key. Enter the license key into the `Base Registration Key` field, select `Manual` in the `Activation Method` field and then click the `Next` button.

On the next screen, select `Download/Upload File` and then click the `Click Here To Download Dossier File`. Transfer the `dossier.do` file downloaded to the `Downloads` folder to a system that has Internet connectivity.

From a system that has Internet connectivity, using a browser...navigate to the [F5 License Activation site](https://activate.f5.com/license)

On the `Activate F5 Product` webpage, click on `Choose File`, select the `dossier.do` file transferred from the BIG-IP and then click `Next`.

On the `End User Legal Agreement` page, check the box next to `I have read and agree to the terms of this license` near the bottom of the page and then click `Next`.

Click the button `Download license` to download the license file. Transfer the `License.txt` file back to the Windows 2019 management VM.

Back on the Windows 2019 management VM on the `Setup Utility >> License` page, click the Browse button to select the license file to upload. In the browser window that opens, navigate to and select the `License.txt` file downloaded from the F5 activation site and then click `Next` to upload the file to the F5 BIG-IP.

The F5 BIG-IP should now be licensed and activated and the `Resource Provisioning` page should be displayed.

>**NOTE**: The BIG-IP may log the user out before presenting the `Resource Provisioning` page. If this happens, re-authenticate and continue the setup process.

On the `Resource Provisioning` page, leave all default settings as configured and click on the `Next` button at the bottom of the page.

On the `Device Certificates` page, import a customer cert if desired or to proceed with the self-signed cert for testing purposes click `Next`.

On the `Platform` page, make the following configurations and then click `Next`:

- Enter a desired hostname for the F5 (example: `mlzashf5.local`)
- Select the desired time zone
- Uncheck the box next to `Disable login` for the Root Account field
- Enter a secure password for the Root account
- Select `Specify Range` in the `SSH IP Allow` section and then enter the CIDR information for the management subnet (default is 10.90.0.0/24)

On the `Network` page, click `Finished` under `Advanced Network Configuration`.

## Applying Network and STIG Configurations to F5

The MLZ repo that is part of the deployment container image contains the bash script called `mlzash_f5_cfg.sh` that will be used to apply STIG and network settings to the BIG-IP. The script is located in the `/src/scripts/f5config` folder. Copy the script over to the Windows 2019 management VM and apply to the F5 BIG-IP using the steps below:

- From the Windows 2019 management VM, copy the bash script over to the F5 BIG-IP by running the command below:
  - `scp <path_to_script>\mlzash_f5_cfg.sh root@<mgmt-ip-of-f5>:/var/config/rest/downloads/mlzash_f5_cfg.sh`
- SSH into the F5 BIG-IP as the root account by running the command: `ssh root@<mgmt-ip-of-f5>`.
- Once on the BIG-IP, ensure the prompt is `config #`
- Apply the execute flag to the `mlzash_f5_stig.sh` script by execute the command below:
  - `chmod +x /var/config/rest/downloads/mlzash_f5_cfg.sh`
- Execute the bash script using the command below:
  - `sh /var/config/rest/downloads/mlzash_f5_cfg.sh`
- Once the script completes, reboot the F5 BIG-IP by entering the command `reboot`