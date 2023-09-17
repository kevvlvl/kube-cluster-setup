# Deploy ArgoCD on Kubernetes

https://argo-cd.readthedocs.io/en/stable/getting_started/

## Steps

1. Connect to the control plane or worker node

2. Apply the ArgoCD CRDs

```shell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
..
customresourcedefinition.apiextensions.k8s.io/applications.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/applicationsets.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/appprojects.argoproj.io created
serviceaccount/argocd-application-controller created
serviceaccount/argocd-applicationset-controller created
serviceaccount/argocd-dex-server created
serviceaccount/argocd-notifications-controller created
serviceaccount/argocd-redis created
serviceaccount/argocd-repo-server created
serviceaccount/argocd-server created
role.rbac.authorization.k8s.io/argocd-application-controller created
role.rbac.authorization.k8s.io/argocd-applicationset-controller created
role.rbac.authorization.k8s.io/argocd-dex-server created
role.rbac.authorization.k8s.io/argocd-notifications-controller created
role.rbac.authorization.k8s.io/argocd-server created
clusterrole.rbac.authorization.k8s.io/argocd-application-controller created
clusterrole.rbac.authorization.k8s.io/argocd-server created
rolebinding.rbac.authorization.k8s.io/argocd-application-controller created
rolebinding.rbac.authorization.k8s.io/argocd-applicationset-controller created
rolebinding.rbac.authorization.k8s.io/argocd-dex-server created
rolebinding.rbac.authorization.k8s.io/argocd-notifications-controller created
rolebinding.rbac.authorization.k8s.io/argocd-server created
clusterrolebinding.rbac.authorization.k8s.io/argocd-application-controller created
clusterrolebinding.rbac.authorization.k8s.io/argocd-server created
configmap/argocd-cm created
configmap/argocd-cmd-params-cm created
configmap/argocd-gpg-keys-cm created
configmap/argocd-notifications-cm created
configmap/argocd-rbac-cm created
configmap/argocd-ssh-known-hosts-cm created
configmap/argocd-tls-certs-cm created
secret/argocd-notifications-secret created
secret/argocd-secret created
service/argocd-applicationset-controller created
service/argocd-dex-server created
service/argocd-metrics created
service/argocd-notifications-controller-metrics created
service/argocd-redis created
service/argocd-repo-server created
service/argocd-server created
service/argocd-server-metrics created
deployment.apps/argocd-applicationset-controller created
deployment.apps/argocd-dex-server created
deployment.apps/argocd-notifications-controller created
deployment.apps/argocd-redis created
deployment.apps/argocd-repo-server created
deployment.apps/argocd-server created
statefulset.apps/argocd-application-controller created
networkpolicy.networking.k8s.io/argocd-application-controller-network-policy created
networkpolicy.networking.k8s.io/argocd-applicationset-controller-network-policy created
networkpolicy.networking.k8s.io/argocd-dex-server-network-policy created
networkpolicy.networking.k8s.io/argocd-notifications-controller-network-policy created
networkpolicy.networking.k8s.io/argocd-redis-network-policy created
networkpolicy.networking.k8s.io/argocd-repo-server-network-policy created
networkpolicy.networking.k8s.io/argocd-server-network-policy created
```

3. Verify that everything deployed in the namespace `argocd` is healthy

```shell
NAME                                                    READY   STATUS    RESTARTS   AGE
pod/argocd-application-controller-0                     1/1     Running   0          93s
pod/argocd-applicationset-controller-568754c579-pmfw6   1/1     Running   0          93s
pod/argocd-dex-server-7658dcdf77-7jjsw                  1/1     Running   0          93s
pod/argocd-notifications-controller-5548b96954-vqvmr    1/1     Running   0          93s
pod/argocd-redis-6976fc7dfc-6dsgq                       1/1     Running   0          93s
pod/argocd-repo-server-7594f8849c-xcp9s                 1/1     Running   0          93s
pod/argocd-server-58cc545d87-m4pqz                      1/1     Running   0          93s

NAME                                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/argocd-applicationset-controller          ClusterIP   10.100.158.119   <none>        7000/TCP,8080/TCP            94s
service/argocd-dex-server                         ClusterIP   10.97.242.45     <none>        5556/TCP,5557/TCP,5558/TCP   94s
service/argocd-metrics                            ClusterIP   10.110.197.34    <none>        8082/TCP                     94s
service/argocd-notifications-controller-metrics   ClusterIP   10.107.138.216   <none>        9001/TCP                     94s
service/argocd-redis                              ClusterIP   10.99.180.31     <none>        6379/TCP                     94s
service/argocd-repo-server                        ClusterIP   10.110.26.189    <none>        8081/TCP,8084/TCP            94s
service/argocd-server                             ClusterIP   10.109.222.11    <none>        80/TCP,443/TCP               94s
service/argocd-server-metrics                     ClusterIP   10.101.10.67     <none>        8083/TCP                     94s

NAME                                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/argocd-applicationset-controller   1/1     1            1           94s
deployment.apps/argocd-dex-server                  1/1     1            1           94s
deployment.apps/argocd-notifications-controller    1/1     1            1           93s
deployment.apps/argocd-redis                       1/1     1            1           93s
deployment.apps/argocd-repo-server                 1/1     1            1           93s
deployment.apps/argocd-server                      1/1     1            1           93s

NAME                                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/argocd-applicationset-controller-568754c579   1         1         1       94s
replicaset.apps/argocd-dex-server-7658dcdf77                  1         1         1       93s
replicaset.apps/argocd-notifications-controller-5548b96954    1         1         1       93s
replicaset.apps/argocd-redis-6976fc7dfc                       1         1         1       93s
replicaset.apps/argocd-repo-server-7594f8849c                 1         1         1       93s
replicaset.apps/argocd-server-58cc545d87                      1         1         1       93s

NAME                                             READY   AGE
statefulset.apps/argocd-application-controller   1/1     93s
```

If need be, use the `--insecure` flag for every argocd cli operation. In reality, we want to configure certificates to ensure client trust but this is fine for a sandbox

4. Install the ArgoCD CLI

```shell
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

5. Update the admin password by updating the secret

replace PASSWORD_HERE with the desired password

```shell
kubectl -n argocd patch secret argocd-secret \
-p '{"stringData": {"admin.password": "'$(htpasswd -bnBC 10 "" PASSWORD_HERE | tr -d ':\n' | sed 's/$2y/$2a/')'", "admin.passwordMtime": "'$(date +%FT%T%Z)'"}}'
```

While connected on any node, now we can access argoCD UI by getting the service's ClusterIP:

```shell
k -n argocd get svc argocd-server
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
argocd-server   ClusterIP   10.109.222.11   <none>        80/TCP,443/TCP   15h
```

# Deploy Gitea on Kubernetes

1. Install Gitea (for a git source repository)

_Source_: https://gitea.com/gitea/helm-chart/

__Prerequisite__: Make sure helm cli is installed.

2. Use the following values for a single pod instance save as file `gitea-single-pod-values.yaml`

```yaml
redis-cluster:
  enabled: false
postgresql:
  enabled: false
postgresql-ha:
  enabled: false

persistence:
  enabled: false

gitea:
  config:
    database:
      DB_TYPE: sqlite3
    session:
      PROVIDER: memory
    cache:
      ADAPTER: memory
    queue:
      TYPE: level
  admin:
    username: "supertea"
    password: "gitea"
    email: "foo@bar.gitea"
```

```shell
helm repo add gitea-charts https://dl.gitea.com/charts/
helm repo update
helm install gitea gitea-charts/gitea -f gitea-single-pod-values.yaml
```

3. Then, we delete the gitea services and re-expose the deployment to have a ClusterIP. By default, gitea has a clusterip of type None

```shell
k get svc gitea-http -o yaml > gitea-http-svc.yaml
k delete svc gitea-http
k get svc gitea-ssh -o yaml > gitea-ssh-svc.yaml
k delete svc gitea-ssh
k expose deploy gitea -o yaml --dry-run=client > gitea-svc.yaml
# Edit the file gitea-svc.yaml and change the ssh port to 22 specifically.
k apply -f gitea-svc.yaml
$ k get svc
NAME    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
gitea   ClusterIP   10.98.139.192   <none>        2222/TCP,3000/TCP   6s
```

As you can see, you can now expose the service at that ClusterIP and port 3000

## Add ArgoCD local users (when not using SSO)

1: Modify config map argocd-cm:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  ...
  name: argocd-cm
  ...
data:
  accounts.bobsacamano: login # Add login capability to this new user
  admin.enabled: "false"      # Disable the local admin account
```

2. Set a password for this user as follows:

```shell
$ argocd account list
NAME         ENABLED  CAPABILITIES
admin        false    login
bobsacamano  true     login

$ argocd account get --account bobsacamano
Name:               bobsacamano
Enabled:            true
Capabilities:       login

Tokens:
NONE
$ argocd account update-password \
  --account bobsacamano \
  --current-password \
  --new-password login1234
```