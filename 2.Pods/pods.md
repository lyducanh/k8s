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
5. The scheduler deploys the Pod to a healthy node with enough available resources (Try case no have hardware resource node ) https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/ `if non of workers node available, then pod not scheduled`. ***Try this case on Demo***
6. The local kubelet monitors i

## The anatomy of a Pod

- A Pod is running a container, is that container running inside container  -> so yes it isolated enviroment that mean each pod have their own:
- `net namespace`: IP address, port range, routing table…
- `pid namespace`: isolated process tree
- `mnt namespace`: filesystems and volumes…
- `UTS namespace`: Hostname
- `IPC namespace`: Unix domain sockets and shared memory 


- ![alt text](/images/network_pod.png)
- assumed pods running on worker node with 10.0.10.1/24

- ![alt text](/images/subnet_worker.png)

- https://kubernetes.io/docs/concepts/cluster-administration/networking/

## Pod networking deep dive 
- https://sookocheff.com/post/kubernetes/understanding-kubernetes-networking-model/ (fucking good) 

- ***CONTINUE DEMO***


## Pod scaling 
- add / remove more pods, horizontal scaling


## Handson POD

- https://viblo.asia/p/kubernetes-series-bai-2-kubernetes-pod-thanh-phan-de-chay-container-YWOZr3QElQ0


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
![](/images/Pods/1.png)

### 3. List all pods across ALL namespaces
Sometimes k3s system pods (like the network plugin or DNS) run in a different namespace (like `kube-system`). This command shows everything running in the whole cluster.
```bash
kubectl get pods -A
```
![](/images/Pods/2.png)


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
   ```bash
   kubectl get pods
   ```

3. **Find out why it wasn't scheduled:**
   To prove to your audience that it's due to hardware limits, use the describe command. Look at the very bottom under the `Events:` section.
   ```bash
   kubectl describe pod impossible-pod
   ```
   *You will see a message like:*
   `Warning  FailedScheduling  ...  0/X nodes are available: X Insufficient cpu, X Insufficient memory.`

This perfectly proves the concept that if a node does not have enough resources to satisfy the pod's requests, the kube-scheduler will refuse to schedule it!

### 7. Updating or Recreating a Pod
When you are working directly with standalone Pods, updating them can be tricky because most fields in a Pod are immutable once it is created.

**Recreate the Pod (The most reliable way)**
Because most configuration fields in a Pod cannot be modified after it's running, you usually have to delete the pod and recreate it.
```bash
# 1. Edit your YAML file (e.g., single-nginx.yaml)
# 2. Delete the existing pod
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
5. The scheduler deploys the Pod to a healthy node with enough available resources (Try case no have hardware resource node ) https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/ `if non of workers node available, then pod not scheduled`. ***Try this case on Demo***
6. The local kubelet monitors i

## The anatomy of a Pod

- A Pod is running a container, is that container running inside container  -> so yes it isolated enviroment that mean each pod have their own:
- `net namespace`: IP address, port range, routing table…
- `pid namespace`: isolated process tree
- `mnt namespace`: filesystems and volumes…
- `UTS namespace`: Hostname
- `IPC namespace`: Unix domain sockets and shared memory 


- ![alt text](/images/network_pod.png)
- assumed pods running on worker node with 10.0.10.1/24

- ![alt text](/images/subnet_worker.png)

- https://kubernetes.io/docs/concepts/cluster-administration/networking/

## Pod networking deep dive 
- https://sookocheff.com/post/kubernetes/understanding-kubernetes-networking-model/ (fucking good) 

- ***CONTINUE DEMO***


## Pod scaling 
- add / remove more pods, horizontal scaling


## Handson POD

- https://viblo.asia/p/kubernetes-series-bai-2-kubernetes-pod-thanh-phan-de-chay-container-YWOZr3QElQ0



```bash
export KUBECONFIG="/home/ducanh/Downloads/k8s/1.Introduction and setup/k3s/kubeconfig"
```


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
![](/images/Pods/1.png)

### 3. List all pods across ALL namespaces
Sometimes k3s system pods (like the network plugin or DNS) run in a different namespace (like `kube-system`). This command shows everything running in the whole cluster.
```bash
kubectl get pods -A
```
![](/images/Pods/2.png)


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
   ```bash
   kubectl get pods
   ```

3. **Find out why it wasn't scheduled:**
   To prove to your audience that it's due to hardware limits, use the describe command. Look at the very bottom under the `Events:` section.
   ```bash
   kubectl describe pod impossible-pod
   ```
   *You will see a message like:*
   `Warning  FailedScheduling  ...  0/X nodes are available: X Insufficient cpu, X Insufficient memory.`

This perfectly proves the concept that if a node does not have enough resources to satisfy the pod's requests, the kube-scheduler will refuse to schedule it!

### 7. Updating or Recreating a Pod
When you are working directly with standalone Pods, updating them can be tricky because most fields in a Pod are immutable once it is created.

**Recreate the Pod (The most reliable way)**
Because most configuration fields in a Pod cannot be modified after it's running, you usually have to delete the pod and recreate it.
```bash
# 1. Edit your YAML file (e.g., single-nginx.yaml)
# 2. Delete the existing pod
kubectl delete pod single-nginx

# 3. Apply the updated file to create it fresh
kubectl apply -f "/home/ducanh/Downloads/k8s/2.Pods/single-nginx.yaml"
```

**Shortcut for recreate:**
You can combine deletion and recreation into one forceful command:
```bash
kubectl replace --force -f "/home/ducanh/Downloads/k8s/2.Pods/single-nginx.yaml"
```

### 8. Testing Pod Networking (Same vs Different Nodes)

1. **Create the test Pods**
   ```bash
   kubectl apply -f "/home/ducanh/Downloads/k8s/2.Pods/network-test-pods.yaml"
   ```

2. **Get their IP addresses and verify their Nodes**
   Wait a few seconds for them to be running, then check their assigned internal IPs and nodes:
   ```bash
   kubectl get pods -o wide
   ```
   *Note down the IP address of `pod-on-worker-1b` and `pod-on-worker-2`.*

3. **Test Networking (Same Worker Node)**
   Let's enter the first pod (`1a`) and ping the second pod (`1b`), which is sitting right next to it on the exact same worker node.
   ```bash
   # Replace <IP_OF_1B> with the actual IP address you noted down
   kubectl exec -it pod-on-worker-1a -- ping -c 3 <IP_OF_1B>
   ```
   *Behind the scenes:* The traffic leaves `pod-1a`'s virtual network interface, goes to the virtual bridge on `k3s-worker-1`, and is immediately routed directly to `pod-1b`'s interface.

4. **Test Networking (Different Worker Nodes)**
   Now, stay inside `pod-1a` (on worker 1) and ping `pod-on-worker-2` (on worker 2).
   ```bash
   # Replace <IP_OF_2> with the actual IP address you noted down
   kubectl exec -it pod-on-worker-1a -- ping -c 3 <IP_OF_2>
   ```
   *Behind the scenes:* The traffic leaves `pod-1a`, goes to the bridge on `worker-1`, realizes the IP belongs to a different node, gets encapsulated (usually by Flannel/k3s networking), travels over your Vagrant 192.168.56.x private network to `worker-2`, gets un-encapsulated, and is routed to `pod-on-worker-2`.

Both pings will be successful, proving that Kubernetes provides a flat networking model where every pod can communicate with every other pod, regardless of which physical/virtual node they are scheduled on!

### 9. Why are pods running on the master node?

Yes, in your current setup, the master node can run pods, and this is completely normal for K3s.

**1. K3s Default Behavior (No Taints)**
In a standard, heavy Kubernetes distribution (like those deployed via `kubeadm` or used in enterprise environments), master nodes are given a special property called a Taint (specifically `node-role.kubernetes.io/master:NoSchedule` or `control-plane:NoSchedule`). This acts like a force field that repels regular user pods, ensuring the master node only spends its CPU and memory managing the cluster.

K3s, however, is designed to be lightweight and optimized for small environments or edge computing. To maximize your hardware resources, K3s does not taint the master nodes by default. It treats the master nodes exactly like worker nodes when it comes to scheduling workloads. Therefore, the kube-scheduler might place your `single-nginx` pod there if it has free resources.

**2. Can you stop this?**
Yes! If you want your cluster to behave like a standard production Kubernetes environment where masters only handle management tasks, you can manually apply a taint to your master nodes:

```bash
# This prevents new pods from scheduling on the master, 
# unless the pod specifically "tolerates" the taint.
kubectl taint nodes k3s-master-1 node-role.kubernetes.io/master=true:NoSchedule
kubectl taint nodes k3s-master-2 node-role.kubernetes.io/master=true:NoSchedule
kubectl taint nodes k3s-master-3 node-role.kubernetes.io/master=true:NoSchedule
```

Once you do that, the scheduler will strictly push all your regular application pods (like nginx) onto your `k3s-worker` nodes!


## Pod networking 

- container in pod is same network space, self resolve 
- pod - pod inter-node, pod -> ns (eth) -> root ns/vm/node(veth) -> bridge use ARP protocol layer 2, layer 3 (ipv4 to mac address physical)

### 10. How CNI Works (Pod-to-Pod Between Nodes)

-  ### 1. Host-Level Inspection (Standard Linux Commands)

  If you SSH into a Kubernetes node, you can use standard Linux networking tools to see the overlay interfaces (like VXLAN or IPIP tunnels).

  • View Network Interfaces:
  Look for interfaces created by your CNI (e.g., flannel.1 for Flannel VXLAN, vxlan.calico for Calico, or tunl0 for IP-in-IP).
    `ip link show`
  To see specific details about a VXLAN interface (like the VNI - VXLAN Network Identifier):
    `ip -d link show flannel.1`

  • View Routing Tables:
  You can see how the host routes traffic destined for pod IP ranges to the overlay interface.
    `ip route`
  (You should see routes pointing traffic for other nodes' pod CIDRs to the tunnel interface).
  • View VXLAN Forwarding Database (FDB):
  If using VXLAN, the FDB tells the node the physical IP address (VTEP) associated with a specific overlay MAC address.
    `bridge fdb show dev flannel.1`

![](/images/Pods/4.png)

![](/images/Pods/5.png)


![](/images/Pods/3.png)


## Pod vs Service

  ### Step 1: Deploy and Gather IPs

  Run this from your master node (or wherever kubectl is configured):
    kubectl apply -f 5.Services/service-demo.yaml
  Wait a moment for the pods to run, then get the IPs of both the Service and the Pods:

    # Get the Service Virtual IP (ClusterIP)
    kubectl get svc demo-service
    
    # Get the actual IPs of the 3 backend Pods
    kubectl get pods -l app=demo-app -o wide
  Take note of the Service IP (e.g., 10.43.x.x) and the Pod IPs (e.g., 10.42.x.x).
  ### Step 2: See the Magic on the Node (kube-proxy)
  A Kubernetes Service IP is a Virtual IP. It doesn't actually exist on any physical network interface. Instead, a component called kube-proxy runs on every node and
  creates Linux `iptables` (or IPVS) rules to intercept traffic meant for the Service IP and forward it to the Pods.

  SSH into any node in your cluster (master or worker) and search the node's iptables for your Service's Virtual IP:

    # Replace <SERVICE-IP> with the IP you got from Step 1
    sudo iptables-save | grep <SERVICE-IP>