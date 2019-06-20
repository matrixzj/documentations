---
title: Segmentation Faults (Segfaults)
tags: [memory]
keywords: segfaults
last_updated: Juue 17, 2019
summary: "Things related with Memory Segfaults"
sidebar: mydoc_sidebar
permalink: memory_segfaults.html
folder: memory
---

## Segmentation Faults(Segfaults)
=====

### What is a segfault?

A segmentation fault (aka segfault) is a common condition that causes programs to crash. Segfaults are caused by a program trying to read or write an illegal memory location. Program memory is divided into different segments: 

* a text segment for program instructions
* a data segment for variables and arrays defined at compile time
* a stack segment for temporary (or automatic) variables defined in subroutines and functions
* a heap segment for variables allocated during runtime by functions, such as malloc (in C) 

A segfault occurs when a reference to a variable falls outside the segment where that variable resides, or when a write is attempted to a location that is in a read-only segment. In practice, segfaults are almost always due to trying to read or write a non-existent array element, not properly defining a pointer before using it, or (in C programs) accidentally using a variable's value as an address (see the scanf example below).  
On Unix family operating systems, a signal called SIGSEGV - signal #11, defined in the system header file signal.h - is then sent to to process. The default action for SIGSEGV is abnormal termination: the process ends and an application core file may be written (depending on the system's configuration).

### Why does a segfault occur?

A segmentation fault can occur under the following circumstances:

1. A bug (software defect) in the program or command is encountered, for example a buffer overflow (an attempt to access memory beyond the end of an array). This can typically be resolved by applying errata or vendor software updates.

2. A hardware problem affects the virtual memory subsystem. For example, a RAM DIMM or CPU cache is defective.

3. An attempt is made to execute a program that was not compiled/built correctly.

### How to inteprete segfault log? 
```bash
May 18 23:55:05 dhcp-192-66 kernel: test[7779]: segfault at 0 ip 00007fdddf181664 sp 00007ffcbb5eb568 error 6 in libc-2.17.so[7fdddf0f2000+1c3000]
```
* **test[7779]**   
   program name and pid number
* **segfault at 0**
   memory address (in hex) that caused the segfault when the program tried to access it. Here the address is 0, so we have a null dereference, usually it is a null pointer 
* **ip 00007fdddf181664**    
   register name and register value for current running instruction
* **sp 00007ffcbb5eb568**  
   regester name and register value for stack (top of stack)
* **error 6**  
   error and return code, which is defined in arch/x86/mm/fault.c  
   [Segmentation fault error decoder](https://rgeissert.blogspot.com/p/segmentation-fault-error.html)

### segfault error code
```
/*
 * Page fault error code bits:
 *
 *   bit 0 ==    0: no page found       1: protection fault(eg. writing to a read-only mapping)
 *   bit 1 ==    0: read access         1: write access
 *   bit 2 ==    0: kernel-mode access  1: user-mode access
 *   bit 3 ==                           1: use of reserved bit detected(kernel will panic if this happens)
 *   bit 4 ==                           1: fault was an instruction fetch, not data read or write
 *   bit 5 ==                           1: protection keys block access
 */
enum x86_pf_error_code {

        PF_PROT         =               1 << 0,
        PF_WRITE        =               1 << 1,
        PF_USER         =               1 << 2,
        PF_RSVD         =               1 << 3,
        PF_INSTR        =               1 << 4,
        PF_PK           =               1 << 5,
};
```
* 0 (00000) / 8 (01000) / 16 (10000) / 24 (11000)  
   a kernel-mode read resulting in no page being found / a reserved bit was detected / read(instruction fetch) / a reserved bit was detected + read(instruction fetch)
* 1 (00001) / 9 (01001) / 17 (10001) / 25 (11001)  
   a kernel-mode read resulting in a protection fault / a reserved bit was detected / read(instruction fetch) / a reserved bit was detected + read(instruction fetch)
* 2 (00010) / 10 (01010) / 18 (10010) / 26 (11010)  
   a kernel-mode write resulting in no page being found / a reserved bit was detected / write(instruction fetch) / a reserved bit was detected + write(instruction fetch)
* 3 (00011) / 11 (01011) / 19 (10011) / 27 (11011)  
   a kernel-mode write resulting in a protection fault / a reserved bit was detected / write(instruction fetch) / a reserved bit was detected + write(instruction fetch)
* 4 (00100) / 12 (01100) / 20 (10100) / 28 (11100)  
   a user-mode read resulting in no page being found / a reserved bit was detected / read(instruction fetch) / a reserved bit was detected + read(instruction fetch)
* 5 (00101) / 13 (01101) / 21 (10101) / 29 (11101)  
   a user-mode read resulting in a protection fault / a reserved bit was detected / read(instruction fetch) / a reserved bit was detected + read(instruction fetch)
* 6 (00110) / 14 (01110) / 22 (10110) / 30 (11110)  
   a user-mode write resulting in no page being found / a reserved bit was detected / write(instruction fetch) / a reserved bit was detected + write(instruction fetch)
* 7 (00111) / 15 (01111) / 23 (10111) / 31 (11111)  
   a user-mode write resulting in a protection fault / a reserved bit was detected / write(instruction fetch) / a reserved bit was detected + write(instruction fetch)
* [protection keys](https://lwn.net/Articles/643797/)

### Example
* calling memset() as shown below would cause a program to segfault:

   ```bash
   $ cat test.c
   #include <stdio.h>
   #include <string.h>
   
   int main()
   {
       memset((char *)0x0, 1, 100);
   }
   
   $ gcc test.c -o test
   
   $ ./test
   Segmentation fault
   
   $ sudo tail -n 1 /var/log/messages
   May 18 23:55:05 dhcp-192-66 kernel: test[7779]: segfault at 0 ip 00007fdddf181664 sp 00007ffcbb5eb568 error 6 in libc-2.17.so[7fdddf0f2000+1c3000]
   ```

[A Guide for Troubleshooting a Segfault](https://access.redhat.com/articles/372743)  
[What the Linux kernel's messages about segfaulting programs mean on 64-bit x86](https://utcc.utoronto.ca/~cks/space/blog/linux/KernelSegfaultMessageMeaning)  
[What are segmentation faults (segfaults), and how can I identify what's causing them?](https://kb.iu.edu/d/aqsj)

{% include links.html %}
# Segmentation Faults(Segfaults)
