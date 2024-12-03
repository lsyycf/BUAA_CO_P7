# 一、模块设计

## 模块一：寄存器堆

- 功能同 P0 第三题 GRF

## 模块二：算术逻辑单元

- ALUOp 决定 ALU 进行的运算

## 模块三：取指令模块

- 每个时钟周期上升沿将pcNext赋值给pc
- 将pc的值减去初值0x00003000，作为ROM读取的地址addr
- pc若为0则将pc置为初始值0x00003000，地址置为0

## 模块四：乘除模块

- 进行乘除运算，结果存入内部相应的寄存器
- 通过busy信号对后续指令进行阻塞
- 写使能时，将值写入内部寄存器中
- 根据控制信号，输出内部寄存器地计算结果

##  模块五：控制信号生成器

### （1）D段

- **pcOp**：设置程序计数器的操作。
- **cmpOp**：表示条件跳转比较。
- **extOp**：是否需要扩展符号。
- **regWE**：表示寄存器写使能。
- **MD** ：是否需要使用乘除模块。
- **rtTuse** 和 **rsTuse**：再过几个周期，该指令要使用  rs 或  rt 寄存器的值。
- **eret**：是否是eret指令。
- **delay**：是否是延迟槽指令。
- **syscall**：是否是syscall指令。
- **RI**：不存在的指令。

### （2）E段

- **ALUOp**：决定 ALU 执行的操作。
- **MDOp**：决定 MD 执行的操作。
- **MDWE**：表示HI、LO寄存器写使能。
- **MDAddrOp**：选择读取 MD 中的寄存器。
- **resOp**：选择E段结果来自 ALU 还是 MD。
- **ALUIn2Op**：确定 ALU 第二个输入。
- **fwAddrOp**：选择转发的地址。
- **fwDataOp**：选择转发的数据。
- **Tnew**：表示以D级为基准，再过几个周期，该指令产生所需的结果。
- **mtc0**：是否是mtc0指令。
- **load**：是否是访存型指令。
- **store**：是否是存储型指令。
- **cal**：是否是计算型指令。

### （3）M段

- **memStoreOp**：决定写入主存的数据是字、字节和半字。
- **memLoadOp**：决定主存读出的数据是字、字节和半字。
- **fwAddrOp**：选择转发的地址。
- **fwDataOp**：选择转发的数据。
- **Tnew**：从结果产生到存入流水线寄存器需要几个周期。
- **eret**：是否是eret指令。
- **mtc0**：是否是mtc0指令.
- **mfc0**：是否是mfc0指令。

### （4）W段

- **fwAddrOp**：选择转发的地址。
- **fwDataOp**：选择转发的数据。
- **Tnew**：从结果产生到存入流水线寄存器需要几个周期。

## 模块六：流水线寄存器

- **D段**：存储 pc、指令、异常码、是否是延迟槽指令
- **E段**：存储 pc、指令、rs 和  rt 读出的数据、立即数、是否写入寄存器、异常码、是否是延迟槽指令
- **M段**：存储 pc、指令、rs 和  rt 读出的数据、立即数、ALU 计算结果、是否写入寄存器、异常码、是否是延迟槽指令
- **W段**：存储 pc、指令、rs 和  rt 读出的数据、立即数、ALU 计算结果、主存读出结果、是否写入寄存器

## 模块七：字节/半字/字选择模块

- 根据ALU计算地址的后两位，以及存取指令的类型，决定主存存取的数据

## 模块八：CP0模块

- 放置在M级流水段
- 一方面尽可能多的收集前段的异常，另一方面防止异常数据写回寄存器
- 通过异常码修改三个内部寄存器的值
- 支持内部寄存器的读写操作

| 寄存器           | 功能域           | 位域   | 解释                                                                 |
|------------------|------------------|--------|----------------------------------------------------------------------|
| SR（State Register） | IM（Interrupt Mask） | 15:10  | 分别对应六个外部中断，相应位置 1 表示允许中断，置 0 表示禁止中断。这是一个被动的功能，只能通过 `mtc0` 这个指令修改，通过修改这个功能域，我们可以屏蔽一些中断。 |
| SR（State Register） | EXL（Exception Level） | 1      | 任何异常发生时置位，这会强制进入核心态（也就是进入异常处理程序）并禁止中断。 |
| SR（State Register） | IE（Interrupt Enable） | 0      | 全局中断使能，该位置 1 表示允许中断，置 0 表示禁止中断。              |
| Cause            | BD（Branch Delay）    | 31     | 当该位置 1 的时候，EPC 指向当前指令的前一条指令（一定为跳转），否则指向当前指令。 |
| Cause            | IP（Interrupt Pending） | 15:10  | 为 6 位待决的中断位，分别对应 6 个外部中断，相应位置 1 表示有中断，置 0 表示无中断，将会每个周期被修改一次，修改的内容来自计时器和外部中断。 |
| Cause            | ExcCode           | 6:2    | 异常编码，记录当前发生的是什么异常。                                 |
| EPC              | -                  | -      | 记录异常处理结束后需要返回的 PC。                                      |

## 模块九：桥

- 获取CPU申请访问的地址，读取相应的数据
- 通过地址的区间确定数据位于主存、Timer0、Timer1中

## 模块十：Timer

- 课程组已给出代码
- 两种模式给出模拟中断信号
- 通过地址读写Timer内存

# 二、阻塞与转发

## 1.阻塞

### 条件：
- 读写寄存器冲突
  - Tuse\<Tnew 
  - 需要将后续数据写入寄存器
  - 写入寄存器地址不为0
  - 写入寄存器地址与后续转发地址相同
- 乘除单元使用冲突
  - MD单元处于busy状态
  - 后续指令需要使用MD单元
- eret 指令冲突
  - D段是eret指令
  - E段或M段需要写CP0寄存器


### 行为：
- 停止取下一条指令
- D级寄存器保持原值不变
- E级寄存器复位（延迟槽指令除外）

## 2.转发

###  条件：
- Tnew=0
- 需要将后续数据写入寄存器
- 写入寄存器地址不为0
- 写入寄存器地址与后续转发地址相同

### 通路：
- E段->D段
- M段->D段、E段
- W段->D段、E段、M段

### 内容：
- 转发地址：写入的寄存器
- 转发数据：写入寄存器的内容

# 三、异常

| 中断码 | 助记符与名称 | 指令与指令类型 | 描述 | 收集 |
| ---- | ---- | ---- | ---- | --- |
| 0 | `Int`（外部中断） | 所有指令 | 中断请求，来源于计时器与外部中断。 | - |
| 4 | `AdEL`（取指异常） | 所有指令 | PC 地址未字对齐。<br>PC 地址超过 `0x3000 ~ 0x6ffc`。 | F段 |
| 4 | `AdEL`（取数异常） | `lw` | 取数地址未与 4 字节对齐。 | M段 |
| 4 | `AdEL`（取数异常） | `lh` | 取数地址未与 2 字节对齐。 | M段 |
| 4 | `AdEL`（取数异常） | `lh`，`lb` | 取 Timer 寄存器的值。 | M段 |
| 4 | `AdEL`（取数异常） | load 型指令 | 计算地址时加法溢出。 | E段 |
| 4 | `AdEL`（取数异常） | load 型指令 | 取数地址超出 DM、Timer0、Timer1、中断发生器的范围。 | M段 |
| 5 | `AdES`（存数异常） | `sw` | 存数地址未 4 字节对齐。 | M段 |
| 5 | `AdES`（存数异常） | `sh` | 存数地址未 2 字节对齐。 | M段 |
| 5 | `AdES`（存数异常） | `sh`，`sb` | 存 Timer 寄存器的值。 | M段 |
| 5 | `AdES`（存数异常） | store 型指令 | 计算地址加法溢出。 | E段 |
| 5 | `AdES`（存数异常） | store 型指令 | 向计时器的 Count 寄存器存值。 | M段 |
| 5 | `AdES`（存数异常） | store 型指令 | 存数地址超出 DM、Timer0、Timer1、中断发生器的范围。 | M段 |
| 8 | `Syscall`（系统调用） | `syscall` | 系统调用。 | D段 |
| 10 | `RI`（未知指令） | - | 未知的指令码。 | D段 |
| 12 | `Ov`（溢出异常） | `add`，`addi`，`sub` | 算术溢出。 | E段 |

# 四、思考题

## 问题一、
- Q：请查阅相关资料，说明鼠标和键盘的输入信号是如何被 CPU 知晓的？
- A：鼠标和键盘的输入信号都会转化为不同的系统中断信号，CPU根据中断信号的值可以执行对应的汇编指令，这样就实现了相应鼠标和键盘的功能

## 问题二、
- Q：请思考为什么我们的 CPU 处理中断异常必须是已经指定好的地址？如果你的 CPU 支持用户自定义入口地址，即处理中断异常的程序由用户提供，其还能提供我们所希望的功能吗？如果可以，请说明这样可能会出现什么问题？否则举例说明。（假设用户提供的中断处理程序合法）
- A：必须是已经指定好的地址。处理中断异常程序的目的是维护系统、程序的正常运行，并返回错误信息。如果地址由用户自定义，可能地址无效产生新的异常，达不到目的


## 问题三、
- Q：为何与外设通信需要 Bridge？
- A：一方面，CPU不需要关心具体的数据从何而来，只需通过地址就能获得对应的数据，达到了高内聚低耦合的目的。另一方面，外设种类很多而CPU指令集有限，把外设的接口和CPU的接口通过系统桥连接起来，通过统一的方式，由系统桥选择相关信息的输入输出，使得CPU能够支持各种外设，有更强的拓展性和灵活性

## 问题四、
- Q：请阅读官方提供的定时器源代码，阐述两种中断模式的异同，并分别针对每一种模式绘制状态移图。

- 计数器模式 0
	- 当计数器倒计数为 0 后，计数器停止计数，寄存器的计数使能自动变为 0，中断信号始终保持有效，状态机在中断状态下循环，直到屏蔽中断或重新开始计数
	
- 计数器模式 1
	- 当计数器倒计时为 0 后， 初值寄存器值被自动加载至计数器，然后重新开始计数。在这种模式下，中断信号只会产生一个周期

## 问题五、
- Q：倘若中断信号流入的时候，在检测宏观 PC 的一级如果是一条空泡（你的 CPU 该级所有信息均为空）指令，此时会发生什么问题？在此例基础上请思考：在 P7 中，清空流水线产生的空泡指令应该保留原指令的哪些信息？
- CPU此时不知道应该要进行的操作是什么，在异常处理程序返回时EPC中返回的值为0，导致程序错乱
- 在清空流水线的时候，应该保留被阻塞的当前指令的PC值、判断其是否为延迟槽指令的BD位控制信号

## 问题六、
- Q：为什么 jalr 指令为什么不能写成 jalr \$31, \$31？
- A：因为 \$31 本身用来存储返回地址。如果你将返回地址存储到 \$31 中，并且又用它来确定跳转的目标地址，这样就会产生自引用，导致程序跳转到它自身的地址。进而程序会陷入死循环，或者跳转到错误的地址，破坏了正常的控制流
