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