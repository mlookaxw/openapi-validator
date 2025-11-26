#!/bin/bash
set -euo pipefail

CMD_NAME=$(basename $0)
CMD_HOME=$(dirname $0)


PROJECT_DIR=$(realpath "${CMD_HOME}/..")
LOCAL_REPO_DIR="${PROJECT_DIR}/lib/apigateway-dependencies"

if [ "${1:-}" != "" ]
then
  AXWAY_HOME=$1
fi
if [ "${AXWAY_HOME:-}" == "" ]
then
    echo "Provide API-Gateway installation folder and version. "
    echo "For example: "
    echo "./lib/import-deps.sh /opt/Axway/7.7"
    exit 10
fi
AXWAY_VERSION="7.7"

SYSTEM_LIB_DIR="${AXWAY_HOME}/apigateway/system/lib"

copyDeps() {
    local folder=$1
    local artifact=$2
    local group="com.axway.apigw.local"
    local version="${AXWAY_VERSION}"

    # Locate the JAR within the Gateway installation folder
    local file=$(ls -1 ${folder}/${artifact}-*.jar)
    local num_files=$(echo "$file" | wc -l)
    if [ $num_files -eq 0 ]
    then
      echo "ERROR: no files found for pattern ${givenFile}"
      exit 1
    elif [ $num_files -gt 1 ]
    then
      echo "ERROR: $num_files files found for pattern ${givenFile}"
      exit 1
    fi

    mvn install:install-file \
            -Dfile=${file} \
            -DgroupId=${group} \
            -DartifactId=${artifact} \
            -Dversion=${version} \
            -Dpackaging=jar \
            -DgeneratePom=true \
            -DlocalRepositoryPath=${LOCAL_REPO_DIR}
}


copyDeps "${SYSTEM_LIB_DIR}"         "vordel-apimanager"
copyDeps "${SYSTEM_LIB_DIR}"         "vordel-api-model"
copyDeps "${SYSTEM_LIB_DIR}"         "vordel-core-controller"
copyDeps "${SYSTEM_LIB_DIR}"         "vordel-core-runtime"
copyDeps "${SYSTEM_LIB_DIR}"         "vordel-swagger-model"
copyDeps "${SYSTEM_LIB_DIR}/plugins" "apigw-common"
copyDeps "${SYSTEM_LIB_DIR}/plugins" "vordel-common"
copyDeps "${SYSTEM_LIB_DIR}/plugins" "vordel-mime"
copyDeps "${SYSTEM_LIB_DIR}/plugins" "vordel-trace"
copyDeps "${SYSTEM_LIB_DIR}/plugins" "resource-repo"
copyDeps "${SYSTEM_LIB_DIR}/modules" "jakarta.ws.rs-api"
