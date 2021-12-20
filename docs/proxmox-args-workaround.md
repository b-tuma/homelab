## Proxmox - Workaround to "only root can set args config"

Normally you should not be able to pass arguments via API calls to Proxmox, but currently there is no way to pass an Ignition file, so a workaround is necessary.
**Be aware that this workaround can have some security implications.**

SSH into your Proxmox server and open file */usr/share/perl5/PVE/API2/Qemu.pm*, near line 408 should look like this:

    } elsif ($opt eq 'vmstate') {
        # the user needs Disk and PowerMgmt privileges to change the vmstate
        # also needs privileges on the storage, that will be checked later
        $rpcenv->check_vm_perm($authuser, $vmid, $pool, ['VM.Config.Disk', 'VM.PowerMgmt' ]);
    } else {
        # catches hostpci\d+, args, lock, etc.
        # new options will be checked here
        die "only root can set '$opt' config\n";
    }

Replace with the following block:

    } elsif ($opt eq 'vmstate') {
        # the user needs Disk and PowerMgmt privileges to change the vmstate
        # also needs privileges on the storage, that will be checked later
        $rpcenv->check_vm_perm($authuser, $vmid, $pool, ['VM.Config.Disk', 'VM.PowerMgmt' ]);
    } elsif ($opt eq 'args') {
        # CAUTION: Allowing this parameter have security implications.
        # Usually only root@pam (directly, no APIs) would have permission.
        $rpcenv->check_vm_perm($authuser, $vmid, $pool, ['VM.Config.Options']);
    } else {
        # catches hostpci\d+, lock, etc.
        # new options will be checked here
        die "only root can set '$opt' config\n";
    }

Now it should be possible to pass args if the API Token has the **VM.Config.Options** permission.

*Tested in PVE Manager version 7.0-14+1/08975a4c.*
