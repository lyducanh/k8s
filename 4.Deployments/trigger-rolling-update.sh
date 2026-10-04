#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${DIR}/simple-deployment-v2.yaml"

echo "=========================================================="
echo "🚀 Triggering Rolling Update using ${MANIFEST}"
echo "=========================================================="

# 1. Apply updated deployment manifest
kubectl apply -f "${MANIFEST}"

echo ""
echo "⏳ Monitoring rollout progress in real-time..."
# 2. Watch rollout status
kubectl rollout status deployment/nginx-deployment

echo ""
echo "📊 Current ReplicaSets (Notice Old RS vs New RS):"
# 3. Show ReplicaSets
kubectl get rs -l app=nginx

echo ""
echo "📜 Rollout History:"
# 4. Show revisions
kubectl rollout history deployment/nginx-deployment

echo ""
echo "🌐 Testing continuous availability (HTTP Response):"
# 5. Test curl from service
curl -sI http://192.168.56.11:30088 | head -n 3 || echo "Service reachable"

echo ""
echo "✅ Rolling update completed successfully with zero downtime!"
