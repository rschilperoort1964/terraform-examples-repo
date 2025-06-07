## Steps to prepare for the demo:

1. Install SOPS (https://github.com/getsops/sops) 
1. Create adminpassword.json in this folder
1. Create a key vault and a key vault key with the encryption key
1. Run the following commands to encrypt the file:
`sopskey=$(az keyvault key show --name sops-key --vault-name <VAULT_NAME> --subscription <SUBSCRIPTION> --query key.kid -o tsv)` \
`sops --encrypt --azure-kv $sopskey adminpassword.json > adminpassword.enc.json`
1. Deploy the solution to create a tfstate file to show that the decrypted secret is still in there
