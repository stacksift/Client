#!/bin/sh

#  setup_sparkle.sh
#  Client
#
#  Created by Matthew Massicotte on 2021-06-17.
#  

set -euxo pipefail

SPARKLE_FRAMEWORK="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/Sparkle.framework"

# Remove unnecessary components for XPC integration

rm "${SPARKLE_FRAMEWORK}/Autoupdate"
rm "${SPARKLE_FRAMEWORK}/Updater.app"
rm "${SPARKLE_FRAMEWORK}/Versions/A/Autoupdate"
rm -r "${SPARKLE_FRAMEWORK}/Versions/A/Updater.app"
