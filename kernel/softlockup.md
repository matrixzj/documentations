CPU Soft softup
=====

A **soft lockup** is the symptom of a task or kernel thread using and not releasing a CPU for a longer period of time than allowed.

The technical reason behind a soft lock involves CPU interrupts and nmi-watchdog. For each online CPU on the system, a watchdog process gets created. This kernel thread is created with highest scheduling priority possible. This process "wakes up" once per second, gets the current time stamp for the CPU it is responsible for, and saves this into the PER-CPU data structure. There is a separate interrupt that calls a function `softlockup_tick()`, which is responsible for comparing the current time to the saved time as last recorded by the watchdog. If the current time is greater than the `watchdog_thresh` (`softlockup_thresh` in version 5), then a soft lock is reported because the real-time watchdog thread could not get onto the CPU. One common example of this is if a thread with a higher priority than the watchdog thread is attempting to acquire a spin lock, it can hold the CPU long enough for soft locks to be reported. We will further discuss this example, but please note that there are many conditions that can lead to a soft lock: they do not always involve spinlock waits.

A **spinlock** is a synchronization mechanism used to protect a resource -- typically a data structure -- from concurrent access by multiple threads. Unlike other synchronization mechanisms, a thread will continuously poll the lock until it obtains the lock. The spinlock is held until the thread releases it -- presumably because the thread no longer needs access to the resource.

Spinlocks are efficient when they are blocked for only a brief period of time, but as they prevent the CPU core from performing other work while the thread is waiting for the spinlock, they are inefficient when the thread must wait for an extended period of time.

The Kernel will report a soft lockup warning when it detects that the CPU was busy for a long time without releasing a spinlock. This is because threads should not sleep while holding the spinlock, as it might lead to deadlock. Because the threads do not sleep, the nmiwatchdog thread never gets to run, the CPU data structure timestamp never gets updated, and the kernel detects the condition and produces the warning.

## Example Root Cause Analysis:

Reviewing the sample log messages below, we see reported soft lockups on CPU 1:

```bash
Aug 13 17:42:32 hostname kernel: BUG: soft lockup - CPU#1 stuck for 10s! [kswapd1:982]
Aug 13 17:42:32 hostname kernel: CPU 1:
Aug 13 17:42:32 hostname kernel: Modules linked in: mptctl mptbase sg ipmi_si(U) ipmi_devintf(U) ipmi_msghandler(U) nfsd exportfs auth_rpcgss autofs4 nfs fscache nfs_acl hidp l2cap bluetooth lockd sunrpc bonding ipv6 xfrm_nalgo crypto_api dm_multipath scsi_dh video hwmon backlight sbs i2c_ec i2c_core button battery asus_acpi acpi_memhotplug ac parport_pc lp parport shpchp hpilo bnx2(U) serio_raw pcspkr dm_raid45 dm_message dm_region_hash dm_mem_cache dm_snapshot dm_zero dm_mirror dm_log dm_mod usb_storage cciss(U) sd_mod scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
Aug 13 17:42:32 hostname kernel: Pid: 982, comm: kswapd1 Tainted: G      2.6.18-164.el5 #1
Aug 13 17:42:32 hostname kernel: RIP: 0010:[<ffffffff80064bcc>]  [<ffffffff80064bcc>] .text.lock.spinlock+0x2/0x30
Aug 13 17:42:32 hostname kernel: RSP: 0018:ffff81101f63fd38  EFLAGS: 00000282
Aug 13 17:42:32 hostname kernel: RAX: ffff81101f63fd50 RBX: 0000000000000000 RCX: 000000000076d3ba
Aug 13 17:42:32 hostname kernel: RDX: 0000000000000000 RSI: 00000000000000d0 RDI: ffffffff88442e30
Aug 13 17:42:32 hostname kernel: RBP: ffffffff800c9241 R08: 0000000000193dbf R09: ffff81068a77cbb0
Aug 13 17:42:32 hostname kernel: R10: 0000000000000064 R11: 0000000000000282 R12: ffff810820001f80
Aug 13 17:42:32 hostname kernel: R13: ffffffff800480be R14: 000000000000000e R15: 0000000000000002
Aug 13 17:42:32 hostname kernel: FS:  0000000000000000(0000) GS:ffff81101ff81a40(0000) knlGS:0000000000000000
Aug 13 17:42:32 hostname kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
Aug 13 17:42:32 hostname kernel: CR2: 00000000076fc460 CR3: 0000000000201000 CR4: 00000000000006e0
Aug 13 17:42:32 hostname kernel:
Aug 13 17:42:32 hostname kernel: Call Trace:
Aug 13 17:42:32 hostname kernel:  [<ffffffff8840933a>] :nfs:nfs_access_cache_shrinker+0x2d/0x1da
Aug 13 17:42:32 hostname kernel:  [<ffffffff8003f349>] shrink_slab+0x60/0x153
Aug 13 17:42:32 hostname kernel:  [<ffffffff80057db5>] kswapd+0x343/0x46c
Aug 13 17:42:32 hostname kernel:  [<ffffffff8009f6c1>] autoremove_wake_function+0x0/0x2e
Aug 13 17:42:32 hostname kernel:  [<ffffffff80057a72>] kswapd+0x0/0x46c
Aug 13 17:42:32 hostname kernel:  [<ffffffff8009f4a9>] keventd_create_kthread+0x0/0xc4
Aug 13 17:42:32 hostname kernel:  [<ffffffff8003298b>] kthread+0xfe/0x132
Aug 13 17:42:32 hostname kernel:  [<ffffffff8009c33e>] request_module+0x0/0x14d
Aug 13 17:42:32 hostname kernel:  [<ffffffff8005dfb1>] child_rip+0xa/0x11
Aug 13 17:42:32 hostname kernel:  [<ffffffff8009f4a9>] keventd_create_kthread+0x0/0xc4
Aug 13 17:42:32 hostname kernel:  [<ffffffff8003288d>] kthread+0x0/0x132
Aug 13 17:42:32 hostname kernel:  [<ffffffff8005dfa7>] child_rip+0x0/0x11
```

This system was also reporting soft locks for the following processes: bash, rsync, hpetfe, and kswapd.

The most important clue as to the cause of the soft lockup is the location of where the code was executing when the soft lockup was detected. This can be found on this line with the RIP (return instruction pointer):

```bash
Aug 13 17:42:32 hostname kernel: RIP: 0010:[<ffffffff80064bcc>]  [<ffffffff80064bcc>] .text.lock.spinlock+0x2/0x30
```

In this case the code was trying to acquire a spinlock and this is a typical cause of a soft lockup message. This thread is being prevented from acquiring the spinlock because - most likely - another process has been holding onto the spinlock for too long. So this soft lockup message shows a victim to the real problem and an investgation is needed to find the culprit process that is holding the spinlock. Since a process that holds a spinlock must be currently running on a CPU then a listing of the stack traces for all CPUs is needed to locate the spinlock holder (ie sysrq-t or 'bt -a' in crash). It's also possible that a highly contended reader/writer lock with many readers can cause starvation for writers especially on a NUMA based system where the cost of the memory access to the lock is not equal for all CPUs.

If the soft lockup message shows an RIP that is not trying to acquire a spinlock and is in a seemingly arbitrary place in the code then it may be the case that the process is executing an unbounded loop without relinquishing the CPU. In this case the code needs to be inspected to figure out why it has not terminated. It may be necessary to insert a conditional reschedule (cond_resched()) call in the loop to allow it to temporarily yield the CPU so that other processes can run.

For this particular example above also pay attention to this line:

```bash
Aug 13 17:42:32 hostname kernel:  [<ffffffff8840933a>] :nfs:nfs_access_cache_shrinker+0x2d/0x1da
```

Linux now supports local caching of certain file systems (currently only NFS and the in-kernel AFS file systems). This permits remote data to be cached on local disk, thus potentially speeding up future accesses to that data by avoiding the need to go to the network and fetch it again. In this case, something seems to have gone wrong. This NFS cache facility (nfs_access_cache_shrinker) went into loop to do its caching task and locked some internal resources that are needed by other processes as well (bash, kswapd, and rsync, in this case). But the NFS cache did not release the lock before 10 seconds elapsed, so the kernel prints the informational message in logs to let system administrators know about the condition.

Now we will examine why this delay might have occurred. We see the following nfs mounts:

```bash
nfs1:/abi      /abi                    nfs     soft,bg 0 0
nfs2:/d1       /servers/nfs2/d1        nfs     soft,bg 0 0
nfs3:/d1       /servers/nfs3/d1        nfs     soft,bg 0 0
nfs4:/d1       /servers/nfs4/d1        nfs     soft,bg 0 0
nfs5:/d1       /servers/nfs5/d1        nfs     soft,bg 0 0
```

There are many possibilities why this has happened. The most common is if one of the NFS shares went down because of a network connectivity problem. We also see at the time of crash the rsync utility was running, so there is a possibility that this utility was dealing with any one of the NFS shares and prevented timely access to the resource.

The default soft lockup threshold for Red Hat Enterprise Linux 5 is 10s. This has been increased to 60s in Red Hat Enterprise Linux 6.
