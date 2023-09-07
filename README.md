# quartus-install.py

This script installs Intel FPGA's Quartus Prime software on remote servers
which don't have a web browser or a GUI.  It makes it easy to download
across a number of servers, and to run as part of a scripted build.

Syntax:
```
usage: quartus-install.py [-h] [--download-only] [--install-only] [--prune]
                          version target device [device ...]

Download and install Quartus.

positional arguments (required):
  version          Quartus version, eg 18.0pro, 17.1lite, 16.1std.
                   Supplying an invalid version will return the supported versions.
  target           Directory to install Quartus in
  device           Device to download/install in Quartus.  Supported:
                           a2    Arria II
                           a5    Arria V
                           a5gz  Arria V GZ
                           a10   Arria 10
                           c4    Cyclone IV
                           c5    Cyclone V
                           c10gx Cyclone 10 GX
                           c10lp Cyclone 10 LP
                           m2    MAX II
                           m5    MAX V
                           m10   MAX 10
                           s4    Stratix IV
                           s5    Stratix V
                           s10   Stratix 10
                           dsp   DSP Builder
                           eds   ARM EDS
                           opencl OpenCL toolkit

optional arguments:
  -h, --help       show this help message and exit
  --list-versions  Print the Quartus versions supported
  --list-parts     Print the devices and other pieces we can download
  --download-only  Only download, don't install
  --install-only   Only install, don't download
  --prune          Delete install files when finished
  --nosetup        Don't download Quartus setup frontend
  --parallel PARALLEL, -j PARALLEL
                   Number of parallel download connections
  --fix-libpng     Build and add libpng12.so binary to Quartus library dir
                   (needed for recent Ubuntu among others)
  --check-urls     Check whether the URLs in the database are fetchable
  --foreign        EXPERIMENTAL support for emulating Quartus on aarch64
                   Ubuntu LTS (eg Apple M1 via UTM).  Requires sudo, see
                   below for details.
```

Example usage:
```
quartus-install.py 18.1std /opt/intelFPGA/18.1std a10 s4 s5 c4 c5 m10
```

You will also need the ['aria2'](https://aria2.github.io/) tool installed
(available as a Ubuntu package) to
perform parallel downloads (since the Akamai servers have limited per-file
bandwidth, it is most efficient to download all the pieces in parallel if
you are on a high-bandwidth link).

Please note that installing Quartus implies acceptance of [Intel FPGA's
EULA](http://fpgasoftware.intel.com/eula/) for the appropriate version(s)
you download.

Since it's necessary to extract the URLs manaully from the Intel website,
only a limited set of Quartus versions are supported.  Patches/PRs welcome!

Theo Markettos



Quartus on arm64 / aarch64 / Apple Silicon
------------------------------------------

Quartus has native x86 binaries, and Intel only supplies those for Linux and
Windows.  So people with Arm-based systems, eg modern Macs, are out of luck?
Quartus will run in MacOS where Rosetta would help it, since Rosetta does
work in VMs thanks to UTM ultilized Apple Virtualization framework.  Performance 
in virtualized VM is absolutely awesome.

The `pre-install.sh` script will:
- Install spice-vdagent for clipboard passthrough.
- Mount Rosetta binary and shared folder.
- Setup Rosetta.
- Add support for amd64 architecture to install amd64 packages.

To run the script, you should provide the macOS version as an argument, ensuring
that it is greater than or equal to 13 (because the Virtualization framework first
release on Ventura). Execute the script with sudo privileges:

```
sudo ./pre-install.sh <macOS_version>
```

After the installation, please restart the VM for changes to take effect.

To install Quartus with patches for an aarch64 VM, install Quartus as
above but pass the `--foreign` flag, which will install necessary packages
and patch your install.

Currently, there are issues with installing Quartus on macOS because it relies on some 
instructions that aren't supported by Rosetta, which can cause the `quartus-install.py` 
script to crash after Quartus is installed (before installing devices/QuestaSim). If you 
encounter this problem, you'll need to extract the device `.qdz` files and manually copy 
them to the Quartus folder. And you have to install QuestaSim separately by running the 
`.run` file with the `--mode text` argument. 

Following that, execute the `foreign-pre.sh` script to install the required dependency 
packages. Afterward, run the `foreign-post.sh $QUARTUS_ROOTDIR` script to apply patches 
to the `qenv` within Quartus.

It's possible that this problem will be resolved in future macOS updates when Apple 
includes the necessary instructions.

Caveats:

- This is extremely experimental and fragile.  It is highly likely to break. 
  Assume it's already broken and hope for positive surprises.
- Don't expect build performance to be amazing, but at least you can run
  Quartus (maybe).
- This has been tested with Quartus Lite 20.1.1, Quartus Standard 22.1 (cracked), 
  Quartus Pro 23.1, although in theory it should work for other versions, it may
  need some tweaking (especially Quartus Pro).  Only the main Quartus,
  Platform Designer, and Eclipse have been tested, not all the many other pieces.
- This is only tested on Debian 12 (aarch64).  It will probably work with
  other Ubuntu or Debian versions, but they haven't been tested.  Other
  distros will need to install different packages.
- Some Java parts (eg Platform Designer), Fitting process will spin forever
  if more than one core is available to the VM.  It is suspected this is due
  to a memory ordering difference between x86 (TSO) and Apple Silicon (weak ordering). 
  While M1 can switch into a TSO mode (as it does when Rosetta is running),
  for Quartus Lite it's simpler to limit the VM to one core as it doesn't
  use multicore for builds anyway.  Another option is to edit the wrapper
  scripts for binaries (eg in $QUARTUS_ROOTDIR/bin/) and prefix the
  invocation of the binary (at the bottom) with 'taskset 1 ' to force only
  Quartus binaries to use a single core.  More experimentation needed here -
  it's possible the C++ parts of Quartus may work better multicore than the
  Java parts.  [In case anyone asks, libccl_sqlite3_jdbc_jni_bridge.so uses
  the JNI so we can't just use the aarch64 JVM, as it needs to link with x86
  libraries].
