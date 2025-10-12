# Deploy

## Prerequisites
- Container registry (e.g., GHCR)
- Kubernetes cluster with access to Postgres and Keycloak

## Build & Push Image
- CI already publishes to GHCR on push to main.
- Or locally:
```bash
docker build -t ghcr.io/OWNER/REPO:main .
docker push ghcr.io/OWNER/REPO:main
```

## Kubernetes
- Create DB secret:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: be-db
type: Opaque
stringData:
  user: personal
  password: personal
```
- Apply manifests:
```bash
kubectl apply -f k8s/
```

## Config
- Env vars (see `.env.example`): DB URLs, CORS, JWT issuer.
- Expose via Ingress or LoadBalancer as needed.
