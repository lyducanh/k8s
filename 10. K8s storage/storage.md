# Kubernetes Storage Guide

## 1. Why do we need Persistent Storage?
- Mặc định, Pod và Container trong Kubernetes là **Ephemeral (tạm thời / không lưu trạng thái)**.
- Khi một container crash hoặc một Pod bị xóa/recreate, toàn bộ dữ liệu ghi trong container sẽ **bị xóa sạch**.
- **Kubernetes Persistent Storage** giải quyết bài toán này bằng cách tách rời vòng đời của dữ liệu khỏi vòng đời của Pod.

---

## 2. Core Concepts (Storage Architecture)

```
+-------------------------------------------------------------+
|                     StorageClass (SC)                       |
|   (Dynamic Provisioner: local-path, aws-ebs, nfs,...)       |
+-------------------------------------------------------------+
                              |
                     Auto-provisions (Dynamic)
                              v
+-----------------------------+      Bound to      +-----------------------------+
|    PersistentVolume (PV)    |<==================>| PersistentVolumeClaim (PVC) |
|  (Actual storage resource)  |                    |  (Developer storage request)|
+-----------------------------+                    +-----------------------------+
                                                                  ^
                                                                  | Mounted into
                                                   +-----------------------------+
                                                   |         Pod / Container     |
                                                   | (Mount path: /data, /html)  |
                                                   +-----------------------------+
```

### Storage Components:
1. **PersistentVolumeClaim (PVC)**:
   - Là "phiếu yêu cầu" lưu trữ do developer hoặc app tạo ra (ví dụ: cần 1Gi, quyền ReadWriteOnce).
2. **PersistentVolume (PV)**:
   - Là "ổ đĩa thực tế" trong cluster. Có thể tạo thủ công (Static) hoặc tự động tạo bởi StorageClass (Dynamic).
3. **StorageClass (SC)**:
   - Là plugin tự động cấp phát PV theo yêu cầu của PVC. Trong cụm K3s của bạn, provisioner mặc định là **`local-path`**.
4. **Volume Mount**:
   - Khai báo gắn kết PVC vào một đường dẫn thư mục cụ thể bên trong container (ví dụ: `/usr/share/nginx/html`).

---

## 3. Access Modes & Volume Binding

### Access Modes:
- **`ReadWriteOnce (RWO)`**: Được mount read/write bởi **1 node duy nhất** tại một thời điểm (chuẩn của ổ đĩa cục bộ / block storage).
- **`ReadOnlyMany (ROX)`**: Được mount read-only bởi nhiều node cùng lúc.
- **`ReadWriteMany (RWX)`**: Được mount read/write bởi nhiều node đồng thời (dành cho NFS, GlusterFS, CephFS, AWS EFS).

### Volume Binding Mode (`WaitForFirstConsumer`):
- StorageClass `local-path` sử dụng chế độ `WaitForFirstConsumer`.
- Khi bạn tạo PVC, trạng thái sẽ là `Pending` cho đến khi có Pod đầu tiên yêu cầu mount PVC đó. Kubernetes sẽ chờ để biết Pod được schedule lên node nào, rồi mới tạo PV trên chính node đó.

---

## 4. Hands-on: Simple Storage Demo

### Bước 1: Tạo PersistentVolumeClaim (PVC)
Tạo yêu cầu cấp phát `1Gi` dung lượng lưu trữ:
```bash
kubectl apply -f "/home/ducanh/Downloads/k8s_h/10. K8s storage/pvc.yaml"
```
Kiểm tra trạng thái (lúc này sẽ ở trạng thái `Pending` do cơ chế `WaitForFirstConsumer`):
```bash
kubectl get pvc simple-pvc
```

### Bước 2: Tạo Pod gắn kèm Volume từ PVC
```bash
kubectl apply -f "/home/ducanh/Downloads/k8s_h/10. K8s storage/storage-pod.yaml"
```
Kiểm tra lại PVC và PV (bây giờ đã chuyển sang `Bound`):
```bash
kubectl get pvc simple-pvc
kubectl get pv
kubectl get pod storage-demo-pod
```

### Bước 3: Ghi dữ liệu kiểm chứng vào Volume bên trong Pod
Ghi một file `index.html` vào thư mục mount `/usr/share/nginx/html`:
```bash
kubectl exec storage-demo-pod -- sh -c 'echo "<h1>Hello from Kubernetes Persistent Storage!</h1>" > /usr/share/nginx/html/index.html'

# Đọc lại nội dung kiểm tra:
kubectl exec storage-demo-pod -- cat /usr/share/nginx/html/index.html
```

### Bước 4: Kiểm tra tính bền vững (Data Persistence)
Xóa hoàn toàn Pod hiện tại:
```bash
kubectl delete pod storage-demo-pod
```
Tạo lại một Pod hoàn toàn mới cùng mount vào PVC đó:
```bash
kubectl apply -f "/home/ducanh/Downloads/k8s_h/10. K8s storage/storage-pod.yaml"
```

### Bước 5: Xác nhận dữ liệu không bị mất
```bash
kubectl exec storage-demo-pod -- cat /usr/share/nginx/html/index.html
```
*Kết quả:* File `index.html` vẫn còn nguyên vẹn, chứng minh dữ liệu tồn tại độc lập với vòng đời của Pod!

---

## 5. Dọn dẹp tài nguyên
Khi hoàn thành thử nghiệm:
```bash
kubectl delete pod storage-demo-pod
kubectl delete pvc simple-pvc
```
