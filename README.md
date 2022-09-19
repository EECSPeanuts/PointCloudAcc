
# User guide
- 参考[教程](https://docs.github.com/cn/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)，编辑readme.md。

- 参考这个[教程](https://developer.aliyun.com/article/604633)，把自己的修改提交到此源仓库的master分支。
！注意，只上传源文件如代码和脚本，不要上传生成文件和大文件(>1M)
  - 检查是否包含大于1M的文件的linux命令：find ./ -type f -size +1M -printf '%s %p\n' | sort -r
  - 提交的格式参考 [教程](https://www.cnblogs.com/daysme/p/7722474.html); 
    - 简化格式是<type是操作的类型>(<scope是操作的对象>): <subject是具体操作的描述> (例如feat(hardware/pool.v): add a arb_fifo module))
  

- verilog设计编程风格
  - **[Verilog代码命名六大黄金规则](https://mp.weixin.qq.com/s/oWlD29XnpDYwF3h5qvGI_Q)**
  - module文件格式参考[template.v](hardware/src/primitives/template/template.v)
  - 整体参考[Verilog编程艺术](./hardware/docs/tutorial/0-Verilog编程艺术_compressed.pdf)
  - 备用参考
    - verilog项目参考[DnnWeaver开源AI加速器](https://github.com/zhouchch3/DNNWeaver/tree/master/hsharma35-dnnweaver.public/hsharma35-dnnweaver.public-6be20110b751/fpga/hardware/source)
    - 完整详细代码编写说明参考[Verilog/SystemVerilog 设计编码风格指南](https://verilogcodingstyle.readthedocs.io/en/latest/index.html)
- verilog模块库位于[primitives](/hardware/src/primitives)

# 分工及目录
- spec文档位于hardware/docs/02-spec/；里面的readme.md是说明文档，.excalidraw文件是硬件框图，下载之后用[网站](https://excalidraw.com/)打开，修改后上传并同步到源仓库；
- 源代码位于/hardware/src/；
- 仿真脚本位于/hardware/sim/;
- 验证C 代码位于/hardware/vrf;

|  | 负责 | 目录 | 时间表 |
| ---- | ---- | ---- |---- |
|  | 脉动阵列 |  | |
|  | 池化模块 | |9.24 写RTL, 9.30仿真通过，10. 15 C model自动对比，合系统，10.30前验证完成确实设计 |
|  | 构建模块 | |9.24 写RTL, 9.30仿真通过，10. 15 C model自动对比，合系统 |
|  | 适配硬件的算法 | 文档位于software/PointNeXt/readme.md | 9.24前，确定用于跑硬件的网络结构位宽；9.30前提取出硬件输入数据，10.10前自动生成输入数据脚本 |
|  | 综合及后端 | 文档位于hardware/work/readme.md，脚本位于 hardware/work/syn/；库及生成文件位于hardware/project/ | 10.5初步总体综合，10.15总体综合，11.1第一版后端，11.15终版后端|


