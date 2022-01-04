Deploy "proxmox" first, and "flux" second.
Sadly Terraform doens't support dynamic providers yet, so it isn't possible to deploy everything as a single command.

TODO: Install calico before installing flux
╰─ helm repo add projectcalico https://docs.projectcalico.org/charts
╰─ helm install calico projectcalico/tigera-operator --version v3.20.3
