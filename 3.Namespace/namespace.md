- namepsace is not for workload isolation is for quotas and limitation 
- Namespaces a good way of sharing a single cluster among different departments and environments. For example,
a single cluster might have the following Namespaces. (each enviroment haver their own pod, service, deployment type, resource limitation, quotas )
• Dev
• Test
• QA
- What they’re not good for, is isolating hostile workloads. -> create multiple cluster 
- https://viblo.asia/p/k8s-basic-kubernetes-namespaces-oK9VyKnXJQR


## Handson 

![hihi](/images/k8snamespace.png)
- books 