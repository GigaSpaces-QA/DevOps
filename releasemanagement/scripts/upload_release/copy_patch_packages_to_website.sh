#!/bin/bash

source params.sh

DEST_DIR=\s3://patch.gigaspaces.com/${VERSION}_patch${PATCH_NUMBER}
echo DEST_DIR=${DEST_DIR}
CLOUDIFY_BUILD_DIR=${REPOSITORY}/cloudify/${VERSION}/build_${BUILD_NUMBER}

XAP_ZIP_FILE="${BUILD_DIR}/xap-premium/1.5/gigaspaces-xap-premium-${VERSION}-ga-b${BUILD_NUMBER}.zip"
CLOUDIFY_FILES="${CLOUDIFY_BUILD_DIR}/cloudify/1.5/*"
DOTNET_FILES="${BUILD_DIR}/xap-premium/dotnet/*-Premium-*.msi"
CPP_FILES="${BUILD_DIR}/gigaspaces-cpp-*.tar.gz"


RN_FILE=Release_Notes_${MAJOR}_${MINOR}_${SERVICEPACK}_patch${PATCH_NUMBER}.doc


#copy release notes file
s3cmd put --recurcive ~/.ssh/website ${REPOSITORY}/release_notes/${RN_FILE} s3://patch.gigaspaces.com/${DEST_DIR}

#copy package files
case  $PATCH_TYPE  in
      xap)
         s3cmd put --recurcive ~/.ssh/website $XAP_ZIP_FILE s3://patch.gigaspaces.com/${DEST_DIR}
        ;;
      dotnet)
        s3cmd put --recurcive ~/.ssh/website $DOTNET_FILES s3://patch.gigaspaces.com/${DEST_DIR}
        ;;
      cpp)
         s3cmd put --recurcive ~/.ssh/website $CPP_FILES s3://patch.gigaspaces.com/${DEST_DIR}
        ;;
      cloudify)
        s3cmd put --recurcive ~/.ssh/website $CLOUDIFY_FILES s3://patch.gigaspaces.com/${DEST_DIR}
        ;;

      *)
esac


