# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "fedora/39-cloud-base"

  config.vm.provider "libvirt" do |v|
    v.memory = 8192
    v.cpus = 4
  end

  config.vm.synced_folder "../bpf-next", "/bpf-next", type: "nfs", nfs_version: 4, "nfs_udp": false, mount_options: ["rw", "tcp"]
  config.vm.synced_folder "../../../bpf/libbpf-bootstrap", "/libbpf-bootstrap", type: "nfs", nfs_version: 4, "nfs_udp": false, mount_options: ["rw", "tcp"]

  # Create GRUB2 config
  config.vm.provision "grub-cfg", type: "shell", inline: <<-SHELL
    grub2-mkconfig -o /boot/grub2/grub.cfg
  SHELL

  # Install dependencies
  config.vm.provision "install", type: "shell", inline: <<-SHELL
    dnf install -y gcc g++ make cmake git ninja-build clang llvm vim lld bc \
      elfutils-devel binutils-devel libcap-devel python3-docutils \
      openssl-devel iptables-legacy iproute-tc ethtool cargo bpftool gdb \
      llvm-devel clang-devel
  SHELL

  # Boot kernel
  config.vm.provision "kernel-install", type: "shell", run: "always", inline: <<-SHELL
    if ! cmp -s /boot/vmlinuz-$(uname -r) /bpf-next/arch/x86/boot/bzImage; then
      cd /bpf-next
      make headers_install
      make modules_install
      make install
      grubby --set-default /boot/vmlinuz-$(cat include/config/kernel.release)
    fi
  SHELL

  config.vm.provision :reload

  # Build latest pahole
  config.vm.provision "pahole", type: "shell", inline: <<-SHELL
    git clone https://git.kernel.org/pub/scm/devel/pahole/pahole.git
    cd pahole
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_RPATH="/usr/local/lib64" -D__LIB=lib64
    make -j4
    make install
  SHELL

  # Install and build LLVM
  config.vm.provision "build-llvm", type: "shell", run: "never", inline: <<-SHELL
    dnf remove llvm-devel clang-devel
    if [ ! -d llvm-project ]; then
      git clone https://github.com/llvm/llvm-project.git
    fi
    cd llvm-project
    git pull
    mkdir -p llvm/build
    cd llvm/build
    cmake .. -G "Ninja" -DLLVM_TARGETS_TO_BUILD="BPF;X86" \
            -DLLVM_ENABLE_PROJECTS="clang"    \
            -DCMAKE_BUILD_TYPE=Release        \
            -DLLVM_BUILD_RUNTIME=OFF
    ninja -j8
    ninja install
  SHELL
end
