# neovim-package

将 Neovim 官方的 `nvim-linux-x86_64.tar.gz` 重新封装为 Arch Linux
`neovim-bin` pacman 包，不重新编译或修改上游二进制。

## GitHub Actions

[`.github/workflows/package.yml`](.github/workflows/package.yml) 每 6 小时运行一次，
也可以手动触发。它会：

1. 获取 Neovim 最新正式版本。
2. 已打包的版本直接跳过。
3. 下载官方压缩包并生成 `.pkg.tar.zst`。
4. 将包上传到当前仓库的 GitHub Release。

首次使用前，请在仓库中启用：

`Settings → Actions → General → Workflow permissions → Read and write permissions`

## 本地打包

需要 Arch Linux 和 `base-devel`：

```bash
./scripts/build-package.sh <版本> ./nvim-linux-x86_64.tar.gz ./dist
```

例如：

```bash
./scripts/build-package.sh v0.12.2 ./nvim-linux-x86_64.tar.gz ./dist
```

安装生成的包：

```bash
sudo pacman -U ./dist/neovim-bin-*.pkg.tar.zst
```
