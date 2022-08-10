---
title: Kubernetes YAML 
tags: [container]
keywords: kubernetes, yaml
last_updated: Jul 9, 2022
summary: "kubernetes yaml format summary"
sidebar: mydoc_sidebar
permalink: kubernetes_yaml.html
folder: Container
---

# Kubernetes YAML
======

## Example
```yaml
apiVersion:
kind:
metadata:

spec:
```

## `apiVersion` / `kind`

`apiVersion` is `string`
`kind` is `string`

| kind | apiVersion |
| :------ | :------ |
| POD | v1 |
| Service | v1 |
| ReplicaSet | apps/v1 |
| Deployment | apps/v1 |

## `metadata`

`metadata` is `dict`, only `name` and `labels` are acceptable in this sector

```yaml
metadata:
    name: myapp-pod
    lables:
        app: myapp
        type: front-end
```

`name` is `string`
`labels` is `dict` of `key` / `value` pairs

## `spec`
`spec` is `dict` and refers to `specification`, which will be different based on different objects to be created

### pods
```yaml
spec:
    containers:
    - name: nginx-container
      image: nginx
```
`containers` is a `list` or `array`

### replicaset / deployment
```yaml
spec:
    template:
        metadata:
        spec:
    selector:
    replica:
```

### service
#### NodePort
```yaml
spec:
    type: NodePort
    ports:
    - targetPort:
      port:
      nodePort:
    selector:
```
`targetPort` is port of a running application inside container. If omitted, it will be same as `port`
`port` is from view of `service` itself, which is a mandatory. 
`nodePort` is port mapping on node, valid range is 30000 ~ 32767. If omitted, it will be a random free port with valid range.
`selector` will be same as what has been configured in `labels` section of specific pods. It will link `service` with `pods`

#### ClusterIP
```yaml
spec:
    type: ClusterIP
    ports:
    - targetPort:
      port:
    selector:
```

#### LoadBalancer
```yaml
spec:
    type: LoadBalancer
    ports:
    - targetPort:
      port:
      nodePort:
    selector:
```
It will be only working on supported cloud environment. Otherwise, it will be working same as `NodePort`.

{% include links.html %}

