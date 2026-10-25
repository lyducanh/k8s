# Kubernetes Helm Chart Guide

- Official Documentation: https://helm.sh/docs/
- Artifact Hub (Chart Repository): https://artifacthub.io/

---

## 1. Helm là gì?

**Helm** là trình quản lý gói (Package Manager) chính thức cho Kubernetes (tương tự như `apt` trên Ubuntu, `npm` trên Node.js hay `pip` trên Python).

### Vấn đề khi chỉ dùng YAML thuần:
- Khi triển khai ứng dụng, bạn thường có nhiều file YAML (`deployment.yaml`, `service.yaml`, `configmap.yaml`, `ingress.yaml`...).
- Để deploy sang nhiều môi trường khác nhau (`dev`, `staging`, `prod`), bạn phải copy-paste hoặc duplicate các file YAML và sửa thủ công (hardcoded) từng thông số như image tag, replica, port, domain... Dễ sai sót và khó bảo trì.

### Helm giải quyết như thế nào?
- **Đóng gói (Packaging)**: Gom toàn bộ manifests của một ứng dụng thành một gói duy nhất gọi là **Helm Chart**.
- **Tham số hóa (Templating)**: Tách các giá trị cấu hình ra file `values.yaml`, sử dụng cú pháp template Go để sinh động các file manifest.
- **Quản lý phiên bản & Vòng đời (Release Management)**: Dễ dàng cài đặt (`install`), nâng cấp (`upgrade`), xem lịch sử (`history`) và hoàn tác (`rollback`) chỉ với một lệnh.

---

## 2. Các khái niệm cốt lõi (Core Concepts)

| Khái niệm | Ý nghĩa |
| :--- | :--- |
| **Chart** | Một gói chứa tất cả các tài nguyên và template cần thiết để chạy một ứng dụng trên K8s. |
| **Repository** | Nơi lưu trữ và chia sẻ các Helm Charts (ví dụ: Artifact Hub, Bitnami repo...). |
| **Release** | Một phiên bản (instance) cụ thể của Chart đang chạy trên cluster Kubernetes. Một Chart có thể được cài nhiều lần tạo thành nhiều Release khác nhau (vd: `my-app-dev`, `my-app-prod`). |
| **Values** | Dữ liệu cấu hình đưa vào chart để tùy biến template (định nghĩa trong `values.yaml` hoặc ghi đè qua `--set`, `-f custom-values.yaml`). |

---

## 3. Cấu trúc thư mục của một Helm Chart

Ví dụ thư mục mẫu [`my-app`](./my-app):

```
13.HelmChart/
├── helm.md                     # Tài liệu hướng dẫn
└── my-app/                     # Thư mục Helm Chart
    ├── Chart.yaml              # Metadata của Chart (tên, version, appVersion...)
    ├── values.yaml             # Giá trị cấu hình mặc định (variables)
    └── templates/              # Thư mục chứa các K8s manifest templates
        ├── _helpers.tpl        # Định nghĩa các template helper, label dùng chung
        ├── configmap.yaml      # Template ConfigMap
        ├── deployment.yaml     # Template Deployment
        ├── service.yaml        # Template Service
        └── NOTES.txt           # Hướng dẫn hiển thị cho user sau khi helm install thành công
```

---

## 4. Hướng dẫn thực hành (Hands-on)

Thư mục chart thực hành: [my-app](./my-app)

### Bước 1: Kiểm tra cú pháp (Lint) và Render thử (Template)
Trước khi cài vào cluster, luôn kiểm tra xem Chart có lỗi cú pháp hay không:

```bash
# Kiểm tra lỗi cấu trúc và cú pháp
helm lint /home/ducanh/Downloads/k8s_h/13.HelmChart/my-app

# Render các file manifest K8s ra màn hình (không cài vào cluster)
helm template my-release /home/ducanh/Downloads/k8s_h/13.HelmChart/my-app
```

---

### Bước 2: Cài đặt Chart vào Kubernetes Cluster (`helm install`)

```bash
# Cú pháp: helm install <RELEASE_NAME> <CHART_PATH>
helm install demo-app /home/ducanh/Downloads/k8s_h/13.HelmChart/my-app
```

Khi cài thành công, Helm sẽ in ra thông báo từ file `templates/NOTES.txt`.

---

### Bước 3: Kiểm tra Release và các tài nguyên đã tạo

```bash
# Xem danh sách các Helm release đang chạy
helm list

# Xem chi tiết các tài nguyên Pod, Service, ConfigMap do release tạo ra
kubectl get all,configmap -l app.kubernetes.io/instance=demo-app
```

Thử truy cập ứng dụng qua port-forward:
```bash
kubectl port-forward svc/demo-app-my-app 8080:80
# Mở terminal khác kiểm tra:
curl http://localhost:8080
```

---

### Bước 4: Nâng cấp cấu hình (`helm upgrade`)

Giả sử bạn muốn tăng số replica lên 4 và đổi thông điệp hiển thị mà **không cần sửa trực tiếp file YAML**:

```bash
# Nâng cấp bằng cờ --set ghi đè giá trị
helm upgrade demo-app /home/ducanh/Downloads/k8s_h/13.HelmChart/my-app \
  --set replicaCount=4 \
  --set message="Updated message from Helm Upgrade!"
```

Kiểm tra lại số lượng Pods:
```bash
kubectl get pods -l app.kubernetes.io/instance=demo-app
```

---

### Bước 5: Xem lịch sử và Hoàn tác (`helm rollback`)

Nếu bản nâng cấp gặp sự cố, bạn có thể quay lại phiên bản trước đó ngay lập tức:

```bash
# Xem lịch sử các revision của release
helm history demo-app

# Rollback về revision 1 (phiên bản ban đầu)
helm rollback demo-app 1

# Kiểm tra lại số lượng Pods (đã quay về 2 replica ban đầu)
kubectl get pods -l app.kubernetes.io/instance=demo-app
```

---

### Bước 6: Gỡ bỏ Release (`helm uninstall`)

Xóa toàn bộ ứng dụng và tất cả tài nguyên K8s liên quan do Helm quản lý:

```bash
helm uninstall demo-app
```

Kiểm tra lại để đảm bảo tài nguyên đã được xóa sạch:
```bash
kubectl get pods -l app.kubernetes.io/instance=demo-app
```

---

## 5. Bảng tổng hợp các lệnh Helm thông dụng (Cheat Sheet)

| Lệnh | Mô tả |
| :--- | :--- |
| `helm create <name>` | Tự động tạo một thư mục Helm Chart mẫu chuẩn |
| `helm lint <chart-path>` | Kiểm tra tính hợp lệ và cú pháp của Chart |
| `helm template <rel-name> <chart-path>` | Xem kết quả YAML sau khi điền values (không apply) |
| `helm install <rel-name> <chart-path>` | Cài đặt Chart vào cluster |
| `helm upgrade <rel-name> <chart-path>` | Nâng cấp release với cấu hình mới |
| `helm rollback <rel-name> <revision>` | Hoàn tác release về revision mong muốn |
| `helm list` (hoặc `helm ls`) | Danh sách các release đang có |
| `helm history <rel-name>` | Xem lịch sử các lần thay đổi của release |
| `helm get values <rel-name>` | Xem các giá trị values đã truyền vào release |
| `helm uninstall <rel-name>` | Gỡ bỏ release và xóa toàn bộ tài nguyên |
| `helm repo add <name> <url>` | Thêm kho chart bên ngoài (vd: Bitnami) |
| `helm repo update` | Cập nhật danh sách charts từ các repo đã thêm |
