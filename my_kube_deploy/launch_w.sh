export KUBERNETES_MASTER=http://m1:8080
docker run -d --name=kubs \
  --net=host --pid=host --privileged=true \
  --volume=/:/rootfs:ro --volume=/sys:/sys:ro \
  --volume=/dev:/dev --volume=/var/lib/docker/:/var/lib/docker:rw \
  --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
  --volume=/var/run:/var/run:rw  \
  gcr.io/google_containers/hyperkube:v1.2.2 \
  /hyperkube kubelet \
  --allow-privileged=true --containerized --enable-server \
  --cluster_dns=10.0.40.10 --cluster_domain=cluster.local \
  --config=/etc/kubernetes/manifests-multi \
  --address=0.0.0.0 --api-servers=http://10.0.40.41:8080
docker run -d --name=proxy \
  --net=host --privileged \
  gcr.io/google_containers/hyperkube:v1.2.2 \
  /hyperkube proxy \
  --master=http://10.0.40.41:8080 --v=2
