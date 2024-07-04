---
title: Privileged Container
tags: [container]
keywords: container, privileged, debug
last_updated: Jul 4, 2024
summary: "privileged container for troubleshooting"
sidebar: mydoc_sidebar
permalink: privileged_container.html
folder: Container
---

# Privileged Container
======
With `Privileged` container, packages can be installed for troubleshooting container issues. 

```bash
$ cat <<EOF > privileged-container.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: privileged-container
  name: privileged-container
spec:
  containers:
  - image: centos:centos7.9.2009
    name: privileged-container
    command:
    - /bin/bash
    - -c
    - sleep 1d
    securityContext:
      privileged: true
  restartPolicy: Always
EOF

$ kubectl apply -f privileged-container.yaml
```

{% include links.html %}
