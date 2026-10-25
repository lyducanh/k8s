# Kubernetes StatefulSet Guide

- https://viblo.asia/p/k8s-basic-kubernetes-statefulset-r1QLxPe2LAw
- https://oneuptime.com/blog/post/2026-01-25-configure-statefulsets-stateful-applications/view

---

## 1. StatefulSet là gì?

**StatefulSet** là workload controller trong Kubernetes dùng để quản lý các ứng dụng **có trạng thái (stateful applications)** như database (MySQL, PostgreSQL, MongoDB), message queue (Kafka, RabbitMQ, ZooKeeper), hoặc các hệ thống phân tán yêu cầu:
- Tên Pod và định danh mạng cố định, duy nhất.
- Ổ đĩa lưu trữ (Persistent Volume) gắn liền với từng Pod cụ thể.
- Khởi tạo và tắt Pod theo thứ tự tuần tự nghiêm ngặt.

### So sánh Deployment và StatefulSet:

| Đặc điểm | Deployment | StatefulSet |
| :--- | :--- | :--- |
| **Loại ứng dụng** | Stateless (Web API, frontend, worker) | Stateful (Database, Redis Cluster, Kafka) |
| **Định danh Pod** | Ngẫu nhiên (vd: `nginx-6799fc88d8-abcde`) | Cố định theo số thứ tự (vd: `web-0`, `web-1`) |
| **Thứ tự Deploy/Delete** | Đồng thời / Bất kỳ | Tuần tự (`0` -> `1` -> `2`, tắt thì ngược lại) |
| **Lưu trữ (Storage)** | Dùng chung PVC hoặc không lưu trữ | Mỗi Pod có PVC riêng biệt qua `volumeClaimTemplates` |
| **Network Service** | Thường dùng ClusterIP / NodePort thông thường | Bắt buộc dùng **Headless Service** (`clusterIP: None`) |

---

## 2. Các thành phần cốt lõi của StatefulSet

### 1. Headless Service (`clusterIP: None`)
- Không cấp một IP ảo đại diện duy nhất (ClusterIP).
- Tạo bản ghi DNS trực tiếp cho từng Pod theo định dạng:
  ```
  <pod-name>.<service-name>.<namespace>.svc.cluster.local
  ```
  Ví dụ: `web-0.nginx-service.default.svc.cluster.local`. Nhờ đó các Pod có thể tìm thấy nhau trực tiếp (rất quan trọng cho mô hình Master-Replica / Cluster).

### 2. `volumeClaimTemplates`
- Tự động sinh ra một PVC riêng cho mỗi Pod theo quy tắc đặt tên:
  ```
  <volume-claim-name>-<statefulset-name>-<ordinal-index>
  ```
  Ví dụ: `web-data-web-0`, `web-data-web-1`.
- Khi Pod `web-0` bị xóa và tạo lại trên một Node khác, nó vẫn sẽ mount lại chính xác `web-data-web-0`.
- Khi Scale down, Kubernetes **không tự động xóa PVC**, giúp bảo vệ dữ liệu an toàn.

---

## 3. Kiến trúc ví dụ (`simple-statefulset.yaml`)

```
+-----------------------------------------------------------+
|              Headless Service: nginx-service              |
|                    (clusterIP: None)                      |
+-----------------------------------------------------------+
               /                             \
     DNS: web-0.nginx-service        DNS: web-1.nginx-service
             /                                 \
            v                                   v
+-----------------------+           +-----------------------+
|      Pod: web-0       |           |      Pod: web-1       |
|  (Container: nginx)   |           |  (Container: nginx)   |
+-----------------------+           +-----------------------+
            |                                   |
            v                                   v
+-----------------------+           +-----------------------+
|  PVC: web-data-web-0  |           |  PVC: web-data-web-1  |
|  (Mount: /.../html)   |           |  (Mount: /.../html)   |
+-----------------------+           +-----------------------+
```

---

## 4. Thực hành (Hands-on)

File manifest: [simple-statefulset.yaml](./simple-statefulset.yaml)

### Bước 1: Triển khai Headless Service & StatefulSet
```bash
kubectl apply -f "/home/ducanh/Downloads/k8s_h/12.StatefulSet/simple-statefulset.yaml"
```

### Bước 2: Quan sát quá trình khởi tạo tuần tự
Quan sát Pod được tạo theo thứ tự (`web-0` xong và Ready mới tạo tiếp `web-1`):
```bash
kubectl get statefulset web
kubectl get pods -l app=nginx-stateful -w
```

### Bước 3: Kiểm tra Persistent Volume Claim (PVC) được tạo tự động
```bash
kubectl get pvc -l app=nginx-stateful
```
Bạn sẽ thấy 2 PVC độc lập được sinh ra:
- `web-data-web-0` (gắn với `web-0`)
- `web-data-web-1` (gắn với `web-1`)

### Bước 4: Kiểm tra Network Identity qua Headless Service
Truy cập thử web server của từng Pod qua địa chỉ DNS hoặc curl trực tiếp:
```bash
# Kiểm tra nội dung của web-0
kubectl exec web-0 -- cat /usr/share/nginx/html/index.html

# Kiểm tra nội dung của web-1
kubectl exec web-1 -- cat /usr/share/nginx/html/index.html

# Test DNS phân giải giữa các Pod qua Headless Service
kubectl exec web-0 -- nslookup nginx-service
```

### Bước 5: Kiểm tra tính bền vững của dữ liệu khi Pod bị recreate
Ghi thêm một file dữ liệu vào `web-0`:
```bash
kubectl exec web-0 -- sh -c 'echo "Data created on $(date)" > /usr/share/nginx/html/myfile.txt'
kubectl exec web-0 -- cat /usr/share/nginx/html/myfile.txt
```

Xóa Pod `web-0`:
```bash
kubectl delete pod web-0
```

Quan sát Pod `web-0` được StatefulSet tự động dựng lại với cùng tên `web-0`:
```bash
kubectl get pod web-0
```

Kiểm tra lại dữ liệu trên `web-0` mới tạo:
```bash
kubectl exec web-0 -- cat /usr/share/nginx/html/myfile.txt
```
*Kết quả:* Dữ liệu `myfile.txt` vẫn còn nguyên vẹn vì StatefulSet gắn lại đúng volume `web-data-web-0` cho `web-0`.

### Bước 6: Thử nghiệm Scale Up / Scale Down
Tăng số lượng replica lên 3:
```bash
kubectl scale statefulset web --replicas=3
kubectl get pods -l app=nginx-stateful
```
*(Pod `web-2` và PVC `web-data-web-2` sẽ được tạo tiếp tục).*

Giảm số lượng replica về lại 2:
```bash
kubectl scale statefulset web --replicas=2
kubectl get pods -l app=nginx-stateful
```
*(Pod `web-2` bị xóa trước theo thứ tự ngược lại, nhưng PVC `web-data-web-2` vẫn được giữ nguyên an toàn).*

---

## 5. Dọn dẹp tài nguyên (Clean up)

```bash
# Xóa StatefulSet và Service
kubectl delete -f "/home/ducanh/Downloads/k8s_h/12.StatefulSet/simple-statefulset.yaml"

# Xóa các PVC đã cấp phát (StatefulSet cố tình không tự xóa PVC)
kubectl delete pvc web-data-web-0 web-data-web-1
# Hoặc nếu đã scale lên 3:
# kubectl delete pvc web-data-web-2
```
