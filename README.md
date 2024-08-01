# RPM MetaData

This repository contains the various schema files for the RPM MetaData (rpm-md) format
created originally for the Yellowdog Updater, Modified (YUM) and supported by a large number
of RPM package managers.

Currently, there is no reference files for this, so this repository contains a collection of
schema files from various sources (under `historical/`), which will hopefully be used to create
a rationalized, uniform definition of what the metadata format actually is.

History
-------

There are now a good handful of package managers that have used and evolved
a repository format that is generally referred to as a `yum` repository. The
original release of `yum`, the "Yellowdog Updater Modified", was in 2002,
and was present in Fedora Core 1, released in 2003.

There have been previous attempts to document the repository format, most
notably in openSUSE.
https://en.opensuse.org/openSUSE:Standards_Rpm_Metadata

There exist repositories using a SQLite variant of the repository format,
with some repositories *exclusively* using it, having only the `repomd.xml`
top level file in XML. The SQLite variant is understood by `yum`, but did
not make the leap to `dnf` at all.

The SQLite repository format variant is not understood by `libsolv`, which is
used by most current generation RPM package managers.

Package Managers
----------------

Package managers known to use the `yum` metadata format include:

- `yum` [github](https://github.com/rpm-software-management/yum) and http://yum.baseurl.org/
  - Currently used by:
    - [Amazon Linux 2](https://aws.amazon.com/amazon-linux-2/)
  - No longer used by:
    - [Fedora](https://fedoraproject.org/)
    - [RHEL](https://redhat.com/rhel/)
- `dnf` (aka `dnf` version 4) [github](https://github.com/rpm-software-management/dnf), [`dnf` documentation](https://dnf.readthedocs.io/en/latest/)
  - Currently used by:
    - [Amazon Linux 2023](https://aws.amazon.com/linux/amazon-linux-2023/)
    - [Fedora](https://fedoraproject.org/)
    - [RHEL](https://redhat.com/rhel/)
- `dnf5` (aka `dnf` version 5) [github](https://github.com/rpm-software-management/dnf5), [`dnf5` documentation](https://dnf5.readthedocs.io/en/latest/)
  - Targeted for [Fedora](https://fedoraproject.org/) 41, see ([SwitchToDnf5](https://fedoraproject.org/wiki/Changes/SwitchToDnf5))
- `zypper` [github](https://github.com/openSUSE/zypper) and https://en.opensuse.org/Portal:Zypper
  - Currently used by:
    - [openSUSE](https://en.opensuse.org/)
    - [SUSE Linux Enterprise](http://www.suse.com/)

Repository Structure
====================

The basic structure is that a `repodata/repomd.xml` file exists, which points
to all other metadata about the repository.