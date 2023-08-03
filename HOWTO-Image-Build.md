# Building Images using Kaniko

To add image build capability alongside Kubernetes (because Kubernetes does not provide ability to build OCI images), we can use a tool such as [Kaniko](https://github.com/GoogleContainerTools/kaniko)

## What is Kaniko?

_From the above link's README.md_:

> kaniko is a tool to build container images from a Dockerfile, inside a container or Kubernetes cluster.
>
> kaniko doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in userspace. This enables building container images in environments that can't easily or securely run a Docker daemon, such as a standard Kubernetes cluster.

## Installing Kaniko

1. Connect/SSH into your k8s cluster
2. Create the namespace "kaniko"
3. Create the Kaniko secret used to connect to the container registry in the case of a private registry
```
k create secret docker-registry docker-registry-creds --docker-server=docker.io --docker-username=YOUR_USERNAME --docker-password=YOUR_PASSWORD
```
4. Create a Config Map with a sample dockerfile which we will inject in Kaniko to build
```
apiVersion: v1
kind: ConfigMap
metadata:
    name: kaniko-app-dockerfile
    namespace: kaniko
data:
    dockerfile: |
        FROM nginx:latest
        ENV FOO=bar
        ENV BUILT_WITH=kaniko

```
5. Run the Kaniko pod. This pod does not require private registry. In the case of a private registry, refer to the similar manifest as documented in the project's README file (Kaniko github link above)
```
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
  namespace: kaniko
spec:
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:latest
      args:
        - "--dockerfile=/opt/app/dockerfile"
        - "--context=/opt/ctx"
        - "--no-push"
      volumeMounts:
      - name: app-dockerfile
        mountPath: "/opt/app"
      - name: build-vol
        mountPath: "/opt/ctx"
  restartPolicy: Never
  volumes:
  - name: app-dockerfile
    configMap:
      name: kaniko-app-dockerfile
  - name: build-vol
    emptyDir: {}
```