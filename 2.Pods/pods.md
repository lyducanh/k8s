# Pod theory

## Why Pods

- write app code -> build docker image -> wrap docker container in pod -> running on k8s 
- Why not running container on k8s 
  - pod support scheduling, resource sharing, augment
- pods in augment containers 
  - Labels and annotations (scheduling)
  - Restart policies
  - Probes (startup probes, readiness probes, liveness probes, and potentially more)
  - Affinity and anti-affinity rules (where pod runs - scheduling )
  - Termination control
  - Security policies
  - Resource requests and limits (scheduling)
- Containers are running on POD
  - Shared filesystem
  - Shared network stack (IP address and ports…)
  - Shared memory
  - Shared volumes



## Static Pods vs controllers

- Directly via a Pod manifest (static Pod)
  - kubelet process managed, if node fails, it transfer to another node that capable, still auto restart
- Indirectly via a controller 
  - control plane monitoring the state ->  self-healing,  
  scaling, or rolling updates (via deployment)

## Single and multi container Pods

- Single Nginx container  
- Nginx + log agent container (sidecard pattern) 
- ***CONTINUE DEMO***

## Deploying Pods

1. Define it in a YAML manifest file
2. Post the YAML to the API server
3. The API server authenticates and authorizes the request
4. The configuration (YAML) is validated
5. The scheduler deploys the Pod to a healthy node with enough available resources (Try case no have hardware resource node ) [https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) `if non of workers node available, then pod not scheduled`. ***Try this case on Demo***
6. The local kubelet monitors i

## The anatomy of a Pod

- A Pod is running a container, is that container running inside container  -> so yes it isolated enviroment that mean each pod have their own:
- `net namespace`: IP address, port range, routing table…
- `pid namespace`: isolated process tree
- `mnt namespace`: filesystems and volumes…
- `UTS namespace`: Hostname
- `IPC namespace`: Unix domain sockets and shared memory 
- alt text
- assumed pods running on worker node with 10.0.10.1/24
- alt text
- [https://kubernetes.io/docs/concepts/cluster-administration/networking/](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

## Pod networking deep dive

- [https://sookocheff.com/post/kubernetes/understanding-kubernetes-networking-model/](https://sookocheff.com/post/kubernetes/understanding-kubernetes-networking-model/) (fucking good) 
- ***CONTINUE DEMO***

## Pod scaling

- add / remove more pods, horizontal scaling

## Handson POD

- [https://viblo.asia/p/kubernetes-series-bai-2-kubernetes-pod-thanh-phan-de-chay-container-YWOZr3QElQ0](https://viblo.asia/p/kubernetes-series-bai-2-kubernetes-pod-thanh-phan-de-chay-container-YWOZr3QElQ0)

```bash
# Create the single Nginx pod
kubectl apply -f "/home/ducanh/Downloads/k8s/2.Pods/single-nginx.yaml"

# Create the Nginx + sidecar pod
kubectl apply -f "/home/ducanh/Downloads/k8s/2.Pods/sidecar-nginx.yaml"

# View the status of your pods
kubectl get pods
```



### 1. List all pods in the current namespace

This gives you a quick overview of the pods, their status (e.g., Running, Pending, CrashLoopBackOff), and how many containers inside them are ready.

```bash
kubectl get pods
```



### 2. See more details (including IP addresses and Node assignment)

Adding `-o wide` gives you extra columns, which is very useful for seeing exactly which worker node your pod was scheduled on.

```bash
kubectl get pods -o wide
```



### 3. List all pods across ALL namespaces

Sometimes k3s system pods (like the network plugin or DNS) run in a different namespace (like `kube-system`). This command shows everything running in the whole cluster.

```bash
kubectl get pods -A
```



### 4. Get detailed information about a specific pod

If a pod is failing or you want to see its configuration, events, and container statuses, use the `describe` command:

```bash
kubectl describe pod single-nginx
```



### 5. Check the logs of a pod

To see the standard output of the application running inside the container:

```bash
# For a single-container pod
kubectl logs single-nginx

# For a multi-container pod (like our sidecar example), you must specify the container name
kubectl logs sidecar-nginx -c nginx
kubectl logs sidecar-nginx -c content-generator
```



### 6. Demonstrating Hardware Resource Limits (Pending Pod)

1. **Apply the impossible pod:**
  ```bash
   kubectl apply -f "/home/ducanh/Downloads/k8s/2.Pods/pending-pod.yaml"
  ```
2. **Check the pod status:**
  You will notice the status stays as `Pending` indefinitely.
3. **Find out why it wasn't scheduled:**
  To prove to your audience that it's due to hardware limits, use the describe command. Look at the very bottom under the `Events:` section.
   *You will see a message like:*
   `Warning  FailedScheduling  ...  0/X nodes are available: X Insufficient cpu, X Insufficient memory.`

This perfectly proves the concept that if a node does not have enough resources to satisfy the pod's requests, the kube-scheduler will refuse to schedule it!

### 7. Updating or Recreating a Pod

When you are working directly with standalone Pods, updating them can be tricky because most fields in a Pod are immutable once it is created.

**Recreate the Pod (The most reliable way)**
Because most configuration fields in a Pod cannot be modified after it's running, you usually have to delete the pod and recreate it.

```bash

export KUBECONFIG="/home/ducanh/Downloads/k8s/1.Introduction and setup/k3s/kubeconfig"
```

# Create the single Nginx pod

kubectl apply -f "/home/ducanh/Downloads/k8s/2.Pods/single-nginx.yaml"

# Create the Nginx + sidecar pod

kubectl apply -f "/home/ducanh/Downloads/k8s/2.Pods/sidecar-nginx.yaml"

# View the status of your pods

kubectl get pods

```

### 1. List all pods in the current namespace
This gives you a quick overview of the pods, their status (e.g., Running, Pending, CrashLoopBackOff), and how many containers inside them are ready.
```bash
kubectl get pods
```

### 2. See more details (including IP addresses and Node assignment)

Adding `-o wide` gives you extra columns, which is very useful for seeing exactly which worker node your pod was scheduled on.

```bash
kubectl get pods -o wide
```

### 3. List all pods across ALL namespaces

Sometimes k3s system pods (like the network plugin or DNS) run in a different namespace (like `kube-system`). This command shows everything running in the whole cluster.

```bash
kubectl get pods -A
```

### 4. Get detailed information about a specific pod

If a pod is failing or you want to see its configuration, events, and container statuses, use the `describe` command:

```bash
kubectl describe pod single-nginx
```

### 6. Testing Pod Networking (Same vs Different Nodes)

