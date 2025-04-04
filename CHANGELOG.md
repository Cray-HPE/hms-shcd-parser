# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.11.0] - 2025-03-19

- Updated image and module dependencies for security updates
- Updated Go to v1.24
- Updated README to point to artifactory rather than old DTR
- Internal tracking ticket: CASMHMS-6416

## [1.10.0] - 2024-12-04

### Changed

- Updated go to 1.23

## [1.9.0] - 2023-06-07

### Changed

- CASMHMS-6036: Switched base image to artifactory.algol60.net/csm-docker/stable/docker.io/library/alpine:3.15

## [1.8.0] - 2022-01-06

### Security

- converted from arti to artifactory and resolved a CVE.

## [1.7.0] - 2021-10-29

### Changed

- version bump to adhere to semvere standard

## [1.6.3] - 2021-08-10

### Changed

- Added GitHub config files
- Fixed snyk issue in Dockerfiles

## [1.6.2] - 2021-07-28

### Changed

- Changed Stash to GitHub

## [1.6.1] - 2021-07-26

### Changed 

- Add GH pipeline build support. 

## [1.6.0] - 2021-07-06

### Changed

- Bump minor version for CSM 1.2 release branch.

## [1.5.0] - 2021-06-30

### Security

- CASMHMS-4898 - Updated base container images for security updates.

## [1.4.2] - 2021-04-20

### Changed

- Updated Dockerfile to pull base images from Artifactory instead of DTR.

## [1.4.1] - 2021-01-28

### Changed

- CASMHMS-3982 - Updates to allow empty table rows in HMN sheet.

## [1.4.0] - 2021-01-27

### Changed

- Updated to MIT License
- Ran go mod tidy and go mod vendor

## [1.3.0] - 2021-01-14

### Changed

- fix version.

## [1.2.0] - 2021-01-14

### Changed

- Updated license file.

## [1.1.1]

### Security

- CASMHMS-4105 - Updated base Golang Alpine image to resolve libcrypto vulnerability.

## [1.1.0]

### Security

- CASMHMS-4065 - Update base image to alpine-3.12.

## [1.0.0]

### Added

- This is the initial release.
