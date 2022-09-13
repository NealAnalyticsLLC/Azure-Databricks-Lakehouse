# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

param(
    [Parameter(Mandatory= $True,
                HelpMessage='Enter the Azure subscription ID to deploy your resources')]
    [string]
    $subscriptionID = '',

    [Parameter(Mandatory= $True,
                HelpMessage='Enter the Azure Data Center Region to deploy your resources')]
    [string]
    $location = ''

)

Write-Host "Log in to Azure.....`r`n" -ForegroundColor Yellow
az login

az account set --subscription $subscriptionID
Write-Host "Switched subscription to '$subscriptionID' `r`n" -ForegroundColor Yellow

Write-Host "Started deploying Blockchain and NFT Service resources.....`r`n" -ForegroundColor Yellow
az deployment sub create --location "$location" --template-file .\main.bicep

Write-Host "All resources are deployed successfully.....`r`n" -ForegroundColor Green