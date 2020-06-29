#
# CIP Core, generic profile
#
# Copyright (c) Siemens AG, 2020
#
# Authors:
#  Christian Storm <christian.storm@siemens.com>
#
# SPDX-License-Identifier: MIT

KCONFIG_SNIPPETS = ""

# The following function defines the kconfig snippet system
# with automatich debian dependency injection
#
# To define a feature set, the user has to define the following
# variable to an empty string:
#
# KFEATURE_featurename = ""
#
# Then, required additions to the variables can be defined:
#
# KFEATURE_featurename[KCONFIG_SNIPPETS] = "file://snippet-file-name.snippet"
# KFEATURE_featurename[SRC_URI] = "file://required-file.txt"
# KFEATURE_featurename[DEPENDS] = "deb-pkg1 deb-pkg2 deb-pkg3"
# KFEATURE_featurename[DEBIAN_DEPENDS] = "deb-pkg1"
# KFEATURE_featurename[BUILD_DEB_DEPENDS] = "deb-pkg1,deb-pkg2,deb-pkg3"

# The 'KCONFIG_SNIPPETS' flag gives a list of URI entries, where only
# file:// is supported. These snippets are appended to the DEFCONFIG file.
#
# Features can depend on other features via the following mechanism:
#
# KFEATURE_DEPS[feature1] = "feature2"

python () {
    requested_features = d.getVar("KFEATURES", True) or ""

    features = set(requested_features.split())
    old_features = set()
    feature_deps = d.getVarFlags("KFEATURE_DEPS") or {}
    while old_features != features:
        diff_features = old_features.symmetric_difference(features)
        old_features = features.copy()
        for i in diff_features:
            features.update(feature_deps.get(i, "").split())

    for f in sorted(features):
        bb.debug(2, "Feature: " + f)
        varname = "KFEATURE_" + f
        dummyvar = d.getVar(varname, False)
        if dummyvar == None:
            bb.error("Feature var " + f + " must be defined with needed flags.")
        else:
            feature_flags = d.getVarFlags(varname)
            for feature_varname in sorted(feature_flags):
                if feature_flags.get(feature_varname, "") != "":
                    sep = " "

                    # Required to add KCONFIG_SNIPPETS to SRC_URI here,
                    # because 'SRC_URI += "${KCONFIG_SNIPPETS}"' would
                    # conflict with SRC_APT feature.
                    if feature_varname == "KCONFIG_SNIPPETS":
                        d.appendVar('SRC_URI',
                            " " + feature_flags[feature_varname].strip())

                    # BUILD_DEP_DEPENDS and DEBIAN_DEPENDS is ',' separated
                    # Only add ',' if there is already something there
                    if feature_varname in ["BUILD_DEB_DEPENDS",
                                           "DEBIAN_DEPENDS"]:
                        sep = "," if d.getVar(feature_varname) else ""

                    d.appendVar(feature_varname,
                        sep + feature_flags[feature_varname].strip())
}

# DEFCONFIG must be a predefined bitbake variable and the corresponding file
# must exist in the WORKDIR.
# The resulting generated config is the same file suffixed with ".gen"

do_prepare_build_prepend() {
        sh -x
        GENCONFIG="${WORKDIR}/${DEFCONFIG}".gen
        rm -f "$GENCONFIG"
        cp "${WORKDIR}/${DEFCONFIG}" "$GENCONFIG"
        for CONFIG_SNIPPET in $(echo "${KCONFIG_SNIPPETS}" | sed 's#file://##g')
        do
                cat ${WORKDIR}/$CONFIG_SNIPPET >> "$GENCONFIG"
        done
}
