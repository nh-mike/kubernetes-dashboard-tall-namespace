```

WEB_VERSION="1.6.1"

#Instal Docker
sudo apt-get install docker.io
sudo usermod -aG docker "${USER}"
su - "${USER}"
```
<hr />

```

#Downloading the docker-layer-extract binary and extracting the Kubernetes
#Dashboard image are only required if you wish to review the contents of
#the image. For building the container, this is not required.

#Download the docker-layer-extract binary for investigation
$ docker run --rm -v $PWD:/out -e GOOS=$(uname -s|tr 'A-Z' 'a-z') golang bash -c 'go install github.com/micahyoung/docker-layer-extract@latest && find /go/bin -name docker-layer-extract | xargs mv -t /out'

#Download and extract the Kubernetes Dashboard Image for investigation
docker pull docker.io/kubernetesui/dashboard-web:${WEB_VERSION}
rm dashboard-web.tar dashboard-web-newest.tar
docker save kubernetesui/dashboard-web -o dashboard-web.tar

rm -rf output
mkdir output

layers="$(./docker-layer-extract --imagefile dashboard-web.tar list | grep ID | awk '{print $2}')"
for layer_id in ${layers}; do
    echo "Extracting layer ${layer_id} to tar"
    rm dashboard-web-layer.tar > /dev/null 2>&1
    ./docker-layer-extract --imagefile dashboard-web.tar extract --layerid "${layer_id}" --layerfile dashboard-web-layer.tar
    echo "Extracting tar archive"
    mkdir "output-${layer_id}"
    tar -xvf dashboard-web-layer.tar -C "output-${layer_id}"
    echo "Merging contents"
    rsync --recursive --remove-source-files "output-${layer_id}/" output/
    # rm -rf "output-${layer_id}"
    rm dashboard-web-layer.tar > /dev/null 2>&1
done

wget "https://raw.githubusercontent.com/kubernetes/dashboard/refs/tags/web/v${WEB_VERSION}/modules/web/Dockerfile" -O "Dockerfile.${WEB_VERSION}"
```
<hr />

```

# Build this image and import into Kubernetes

docker buildx prune -a --force
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx create --name kubernetes-dashboard-tall-namespace-builder
docker buildx use kubernetes-dashboard-tall-namespace-builder

if true; then
    BUILD_PLATFORM="linux/arm64"
    OUTPUTTYPE="docker"
else
    BUILD_PLATFORM="linux/amd64,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x"
    OUTPUTTYPE="local,dest=images"
    rm -rf images
    mkdir images
fi
REPO_OWNER=""
WORKDIR="$(pwd)"

docker buildx build "${WORKDIR}" -f "${WORKDIR}/Dockerfile" --platform "${BUILD_PLATFORM}" \
    -t "${REPO_OWNER}kubernetes-dashboard-tall-namespace:${WEB_VERSION}" \
    --output=type="${OUTPUTTYPE}"

docker buildx rm kubernetes-dashboard-tall-namespace-builder

# docker build . -t kubernetes-dashboard-tall-namespace:${WEB_VERSION}
docker save "${REPO_OWNER}kubernetes-dashboard-tall-namespace" > image.tar
ctr image import image.tar
```

Once you have built, 