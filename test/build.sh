set -euo pipefail

REPO_NAME="sdl"

BUILD_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_ROOT=$(realpath "${BUILD_DIR}/..")
SRC_PATH=${REPO_ROOT}"/"${REPO_NAME}

PACKAGE_NAME=${REPO_NAME}".mojopkg"
PACKAGE_PATH=${BUILD_DIR}"/"${PACKAGE_NAME}

echo "╓───  Packaging: sdl-bindings"
mojo package "${SRC_PATH}" -o "${PACKAGE_PATH}"
echo Successfully created "${PACKAGE_PATH}"