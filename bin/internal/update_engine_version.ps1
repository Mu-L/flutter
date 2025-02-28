# Copyright 2014 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Want to test this script?
# $ cd dev/tools
# $ dart test test/update_engine_version_test.dart

# ---------------------------------- NOTE ---------------------------------- #
#
# Please keep the logic in this file consistent with the logic in the
# `update_engine_version.sh` script in the same directory to ensure that Flutter
# continues to work across all platforms!
#
# -------------------------------------------------------------------------- #

$ErrorActionPreference = "Stop"

$progName = Split-Path -parent $MyInvocation.MyCommand.Definition
$flutterRoot = (Get-Item $progName).parent.parent.FullName

# Generate a bin/cache directory, which won't initially exist for a fresh checkout.
New-Item -Path "$flutterRoot/bin/cache" -ItemType Directory -Force | Out-Null

# On stable, beta, and release tags, the engine.version is tracked by git - do not override it.
$trackedEngine = (git -C "$flutterRoot" ls-files bin/internal/engine.version) | Out-String
if ($trackedEngine.length -ne 0) {
  Copy-Item -Path "$flutterRoot/bin/internal/engine.version" -Destination "$flutterRoot/bin/cache/engine.stamp" -Force
  return
}

# Allow overriding the intended engine version via FLUTTER_PREBUILT_ENGINE_VERSION.
#
# This is for systems, such as Github Actions, where we know ahead of time the
# base-ref we want to use (to download the engine binaries and avoid trying
# to compute one below), or for the Dart HH bot, which wants to try the current
# Flutter framework/engine with a different Dart SDK.
#
# This environment variable is EXPERIMENTAL. If you are not on the Flutter infra
# or Dart infra teams, this code path might be removed at anytime and cease
# functioning. Please file an issue if you have workflow needs.
if (![string]::IsNullOrEmpty($env:FLUTTER_PREBUILT_ENGINE_VERSION)) {
  $engineVersion = $env:FLUTTER_PREBUILT_ENGINE_VERSION
}

# Test for fusion repository
if ([string]::IsNullOrEmpty($engineVersion) -and (Test-Path "$flutterRoot/DEPS" -PathType Leaf) -and (Test-Path "$flutterRoot/engine/src/.gn" -PathType Leaf)) {
    if ($null -eq $Env:LUCI_CONTEXT) {
        $ErrorActionPreference = "Continue"
        git -C "$flutterRoot" remote get-url upstream *> $null
        $exitCode = $?
        $ErrorActionPreference = "Stop"
        if ($exitCode) {
            $engineVersion = (git -C "$flutterRoot"  merge-base HEAD upstream/master)
        } else {
            $engineVersion = (git -C "$flutterRoot"  merge-base HEAD origin/master)
        }
    }
    else {
        $engineVersion = (git -C "$flutterRoot" rev-parse HEAD)
    }
}

# Write the engine version out so downstream tools know what to look for.
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText("$flutterRoot/bin/cache/engine.stamp", $engineVersion, $utf8NoBom)
# TODO(matanlurey): Stop writing to internal/engine.version. https://github.com/flutter/flutter/issues/164315.
[System.IO.File]::WriteAllText("$flutterRoot/bin/internal/engine.version", $engineVersion, $utf8NoBom)

# The realm on CI is passed in.
if ($Env:FLUTTER_REALM) {
    [System.IO.File]::WriteAllText("$flutterRoot/bin/cache/engine.realm", $Env:FLUTTER_REALM, $utf8NoBom)
    # TODO(matanlurey): Stop writing to internal/engine.realm. https://github.com/flutter/flutter/issues/164315.
    [System.IO.File]::WriteAllText("$flutterRoot/bin/internal/engine.realm", $Env:FLUTTER_REALM, $utf8NoBom)
} else {
    [System.IO.File]::WriteAllText("$flutterRoot/bin/cache/engine.realm", "", $utf8NoBom)
    # TODO(matanlurey): Stop writing to internal/engine.realm. https://github.com/flutter/flutter/issues/164315.
    [System.IO.File]::WriteAllText("$flutterRoot/bin/internal/engine.realm", "", $utf8NoBom)
}
