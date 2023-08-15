# httpd-with-access-logs
Docker image with access logging enabled can be pulled from `docker.io/ayushgarglinux/httpd-access-logs`. The `Dockerfile` and `httpd.conf` files are also present in the repository for reference.

# Deploying the `httpd-with-access-logs` pod in the `OpenShift 4` Cluster.

## Create a new project.
```
$ oc new-project httpd-access-log
```

## Add default service account to `anyuid` SCC.
```
$ oc adm policy add-scc-to-user anyuid -z default
```

## Deploy the application with docker image.
```
$ oc new-app docker.io/ayushgarglinux/httpd-access-logs

$ oc get pod
NAME                                 READY   STATUS    RESTARTS   AGE
httpd-access-logs-5874d9f44d-mgqk5   1/1     Running   0          19s

$ oc get svc
NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
httpd-access-logs   ClusterIP   172.30.216.80   <none>        80/TCP    36s
```

## Expose the `svc` to create a route.
```
$ oc expose svc httpd-access-logs
route.route.openshift.io/httpd-access-logs exposed

$ oc get route
NAME                HOST/PORT                                                                PATH   SERVICES            PORT     TERMINATION   WILDCARD
httpd-access-logs   httpd-access-logs-httpd-access-log.apps.ayush.example.com          httpd-access-logs   80-tcp                 None
```

## Enable `PROXY` protocol at ingress `LoadBalancer` and `ingresscontroller` level.
```
$ oc edit ingresscontroller/default -n openshift-ingress-operator
...
spec:
  endpointPublishingStrategy:
    hostNetwork:
      protocol: PROXY
    type: HostNetwork
```

## Following links can be referred to for `PROXY` protocol details.
- https://docs.openshift.com/container-platform/4.13/networking/ingress-operator.html#nw-ingress-controller-configuration-proxy-protocol_configuring-ingress
- https://access.redhat.com/solutions/6337981

## Access the route with the curl command.
```
$ curl -v http://httpd-access-logs-httpd-access-log.apps.ayush.example.com
* About to connect() to httpd-access-logs-httpd-access-log.apps.ayush.example.com port 80 (#0)
*   Trying 10.74.208.75...
* Connected to httpd-access-logs-httpd-access-log.apps.ayush.example.com (10.74.208.75) port 80 (#0)
> GET / HTTP/1.1
> User-Agent: curl/7.29.0
> Host: httpd-access-logs-httpd-access-log.apps.ayush.example.com
> Accept: */*
> 
< HTTP/1.1 403 Forbidden
< date: Tue, 15 Aug 2023 14:28:02 GMT
< server: Apache/2.4.6 (CentOS)
< last-modified: Thu, 16 Oct 2014 13:20:58 GMT
< etag: "1321-5058a1e728280"
< accept-ranges: bytes
< content-length: 4897
< content-type: text/html; charset=UTF-8
< set-cookie: 17648a477dcb33be849edea4098e62e7=a7ee3823fdc89a294bd9369157ffd8bc; path=/; HttpOnly
< 
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"><html><head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
		<title>Apache HTTP Server Test Page powered by CentOS</title>
```

## Check access logs inside the pod for the client IP address.
```
$ oc exec httpd-access-logs-5874d9f44d-mgqk5 -- cat /var/log/httpd/access_log
10.74.208.75 - - [15/Aug/2023:14:28:02 +0000] "GET / HTTP/1.1" 403 4897 "-" "curl/7.29.0"
```
