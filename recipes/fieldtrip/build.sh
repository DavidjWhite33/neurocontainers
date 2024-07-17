#!/usr/bin/env bash
set -e

# this template file builds fieldtrip and is then used as a docker base image for layer caching
export toolName='fieldtrip'
export toolVersion='20240704'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug=$1
fi

source ../main_setup.sh

export MATLAB_VERSION=2021b
export MCR_VERSION=v911

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir -p ${mountPointList}" \
   --install curl unzip ca-certificates openjdk-8-jre dbus-x11 \
   --matlabmcr version=${MATLAB_VERSION} install_path=/opt/mcr  \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --run="curl -fsSL --retry 5 https://object-store.rc.nectar.org.au/v1/AUTH_dead991e1fa847e3afcca2d3a7041f5d/build/${toolName}${toolVersion}_mcr2021b.tar.gz \
      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1 \
      && chmod +x /opt/${toolName}-${toolVersion}/*" \
   --env XAPPLRESDIR=/opt/mcr/${MCR_VERSION}/x11/app-defaults \
   --env LD_LIBRARY_PATH=/opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64:/opt/mcr/${MCR_VERSION}/extern/bin/glnxa64 \
   --env PATH=/opt/${toolName}-${toolVersion}/:$PATH \
   --env DEPLOY_BINS=run_fieldtrip.sh \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$1" != "" ]; then
   ./../main_build.sh
fi


#to copy package archive from local
#  --copy ${toolName}${toolVersion}_mcr2021b.tar.gz /opt/${toolName}-${toolVersion}.tar.gz \
#  --run="tar -xzf /opt/${toolName}-${toolVersion}.tar.gz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \