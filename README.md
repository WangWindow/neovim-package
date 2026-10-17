# neovim-package

将 Neovim 官方的 `nvim-linux-x86_64.tar.gz` 重新封装为 Arch Linux
`neovim-bin` pacman 包和 Debian/Ubuntu `neovim-bin` `.deb` 包，不重新编译或
修改上游二进制。

## GitHub Actions

[`.github/workflows/package.yml`](.github/workflows/package.yml) 每周运行一次，
也可以手动触发。它会：

1. 获取 Neovim 最新正式版本。
2. 两种格式均已发布的版本直接跳过；缺少任一格式时会补齐。
3. 下载官方压缩包并生成 `.pkg.tar.zst` 和 `.deb`。
4. 验证两种包并上传到当前仓库的 GitHub Release。

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
sudo apt install ./dist/neovim-bin_*_amd64.deb
```

`.deb` 包提供 `neovim`，并与发行版的 `neovim` / `neovim-runtime` 包冲突，
以避免二进制和运行时文件相互覆盖。
