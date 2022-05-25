### LoongArch32精简版交叉工具链安装说明



**【源码目录结构】** 

```
    la32r_toolchain
           |---src（存放工具链源码）
           |   |---la32r_binutils
           |   |---la32r_gcc-8.3.0
           |   |---la32r-Linux
           |   |---la32r_glibc-2.28
           |---la32r_toolchain_build.sh（交叉工具链制作脚本）
           |---obj（自动生成，存放各阶段构建文件及日志等）
           |---install（自动生成，存放二进制文件）
```

 **【源码获取】（From 龙芯教育）** 

```bash
git submodule init
git submodule update
``` 

 **【准备工作】** 
    
```
安装前需准备工具链可能依赖的gmp/mpc/mpfr/isl源码：
    cd ./src/la32r_gcc-8.3.0
    ./contrib/download_prerequisites
```

 **【安装】** 
```
cd la32r-toolchain
根据实际情况修改脚本中的BUILD_SYSTEM等变量
bash la32r_toolchain_build.sh
```


ABI相关文档可参考：
[LoongArch ELF ABI specification](https://loongson.github.io/LoongArch-Documentation/LoongArch-ELF-ABI-EN.html)
