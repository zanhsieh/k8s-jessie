export KUBERNETES_MASTER=http://m1:8080
sudo apt -y install curl
echo "Starting Kubernetes v1.2.2..."
docker run -d \
  --net=host \
  gcr.io/google_containers/etcd:2.2.1 /usr/local/bin/etcd \
  --listen-client-urls=http://0.0.0.0:4001 \
  --advertise-client-urls=http://0.0.0.0:4001 \
  --data-dir=/var/etcd/data

docker run -d --name=apiserver \
  --net=host --pid=host --privileged=true \
  gcr.io/google_containers/hyperkube:v1.2.2 \
  /hyperkube apiserver \
  --insecure-bind-address=0.0.0.0 \
  --service-cluster-ip-range=10.0.40.1/24 \
  --etcd_servers=http://127.0.0.1:4001 \
  --v=2

docker run -d --name=controller-manager \
  --net=host --pid=host --privileged=true \
  gcr.io/google_containers/hyperkube:v1.2.2 \
  /hyperkube controller-manager \
  --master=0.0.0.0:8080 \
  --service-account-private-key-file=/srv/kubernetes/server.key \
  --root-ca-file=/srv/kubernetes/ca.crt \
  --min-resync-period=3m \
  --v=2

docker run -d --name=scheduler \
  --net=host --pid=host --privileged=true \
  gcr.io/google_containers/hyperkube:v1.2.2 \
  /hyperkube scheduler \
  --master=127.0.0.1:8080 \
  --v=2

docker run -d --name=kubs \
  --net=host --pid=host --privileged=true \
  --volume=/:/rootfs:ro --volume=/sys:/sys:ro \
  --volume=/dev:/dev --volume=/var/lib/docker/:/var/lib/docker:rw \
  --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
  --volume=/var/run:/var/run:rw \
  gcr.io/google_containers/hyperkube:v1.2.2 \
  /hyperkube kubelet \
  --allow-privileged=true --containerized --enable-server \
  --cluster_dns=10.0.40.10 --cluster_domain=cluster.local \
  --config=/etc/kubernetes/manifests-multi \
  --address="0.0.0.0" --api-servers=http://0.0.0.0:8080

docker run -d --name=proxy \
  --net=host --privileged=true \
  gcr.io/google_containers/hyperkube:v1.2.2 \
  /hyperkube proxy \
  --master=http://0.0.0.0:8080 \
  --v=2

echo "Downloading Kubectl..."
#curl -o /usr/local/bin/kubectl http://storage.googleapis.com/kubernetes-release/release/v1.2.2/bin/linux/amd64/kubectl
cp -f kubectl-1.3.4 /usr/local/bin/kubectl
chmod u+x /usr/local/bin/kubectl
export KUBERNETES_MASTER=http://m1:8080
echo "Waiting for Kubernetes to start..."
until $(kubectl cluster-info &> /dev/null); do
  sleep 1
done
echo "Kubernetes started"

echo "Starting Kubernetes DNS..."
kubectl -s http://m1:8080 create -f kube-system.yaml
kubectl -s http://m1:8080 create -f skydns-rc.yaml
kubectl -s http://m1:8080 create -f skydns-svc.yaml

echo "Starting Kubernetes UI..."
kubectl -s http://m1:8080 create -f dashboard.yaml
kubectl -s http://m1:8080 cluster-info

