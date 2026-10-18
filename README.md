# neovim-package

将 Neovim 官方预编译包重新封装为 Arch Linux `neovim-bin` pacman 包
（x86_64）和 Debian/Ubuntu `neovim-bin` `.deb` 包（amd64、arm64），不重新编译或
修改上游二进制。

## GitHub Actions

[`.github/workflows/package.yml`](.github/workflows/package.yml) 每周运行一次，
也可以手动触发。它会：

1. 获取 Neovim 最新正式版本。
2. 所有目标包均已发布的版本直接跳过；缺少任一格式或架构时会补齐。
3. 下载官方 x86_64 和 arm64 压缩包，生成 Arch x86_64 包及 Debian/Ubuntu amd64、arm64 包。
4. 验证并上传包到当前仓库的 GitHub Release。

首次使用前，请在仓库中启用：

`Settings → Actions → General → Workflow permissions → Read and write permissions`

## 本地打包

### Arch Linux

需要 Arch Linux 和 `base-devel`：

打包示例：
```bash
./scripts/build-package.sh <版本> ./nvim-linux-x86_64.tar.gz ./dist
```

安装生成的包：

```bash
sudo pacman -U ./dist/neovim-bin-*.pkg.tar.zst
```

### Debian / Ubuntu

需要安装 `dpkg-deb`（通常由 `dpkg` 包提供）：

```bash
./scripts/build-deb-package.sh <版本> ./nvim-linux-x86_64.tar.gz ./dist
./scripts/build-deb-package.sh <版本> ./nvim-linux-arm64.tar.gz ./dist
sudo apt install ./dist/neovim-bin_*_amd64.deb # amd64
sudo apt install ./dist/neovim-bin_*_arm64.deb # arm64
```

脚本会根据官方压缩包内的目录结构自动设置 Debian 架构。

`.deb` 包提供 `neovim`，并与发行版的 `neovim` / `neovim-runtime` 包冲突，
以避免二进制和运行时文件相互覆盖。
