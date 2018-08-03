CPU Soft softup
=====

A **soft lockup** is the symptom of a task or kernel thread using and not releasing a CPU for a longer period of time than allowed.

The technical reason behind a soft lock involves CPU interrupts and nmi-watchdog. For each online CPU on the system, a watchdog process gets created. This kernel thread is created with highest scheduling priority possible. This process "wakes up" once per second, gets the current time stamp for the CPU it is responsible for, and saves this into the PER-CPU data structure. There is a separate interrupt that calls a function `softlockup_tick()`, which is responsible for comparing the current time to the saved time as last recorded by the watchdog. If the current time is greater than the `watchdog_thresh` (`softlockup_thresh` in version 5), then a soft lock is reported because the real-time watchdog thread could not get onto the CPU. One common example of this is if a thread with a higher priority than the watchdog thread is attempting to acquire a spin lock, it can hold the CPU long enough for soft locks to be reported. We will further discuss this example, but please note that there are many conditions that can lead to a soft lock: they do not always involve spinlock waits.

A **spinlock** is a synchronization mechanism used to protect a resource -- typically a data structure -- from concurrent access by multiple threads. Unlike other synchronization mechanisms, a thread will continuously poll the lock until it obtains the lock. The spinlock is held until the thread releases it -- presumably because the thread no longer needs access to the resource.

Spinlocks are efficient when they are blocked for only a brief period of time, but as they prevent the CPU core from performing other work while the thread is waiting for the spinlock, they are inefficient when the thread must wait for an extended period of time.

The Kernel will report a soft lockup warning when it detects that the CPU was busy for a long time without releasing a spinlock. This is because threads should not sleep while holding the spinlock, as it might lead to deadlock. Because the threads do not sleep, the nmiwatchdog thread never gets to run, the CPU data structure timestamp never gets updated, and the kernel detects the condition and produces the warning.

