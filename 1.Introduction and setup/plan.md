# Automated High Availability (HA) K3s Cluster Setup Plan

This plan outlines the steps to automatically provision and configure a Highly Available K3s cluster using VirtualBox, Vagrant, and Ansible, consisting of 3 master nodes and 3 worker nodes.

## 1. Prerequisites
*   **VirtualBox:** Installed on the host machine to serve as the hypervisor.
*   **Vagrant:** Installed on the host machine for VM provisioning.
*   **Ansible:** Installed on the host machine (or a dedicated control node) for configuration management.
*   **Resources:** Sufficient host resources (RAM/CPU) to run 7 VMs simultaneously.

## 2. Infrastructure Provisioning (Vagrant)
1.  **Create a `Vagrantfile`:** Define the 7 virtual machines:
    *   1 Load Balancer Node (e.g., `k3s-lb`). Recommend 1 CPU / 1GB RAM.
    *   3 Master Nodes (e.g., `k3s-master-1`, `k3s-master-2`, `k3s-master-3`). Recommend 2 CPU / 2GB RAM each.
    *   3 Worker Nodes (e.g., `k3s-worker-1`, `k3s-worker-2`, `k3s-worker-3`). Recommend 1 CPU / 1GB RAM each.
2.  **Networking:** Configure a private network (host-only adapter) so the VMs have static IPs and can communicate with each other.
3.  **Provision:** Run `vagrant up` to download the base box (e.g., Ubuntu) and start the 7 VMs.

## 3. Configuration Management (Ansible)
1.  **Inventory Setup:** Create an Ansible `inventory` file defining the groups `[loadbalancer]`, `[masters]`, and `[workers]` with their respective Vagrant IP addresses.
2.  **Develop Ansible Playbooks:**
    *   **Load Balancer Setup:** Install and configure Nginx on the `k3s-lb` node to load balance traffic on port 6443 across the 3 master nodes.
    *   **Common Tasks (All Nodes):** Update packages, disable swap (recommended for Kubernetes), and install required dependencies.
    *   **Initialize First Master (HA):** Install the K3s server on `master-1` with the `--cluster-init` flag and configure `--tls-san` with the Load Balancer IP. Retrieve and save the node token.
    *   **Join Remaining Masters:** Install the K3s server on `master-2` and `master-3`, joining the cluster using the token.
    *   **Join Workers:** Install the K3s agent on all worker nodes, pointing them to the **Load Balancer's IP address** as the API server endpoint (using the token to join).
3.  **Execution:** Run the playbook to configure the entire cluster:
    ```bash
    ansible-playbook -i inventory site.yml
    ```

## 4. Verification and Access
1.  **Kubeconfig:** Use Ansible to fetch the `/etc/rancher/k3s/k3s.yaml` file from `master-1` to the host machine.
2.  **Update Endpoint:** Modify the fetched `kubeconfig` to point to the **Load Balancer IP address** instead of `127.0.0.1`.
3.  **Test:** Use `kubectl` on the host machine to verify the cluster:
    ```bash
    kubectl get nodes
    ```
    You should see 6 nodes in the `Ready` state.



## Setup

```
 To run the setup:

  1. Navigate to the folder and provision the VMs:
    cd "/home/ducanh/Downloads/k8s/1.Introduction and setup"
    vagrant up
    
  2. Once the VMs are running, apply the Ansible playbook:
    cd ansible
    ansible-playbook -i inventory site.yml
    
  3. Test your cluster access using the fetched kubeconfig:
    export KUBECONFIG=../kubeconfig
    kubectl get nodes
    
```
