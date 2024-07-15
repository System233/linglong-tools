# 玲珑deb转制自动化工具

此工具总结了deb转制法打包玲珑应用中的出现的常见问题，并实现自动化打包。

## 要求&限制

* 依赖库：apt-file
* 仅用于deb转制打包法，因此输入包名为apt仓库中的包名
* 不适用于源码编译打包法的玲珑项目
* 实验性的deb文件输入支持 ~~暂不支持直接使用本地deb文件输入，没有做这个处理。~~

## 常规使用方法

0. 脚本放置到`~/.local/bin`,设置可执行权限,执行`setup-pkg-env.sh`将目录配置到`.bashrc`
1. 先用`pkg-build.sh 包名`构建项目
2. 进入项目目录，先用`llr`测试启动，如不正常再使用llre在容器内部测试应用
3. 测试好参数后，按需在项目目录下创建`env.sh`、`build.sh`、`start.sh`和`post.sh`，添加自定义指令，使用`llb`重新构建，过程中在各个构建阶段自动调用这些文件（若有）。
4. `llr`再次测试，正常后`lle`打包安装测试。

## 功能

常用命令列表

注：[xxx] 参数为可选
## 环境变量配置
* NO_RT_ENV：此项目未使用玲珑Runtime依赖，linglong.yaml内未指定runtime时或生成项目前手动设置。
* TARGET_ARCH：此项目的架构，自动检测，默认amd64

### 项目构建类
* [pkg-build.sh](pkg-build.sh) [包名/deb文件]
    * 在当前目录下自动生成玲珑项目并构建，有包名时在包名目录下构建，没有传递包名时以当前目录作为项目文件夹构建（文件夹名为包名）
    * 自动转换deb应用到linyaps玲珑包
    * 自动解析版本号
    * 自动解析描述
    * 集中deb包存储
    * 自动补丁和修复环境：QT、GTK、PYTHON、MONO
* [pkg-build-all.sh](pkg-build-all.sh)  包名1 包名2...
    * 用法：pkg-build-all.sh 包名1 包名2...
    * 在当前目录下构建参数列出的全部包
* [pkg-build-temp.sh](pkg-build-temp.sh)
    * 由`pkg-build.sh`生成的`linglong.yaml`在构建时调用，无需手动调用。
    * 玲珑工程构建过程调用的通用构建脚本，内含所有文件、配置和补丁的处理方法。
    * 参数通过环境变量配置

* [pkg-install.sh](pkg-install.sh) [包名]
    * 安装指定的包名，或以当前目录的项目
* [pkg-clear.sh](pkg-clear.sh)
    * 删除当前目录下所有项目的AppDir(应用deb解压后的文件，不含依赖)、linglong文件夹和packages依赖文件夹，清理空间。
* [pkg-export.sh](pkg-export.sh)
    * 导出当前项目的layer文件到脚本中写死的`EXPORT_DIR`目录，并自动清理
* [pkg-export-desktop.sh](pkg-export-desktop.sh)
    * 启动后，拖动测试好的玲珑应用快捷方式到终端并回车，自动导出layer并卸载此应用。

### 依赖相关
* [pkg-fuck-deps.sh](pkg-fuck-deps.sh) [库名]
    * 补全依赖后仍然出现缺依赖库时使用，自动搜索错误信息中的库以及ldd筛选的库，并自动添加依赖。
    * 可以指定要补全其依赖的程序
* [list-deps.sh](list-deps.sh) 包名/deb文件...
    * 列出指定包名的全部依赖列表
* [diff-deps.sh](diff-deps.sh) 包名/deb文件...
    * 列出指定包名的排除[玲珑内置依赖(env.deps)](env.deps)后的依赖列表
* [pull-deps.sh](pull-deps.sh)
    * 拉取当前项目的依赖
* [pkg-search.sh](pkg-search.sh)
    * 通过库文件名搜索所在包名
### 故障排查
* [strace.sh](strace.sh) 可执行文件 参数...
    * 玲珑容器内调用的strace命令

### 安装工具
* [setup-pkg-env.sh](setup-pkg-env.sh)
    * 添加~/.local/bin到PATH
    * 添加玲珑相关命令别名
```
alias "llb=ll-builder build"
alias "llr=ll-builder run"
alias "llbe=ll-builder build --exec bash"
alias "llre=ll-builder run --exec bash"

alias "lle=ll-builder export"

alias "llcr=ll-cli run"
alias "llci=ll-cli install"
alias "llcu=ll-cli uninstall"
alias "llcl=ll-cli list"
alias "llcp=ll-cli ps"
```

### deb
* [deb-repack.sh](deb-repack.sh)
    * 未经测试
    * 转换zstd包到普通xz
    * PS: zst的包比xz还大一大截，真是更新了个寂寞



## 构建脚本环境变量

环境变量在`linglong.yaml`、和项目路径下的`env.sh`(自行按需创建)中配置。

* F_STARTUP: 自动检测的应用启动文件
* F_VER: 自动检测的应用版本号
* PKG_NAME: 目标原始应用包名
* LINGLONG_PKG_NAME: 目标玲珑包名
* CWD: 应用启动目录,默认为`F_EXEC`所在目录,生成为start.sh中的cd指令
* F_DIR: 应用启动文件所在目录
* F_EXEC: 已修正路径的启动文件所在位置
* F_EXEC_RAW: 原始desktop中Exec指定的启动文件位置
* F_ARGS：手动额外添加的启动参数
* NO_GAMES: 不添加games到PATH环境变量
* NO_TERM: 不添加TERM=xterm-256color环境变量
* NO_LDPATH: 不自动搜索并设置LD_LIBRARY_PATH环境变量
* NO_MONO: 禁用MONO补丁
* NO_GLIB: 禁用GLIB补丁
* NO_JAVA: 禁用JAVA补丁
* NO_PREL: 禁用PERL补丁
* SETUP_QPA: 启用QPA补丁
* SHELL_BIN：解释器路径，如`python3`，覆盖#! shebang的行为。
* NO_PATCH_EXEC: 禁用shebang补丁
* NO_FIX_SYM: 禁用相对符号链接转绝对符号链接补丁
* NO_LINK: 禁用启动时符号链接补丁

## 可插入的构建流程

项目文件夹下按需手动创建文件，构建脚本检测到会自动调用

* env.sh: 构建脚本执行前设置环境变量
* build.sh: 构建脚本生成start.sh入口文件、打补丁之前修改项目文件
* start.sh: 构建脚本生成start.sh时，将标准输出作为自定义的指令插入生成的启动脚本（如 echo export A=B插入指令export A=B）。
* post.sh：构建脚本结束时调用，用于各种补丁打完之后再修改项目文件。


## 默认文件路径

* 全局deb包存储：~/.packages
* 脚本路径：~/.local/bin
* 导出命令的layer存放路径：/media/sf_VMShared

## 自带的文件补丁
* libjack.so.0.1.0
* libjackserver.so.0.1.0
* libwebkit2gtk-4.0.so.37

## 依赖配置文件

* env.rt.deps: 玲珑容器带runtime依赖列表
* env.nrt.deps: 玲珑容器无runtime依赖列表
* repl.deps: 包名替换表，有时依赖的虚拟包名无法通过apt download下载，或者需要屏蔽某些依赖时使用
