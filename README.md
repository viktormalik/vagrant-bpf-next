# Vagrant box for kernel (bpf-next) development

The box contains environment necessary for building the
[bpf-next](https://git.kernel.org/pub/scm/linux/kernel/git/bpf/bpf-next.git/)
tree and running the BPF selftests. In particular, it creates a Fedora-based VM
with:
- all necessary dependencies,
- latest pahole built from source,
- latest LLVM built from source.

The bpf-next tree is expected to be checked out at the same level as
(side-by-side to) this repo and it is mounted inside the VM using NFS.

There are several ways to build and run the VM:
- The first `vagrant up` will install the necessary dependencies, except for
  the custom build of LLVM, which takes a long time (LLVM is still installed
  from DNF).
- Use `vagrant provision --provision-with build-llvm` to build latest LLVM.
- Every other `vagrant up`/`vagrant reload` will just check if the bpf-next
  directory contains a newer built kernel and if it does, it will install it.
  The machine is not rebooted by default, though, so it is recommended to run
  `vagrant reload --provision-with kernel-install,reload`.

The setup allows building the kernel in the VM as well as on the host (but
ideally using the same version of Fedora for compatibility of library versions).

The repo also contains some useful files:
- `config.bpf` containing recommended kernel config for the BPF selftests,
- `run_tests.sh` for simple running of the most common tests (with the below
  denylists),
- `<TEST>-denylist` a list of sub-tests from `<TEST>` that currently do not
  pass.

