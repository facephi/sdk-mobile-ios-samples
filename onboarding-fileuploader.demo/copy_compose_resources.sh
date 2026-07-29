#!/usr/bin/env bash
set -euo pipefail

# Merges Compose Multiplatform resources for multi-widget KMP hosts (CocoaPods).
#
# v0.6 — multi-widget: pods + embedded frameworks + cleanup.
# Canonical copy: SDK/SPM-ToolsForDevelopers/scripts/copy_compose_resources.sh
# Phingers NCNN model files are still copied by CocoaPods into *.app/models/ when applicable.
#
# Run AFTER "[CP] Embed Pods Frameworks" in the app target build phases.
SCRIPT_VERSION="0.6"
LOG_PREFIX="${COMPOSE_RESOURCES_LOG_PREFIX:-[copy-compose-resources]}"
DESIGN_SYSTEM_NAMESPACE="com.facephi.design_system_kmp.resources"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRCROOT="${SRCROOT:-$SCRIPT_DIR}"
REPO_ROOT="${COMPOSE_RESOURCES_REPO_ROOT:-${SRCROOT}/..}"
TARGET_BUILD_DIR="${TARGET_BUILD_DIR:-$SCRIPT_DIR/.tmp}"
UNLOCALIZED_RESOURCES_FOLDER_PATH="${UNLOCALIZED_RESOURCES_FOLDER_PATH:-}"
FRAMEWORKS_FOLDER_PATH="${FRAMEWORKS_FOLDER_PATH:-Frameworks}"

PODS_DIR="${PODS_ROOT:-${SRCROOT}/Pods}"
APP_BUNDLE="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
DEST="${APP_BUNDLE}/compose-resources"
APP_RESOURCES_ROOT="${APP_BUNDLE}"

if [ -n "${FRAMEWORKS_FOLDER_PATH}" ] && [ -d "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" ]; then
  FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
elif [ -d "${APP_BUNDLE}/Frameworks" ]; then
  FRAMEWORKS_DIR="${APP_BUNDLE}/Frameworks"
else
  FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH:-Frameworks}"
fi

echo "${LOG_PREFIX} v${SCRIPT_VERSION} Preparing merged Compose resources at: ${DEST}"

mkdir -p "${DEST}/composeResources"

COPIED_SOURCES=()

is_compose_namespace_name() {
  local name="$1"
  [[ "${name}" == *.* ]] && [[ "${name}" == *.resources ]]
}

is_widget_resources_pod() {
  local pod_name="$1"
  [[ "${pod_name}" == *WidgetResources ]]
}

namespace_exists_in_dest() {
  local namespace_name="$1"
  local namespace_dir="${DEST}/composeResources/${namespace_name}"
  [ -d "${namespace_dir}" ] && \
    find "${namespace_dir}" -mindepth 1 -print -quit 2>/dev/null | grep -q .
}

list_app_root_namespace_dirs() {
  if [ ! -d "${APP_RESOURCES_ROOT}" ]; then
    return 0
  fi

  while IFS= read -r namespace_dir; do
    local namespace_name
    namespace_name="$(basename "${namespace_dir}")"
    if is_compose_namespace_name "${namespace_name}"; then
      echo "${namespace_dir}"
    fi
  done < <(find "${APP_RESOURCES_ROOT}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
}

has_merged_compose_namespaces() {
  [ -d "${DEST}/composeResources" ] && \
    find "${DEST}/composeResources" -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null | grep -q .
}

list_merged_namespace_dirs() {
  if [ ! -d "${DEST}/composeResources" ]; then
    return 0
  fi
  find "${DEST}/composeResources" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort
}

log_existing_dest_namespaces() {
  if ! has_merged_compose_namespaces; then
    echo "${LOG_PREFIX} No pre-existing namespaces under ${DEST}/composeResources (typical when [CP] only copied Design System)."
    return 0
  fi

  echo "${LOG_PREFIX} Pre-existing namespaces in app bundle (preserved, not wiped):"
  while IFS= read -r namespace_dir; do
    echo "${LOG_PREFIX}   - $(basename "${namespace_dir}")"
  done < <(list_merged_namespace_dirs)
}

remove_loose_compose_artifact_if_merged() {
  local name="$1"
  local artifact="${APP_RESOURCES_ROOT}/${name}"

  if [ ! -e "${artifact}" ]; then
    return 0
  fi
  if ! has_merged_compose_namespaces; then
    return 0
  fi

  echo "${LOG_PREFIX} Removing duplicate CocoaPods compose artifact: ${artifact}"
  rm -rf "${artifact}"
}

merge_namespace_dir() {
  local namespace_dir="$1"
  local namespace_name
  namespace_name="$(basename "${namespace_dir}")"

  if ! is_compose_namespace_name "${namespace_name}"; then
    return 0
  fi

  mkdir -p "${DEST}/composeResources/${namespace_name}"
  echo "${LOG_PREFIX} Merging namespace ${namespace_name} from: ${namespace_dir}"
  rsync -a --exclude='.DS_Store' "${namespace_dir}/" "${DEST}/composeResources/${namespace_name}/"
}

merge_namespace_from_tree() {
  local src_root="$1"
  local namespace_name="$2"
  local namespace_dir="${src_root}/composeResources/${namespace_name}"

  if [ ! -d "${namespace_dir}" ]; then
    return 0
  fi

  merge_namespace_dir "${namespace_dir}"
}

merge_compose_tree_excluding_design_system() {
  local src="$1"
  if [ ! -d "${src}/composeResources" ]; then
    return 0
  fi

  while IFS= read -r namespace_dir; do
    local namespace_name
    namespace_name="$(basename "${namespace_dir}")"
    if [ "${namespace_name}" = "${DESIGN_SYSTEM_NAMESPACE}" ]; then
      echo "${LOG_PREFIX} Skipping duplicate Design System namespace from: ${src}"
      continue
    fi
    merge_namespace_from_tree "${src}" "${namespace_name}"
  done < <(find "${src}/composeResources" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
}

copy_compose_resources_tree() {
  local src="$1"
  if [ ! -d "${src}" ]; then
    return 0
  fi

  local canonical
  canonical="$(cd "${src}" && pwd)"
  for seen in "${COPIED_SOURCES[@]:-}"; do
    if [ "${seen}" = "${canonical}" ]; then
      return 0
    fi
  done
  COPIED_SOURCES+=("${canonical}")

  if [ ! -d "${src}/composeResources" ]; then
    echo "${LOG_PREFIX} Merging compose-resources tree from: ${src}"
    rsync -a --exclude='.DS_Store' "${src}/" "${DEST}/"
    return 0
  fi

  echo "${LOG_PREFIX} Merging compose-resources namespaces from: ${src}"
  while IFS= read -r namespace_dir; do
    merge_namespace_dir "${namespace_dir}"
  done < <(find "${src}/composeResources" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
}

find_compose_resource_roots_in_dir() {
  local base_dir="$1"
  if [ ! -d "${base_dir}" ]; then
    return 0
  fi

  find "${base_dir}" \( \
    -path '*/compose/cocoapods/compose-resources' -o \
    -path '*/build/compose/cocoapods/compose-resources' -o \
    -path '*/Resources/compose-resources' -o \
    -path '*/compose-resources' \
  \) -type d 2>/dev/null | sort
}

merge_compose_resources_from_pods() {
  if [ ! -d "${PODS_DIR}" ]; then
    echo "${LOG_PREFIX} No Pods directory at ${PODS_DIR}; will rely on app bundle and embedded frameworks."
    return 0
  fi

  # Single source of truth for Design System compose resources.
  if [ -d "${PODS_DIR}/FPHIDesignSystemResources" ]; then
    while IFS= read -r resource_dir; do
      copy_compose_resources_tree "${resource_dir}"
    done < <(find_compose_resource_roots_in_dir "${PODS_DIR}/FPHIDesignSystemResources")
  fi

  while IFS= read -r pod_dir; do
    local pod_name
    pod_name="$(basename "${pod_dir}")"

    case "${pod_name}" in
      FPHIDesignSystemResources)
        continue
        ;;
      *)
        if is_widget_resources_pod "${pod_name}"; then
          # Widget *Resources pods may still ship the full compose tree (pre SM-8119).
          while IFS= read -r resource_dir; do
            merge_compose_tree_excluding_design_system "${resource_dir}"
          done < <(find_compose_resource_roots_in_dir "${pod_dir}")
        fi
        ;;
    esac
  done < <(find "${PODS_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
}

salvage_cocoapods_root_compose_namespaces() {
  if [ -d "${APP_RESOURCES_ROOT}/composeResources" ]; then
    while IFS= read -r namespace_dir; do
      merge_namespace_dir "${namespace_dir}"
    done < <(find "${APP_RESOURCES_ROOT}/composeResources" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
  fi

  while IFS= read -r namespace_dir; do
    merge_namespace_dir "${namespace_dir}"
  done < <(list_app_root_namespace_dirs)
}

salvage_namespaces_from_embedded_frameworks() {
  if [ ! -d "${FRAMEWORKS_DIR}" ]; then
    echo "${LOG_PREFIX} No frameworks dir at ${FRAMEWORKS_DIR}; skipping framework salvage."
    return 0
  fi

  while IFS= read -r framework_compose_dir; do
    local framework_name
    framework_name="$(basename "$(dirname "${framework_compose_dir}")")"

    while IFS= read -r namespace_dir; do
      local namespace_name
      namespace_name="$(basename "${namespace_dir}")"

      if ! is_compose_namespace_name "${namespace_name}"; then
        continue
      fi

      if [ "${namespace_name}" = "${DESIGN_SYSTEM_NAMESPACE}" ] && namespace_exists_in_dest "${namespace_name}"; then
        echo "${LOG_PREFIX} Skipping Design System from ${framework_name} (already in app compose-resources)."
        continue
      fi

      if namespace_exists_in_dest "${namespace_name}"; then
        echo "${LOG_PREFIX} Skipping ${namespace_name} from ${framework_name} (already merged)."
        continue
      fi

      echo "${LOG_PREFIX} Salvaging ${namespace_name} from embedded framework ${framework_name}"
      merge_namespace_dir "${namespace_dir}"
    done < <(find "${framework_compose_dir}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
  done < <(find "${FRAMEWORKS_DIR}" -path '*/composeResources' -type d 2>/dev/null | sort)
}

prune_legacy_strings_xml() {
  while IFS= read -r compiled_resource; do
    local xml_resource
    xml_resource="$(dirname "${compiled_resource}")/strings.xml"
    if [ -f "${xml_resource}" ]; then
      echo "${LOG_PREFIX} Removing stale XML resource: ${xml_resource}"
      rm -f "${xml_resource}"
    fi
  done < <(find "${DEST}" -path '*/values*/strings.commonMain.cvr' -type f 2>/dev/null | sort)

  if [ ! -d "${DEST}/composeResources" ]; then
    return 0
  fi

  while IFS= read -r namespace_dir; do
    if ! find "${namespace_dir}" -path '*/values*/strings.commonMain.cvr' -type f -print -quit 2>/dev/null | grep -q .; then
      continue
    fi

    while IFS= read -r xml_resource; do
      echo "${LOG_PREFIX} Removing stale XML in compiled namespace: ${xml_resource}"
      rm -f "${xml_resource}"
    done < <(find "${namespace_dir}" -name 'strings.xml' -type f 2>/dev/null | sort)
  done < <(find "${DEST}/composeResources" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
}

mirror_compose_files_for_readbytes() {
  local files_root="${DEST}/files"
  mkdir -p "${files_root}"

  while IFS= read -r resource_file; do
    local file_name
    file_name="$(basename "${resource_file}")"
    cp -f "${resource_file}" "${files_root}/${file_name}"
  done < <(find "${DEST}/composeResources" -path '*/files/*' -type f 2>/dev/null | sort)

  if [ -n "$(find "${files_root}" -mindepth 1 -print -quit 2>/dev/null)" ]; then
    echo "${LOG_PREFIX} Mirrored compose JSON/file assets to: ${files_root}"
  fi
}

cleanup_flat_compose_tables_under_dest() {
  if [ ! -d "${DEST}" ]; then
    return 0
  fi

  while IFS= read -r flat_cvr; do
    echo "${LOG_PREFIX} Removing legacy flat string table under compose-resources: ${flat_cvr}"
    rm -f "${flat_cvr}"
  done < <(find "${DEST}" -maxdepth 2 -path '*/values*/strings.commonMain.cvr' -type f ! -path '*/composeResources/*' 2>/dev/null | sort)
}

cleanup_cocoapods_flat_compose_artifacts() {
  local flat_cvr="${APP_RESOURCES_ROOT}/strings.commonMain.cvr"
  if [ -f "${flat_cvr}" ]; then
    echo "${LOG_PREFIX} Removing flat CocoaPods strings.commonMain.cvr collision: ${flat_cvr}"
    rm -f "${flat_cvr}"
  fi
}

remove_cocoapods_root_compose_duplicates() {
  if [ -e "${APP_RESOURCES_ROOT}/composeResources" ]; then
    echo "${LOG_PREFIX} Removing duplicate CocoaPods compose artifact: ${APP_RESOURCES_ROOT}/composeResources"
    rm -rf "${APP_RESOURCES_ROOT}/composeResources"
  fi

  while IFS= read -r namespace_dir; do
    echo "${LOG_PREFIX} Removing duplicate CocoaPods compose artifact: ${namespace_dir}"
    rm -rf "${namespace_dir}"
  done < <(list_app_root_namespace_dirs)

  remove_loose_compose_artifact_if_merged "drawable"
  remove_loose_compose_artifact_if_merged "files"
  remove_loose_compose_artifact_if_merged "font"

  if has_merged_compose_namespaces; then
    while IFS= read -r values_dir; do
      echo "${LOG_PREFIX} Removing duplicate CocoaPods compose artifact: ${values_dir}"
      rm -rf "${values_dir}"
    done < <(find "${APP_RESOURCES_ROOT}" -maxdepth 1 -type d -name 'values*' 2>/dev/null | sort)
  fi
}

strip_embedded_compose_resources_from_frameworks() {
  if [ ! -d "${FRAMEWORKS_DIR}" ]; then
    echo "${LOG_PREFIX} No embedded frameworks dir at ${FRAMEWORKS_DIR}; skipping strip."
    return 0
  fi

  while IFS= read -r compose_resources_dir; do
    echo "${LOG_PREFIX} Removing embedded composeResources to force app-bundle lookup: ${compose_resources_dir}"
    rm -rf "${compose_resources_dir}"
  done < <(find "${FRAMEWORKS_DIR}" -maxdepth 2 -path '*/composeResources' -type d 2>/dev/null | sort -r)
}

verify_no_embedded_compose_resources_remain() {
  if [ ! -d "${FRAMEWORKS_DIR}" ]; then
    return 0
  fi

  local remaining
  remaining="$(find "${FRAMEWORKS_DIR}" -maxdepth 2 -path '*/composeResources' -type d 2>/dev/null | sort || true)"
  if [ -n "${remaining}" ]; then
    echo "${LOG_PREFIX} ERROR: embedded composeResources still present after strip:" >&2
    echo "${remaining}" >&2
    echo "${LOG_PREFIX} Ensure the 'Copy Compose Resources' build phase runs AFTER '[CP] Embed Pods Frameworks'." >&2
    exit 1
  fi
}

verify_merged_namespace_strings() {
  local missing=0

  while IFS= read -r namespace_dir; do
    if ! find "${namespace_dir}" -path '*/values*/strings.commonMain.cvr' -type f -print -quit 2>/dev/null | grep -q .; then
      continue
    fi

    local main_cvr="${namespace_dir}/values/strings.commonMain.cvr"
    if [ ! -f "${main_cvr}" ]; then
      echo "${LOG_PREFIX} ERROR: missing compiled strings at ${main_cvr}" >&2
      missing=1
      continue
    fi

    echo "${LOG_PREFIX} Verified compiled strings at: ${main_cvr}"
  done < <(list_merged_namespace_dirs)

  if [ "${missing}" -ne 0 ]; then
    echo "${LOG_PREFIX} Ensure widget *Resources pods are declared in the Podfile and run pod install." >&2
    exit 1
  fi
}

verify_design_system_strings() {
  local ds_cvr="${DEST}/composeResources/${DESIGN_SYSTEM_NAMESPACE}/values/strings.commonMain.cvr"
  if [ ! -f "${ds_cvr}" ]; then
    echo "${LOG_PREFIX} ERROR: missing Design System strings at ${ds_cvr}" >&2
    exit 1
  fi

  if ! grep -q 'fphi_exit_alert_title' "${ds_cvr}"; then
    echo "${LOG_PREFIX} ERROR: Design System strings look invalid at ${ds_cvr}" >&2
    exit 1
  fi

  echo "${LOG_PREFIX} Verified Design System strings at: ${ds_cvr}"
}

summarize_merged_namespaces() {
  echo "${LOG_PREFIX} Final namespaces in ${DEST}/composeResources:"
  while IFS= read -r namespace_dir; do
    echo "${LOG_PREFIX}   - $(basename "${namespace_dir}")"
  done < <(list_merged_namespace_dirs)
}

merge_optional_compose_tree() {
  local src="$1"
  if [ ! -d "${src}" ]; then
    return 0
  fi

  if [ -d "${src}/composeResources" ]; then
    copy_compose_resources_tree "${src}"
    return 0
  fi

  local first_child
  first_child="$(find "${src}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -n 1 || true)"
  if [ -n "${first_child}" ] && is_compose_namespace_name "$(basename "${first_child}")"; then
    echo "${LOG_PREFIX} Merging compose namespace folders from: ${src}"
    while IFS= read -r namespace_dir; do
      merge_namespace_dir "${namespace_dir}"
    done < <(find "${src}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
    return 0
  fi

  copy_compose_resources_tree "${src}"
}

merge_optional_local_development_paths() {
  merge_optional_compose_tree "${REPO_ROOT}/composeApp/build/compose/cocoapods/compose-resources"

  for module_dir in fphicapture fphinfc fphiphingers; do
    merge_optional_compose_tree "${REPO_ROOT}/${module_dir}/build/compose/cocoapods/compose-resources"
    merge_optional_compose_tree "${REPO_ROOT}/${module_dir}/build/generated/compose/resourceGenerator/preparedResources/commonMain/composeResources"
  done

  if [ -d "${REPO_ROOT}/composeApp/build/cocoapods/synthetic/ios/Pods" ]; then
    while IFS= read -r resource_dir; do
      merge_compose_tree_excluding_design_system "${resource_dir}"
    done < <(find_compose_resource_roots_in_dir "${REPO_ROOT}/composeApp/build/cocoapods/synthetic/ios/Pods")
  fi

  if [ -d "${REPO_ROOT}/fphinfc/build/cocoapods/synthetic/ios/Pods" ]; then
    while IFS= read -r resource_dir; do
      merge_compose_tree_excluding_design_system "${resource_dir}"
    done < <(find_compose_resource_roots_in_dir "${REPO_ROOT}/fphinfc/build/cocoapods/synthetic/ios/Pods")
  fi

  merge_optional_compose_tree "${SRCROOT}/FPHINfcPackages/compose-resources"
}

sync_phingers_models_if_present() {
  local models_dest="${APP_RESOURCES_ROOT}/models"
  local copied=0

  copy_model_files_from_dir() {
    local source_dir="$1"
    if [ ! -d "${source_dir}" ]; then
      return 0
    fi
    while IFS= read -r model_file; do
      copied=1
      mkdir -p "${models_dest}"
      cp -f "${model_file}" "${models_dest}/"
    done < <(find "${source_dir}" -maxdepth 1 -type f -name 'finger_*' 2>/dev/null | sort)
    if [ "${copied}" -eq 1 ]; then
      echo "${LOG_PREFIX} Phingers models sourced from: ${source_dir}"
    fi
  }

  copy_model_files_from_dir "${PODS_DIR}/FPHIPhingersWidgetResources/cocoapods/resources/models"
  copy_model_files_from_dir "${REPO_ROOT}/composeApp/build/cocoapods/synthetic/ios/Pods/FPHIPhingersWidgetResources/cocoapods/resources/models"

  if [ "${copied}" -eq 1 ]; then
    echo "${LOG_PREFIX} Phingers models ready in: ${models_dest}"
  fi
}

# --- Pipeline (order matters) ---

log_existing_dest_namespaces
merge_compose_resources_from_pods
merge_optional_local_development_paths
salvage_cocoapods_root_compose_namespaces
salvage_namespaces_from_embedded_frameworks

if [ ! -d "${DEST}/composeResources" ] || ! has_merged_compose_namespaces; then
  echo "${LOG_PREFIX} ERROR: merged compose resources are missing at ${DEST}/composeResources" >&2
  echo "${LOG_PREFIX} Declare widget + *WidgetResources pods, run pod install, and keep this phase after Embed Pods Frameworks." >&2
  exit 1
fi

prune_legacy_strings_xml
cleanup_flat_compose_tables_under_dest
mirror_compose_files_for_readbytes
verify_merged_namespace_strings
verify_design_system_strings
strip_embedded_compose_resources_from_frameworks
verify_no_embedded_compose_resources_remain
cleanup_cocoapods_flat_compose_artifacts
remove_cocoapods_root_compose_duplicates
summarize_merged_namespaces
sync_phingers_models_if_present

echo "${LOG_PREFIX} Compose resources ready (frameworks dir: ${FRAMEWORKS_DIR})."
