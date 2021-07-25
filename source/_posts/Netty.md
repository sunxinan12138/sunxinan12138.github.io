---
title: Netty
author: 熙男
date: 2021-07-25 16:42:44
categories:
tags:
---

# Netty

Netty是一个由JBoss提供的java开源框架,

Netty是一个异步的, 基于事件驱动的网络应用框架, 用于快速开发高性能, 高可用的网络IO程序.

Netty主要针对在TCP协议下, 面向client端的高并发应用, 或者Peer-to-Peer场景下的大量数据持续传输应用.

Netty 主要基于NIO

- ## 四种IO

> netty 是基于 NIO 那先简单介绍一下IO

#### IO模型

1. I/O模型: 简单理解就是用什么方式进行数据的发送和接收, 决定了通信的性能
2. 三种IO模型:

#### BIO(同步并阻塞)

一个连接创建一个线程, 客户端有连接请求时服务器端就需要启动一个线程处理, 如果连接不进行操作还会造成**不必要的开销**



![BIO](https://i.loli.net/2020/08/25/Ttdh36PEOjWy2vC.png)

**BIO**



- BIO例子





java

```java
import java.io.IOException;
import java.io.InputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MainDemo {
    void serverBIo() throws IOException {
        Socket accept = null;
        ExecutorService executorService = Executors.newCachedThreadPool();
        ServerSocket socket = new ServerSocket(9999);
        System.out.println("lianjie...");

        // 循环链接
        while (true) {
            accept = socket.accept();
            Socket finalAccept = accept;
            executorService.submit(() -> {
                handler(finalAccept);
            });
        }

    }

    private void returnMsg(Socket finalAccept, String s) throws IOException {
        System.out.println("return");
        OutputStream outputStream = finalAccept.getOutputStream();
        outputStream.write(s.getBytes());
        outputStream.flush();
        //  outputStream.close();
    }

    private void handler(Socket accept) {
        byte[] bytes = new byte[1024];
        InputStream stream = null;
        String s = "";
        try {
            stream = accept.getInputStream();
            System.out.println("in");
            while (true) {
                int i = stream.read(bytes);
                s = new String(bytes) + ":::" + Thread.currentThread().getName();
                if (i != -1) System.out.println(s);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                stream.close();
                returnMsg(accept, s);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) {
        MainDemo server = new MainDemo();
        try {
            server.serverBIo();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

**缺点:**

- 需要独立的线程 并发大时 ==需要大量的线程进行处理== 并且 如果没有读写操作 线程会阻塞在Read上 造成资源浪费

#### NIO(同步非阻塞)

和BIO相比 实现了一个**多路复用**的功能 服务器可以用一个线程处理多个连接, 多路复用器进行轮询如果有IO请求就处理



![NIO](https://i.loli.net/2020/08/25/LQHDTZR8NGntb76.png)

**NIO**



> 三大核心: Selector Channel Buffer

具体方式:



![image-20200825235215229](file:///C:/%5CUsers%5C25778%5CAppData%5CRoaming%5CTypora%5Ctypora-user-images%5Cimage-20200825235215229.png)

**image-20200825235215229**



NIO的通讯:

- 客户端





java

```java
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Scanner;
import java.util.Set;

public class GroupChatClient {
    private final String HOST = "127.0.0.1"; //服务器地址
    private int PORT = 6667; //服务器端口
    private Selector selector;
    private SocketChannel socketChannel;
    private String userName;

    public GroupChatClient() throws IOException {
        //得到选择器
        selector = Selector.open();
        //连接远程服务器
        socketChannel = SocketChannel.open(new InetSocketAddress("127.0.0.1", PORT));
        //设置非阻塞
        socketChannel.configureBlocking(false);
        //注册选择器并设置为 read
        socketChannel.register(selector, SelectionKey.OP_READ);
        //得到客户端 IP 地址和端口信息，作为聊天用户名使用
        userName = socketChannel.getLocalAddress().toString().substring(1);
        System.out.println(userName + " is ok ~");
    }

    //向服务器端发送数据
    public void sendInfo(String info) throws Exception {
        //如果控制台输入 exit 就关闭通道，结束聊天
        if (info.equalsIgnoreCase("exit")) {
            socketChannel.write(ByteBuffer.wrap(info.getBytes()));
            socketChannel.close();
            socketChannel = null;
            return;
        }
        info = userName + " 说: " + info;
        try {
            //往通道中写数据
            socketChannel.write(ByteBuffer.wrap(info.getBytes()));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    //从服务器端接收数据
    public void readInfo() {
        try {
            int readyChannels = selector.select();
            if (readyChannels > 0) { //有可用通道
                Set selectedKeys = selector.selectedKeys();
                Iterator keyIterator = selectedKeys.iterator();
                while (keyIterator.hasNext()) {
                    SelectionKey sk = (SelectionKey) keyIterator.next();
                    if (sk.isReadable()) {
                        //得到关联的通道
                        SocketChannel sc = (SocketChannel) sk.channel();
                        //得到一个缓冲区
                        ByteBuffer buff = ByteBuffer.allocate(1024);
                        //读取数据并存储到缓冲区
                        sc.read(buff);
                        //把缓冲区数据转换成字符串
                        String msg = new String(buff.array());
                        System.out.println(msg.trim());
                    }
                    keyIterator.remove(); //删除当前 SelectionKey，防止重复处理
                }
            } else {
                //会检测到没有可用的channel ，可以退出
                System.out.println("没有可用channel ...");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) throws Exception  {
        //创建一个聊天客户端对象
        GroupChatClient chatClient = new GroupChatClient();
        new Thread() { //单独开一个线程不断的接收服务器端广播的数据
            public void run() {
                while (true) {
                    chatClient.readInfo();
                    try { //间隔 3 秒
                        Thread.currentThread().sleep(3000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        }.start();

        Scanner scanner = new Scanner(System.in);
        //在控制台输入数据并发送到服务器端
        while (scanner.hasNextLine()) {
            String msg = scanner.nextLine();
            chatClient.sendInfo(msg.trim());
        }
    }
}
```

- 服务端





java

```java
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.*;
import java.text.SimpleDateFormat;
import java.util.Iterator;


public class GroupChatServer {
    private Selector selector;
    private ServerSocketChannel listenerChannel;
    private static final int PORT = 6667; //服务器端口

    public GroupChatServer() {
        try {
            // 得到选择器
            selector = Selector.open();
            // 打开监听通道
            listenerChannel = ServerSocketChannel.open();
            // 绑定端口
            listenerChannel.socket().bind(new InetSocketAddress(PORT));
            // 设置为非阻塞模式
            listenerChannel.configureBlocking(false);
            // 将选择器绑定到监听通道并监听 accept 事件
            listenerChannel.register(selector, SelectionKey.OP_ACCEPT);
            printInfo("服务器 ok.......");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void listen() {
        try {
            while (true) { //不停轮询
                int count = selector.select();//获取就绪 channel
                if (count > 0) {
                    Iterator<SelectionKey> iterator = selector.selectedKeys().iterator();
                    while (iterator.hasNext()) {
                        SelectionKey key = iterator.next();
                        // 监听到 accept
                        if (key.isAcceptable()) {
                            SocketChannel sc = listenerChannel.accept();
                            //非阻塞模式
                            sc.configureBlocking(false);
                            //注册到选择器上并监听 read
                            sc.register(selector, SelectionKey.OP_READ);

                            //System.out.println(sc.getRemoteAddress().toString().substring(1) + "online ...");
                            System.out.println(sc.socket().getRemoteSocketAddress().toString().substring(1) + " 上线 ...");
                            //将此对应的 channel 设置为 accept,接着准备接受其他客户端请求
                            key.interestOps(SelectionKey.OP_ACCEPT);
                        }
                        //监听到 read
                        if (key.isReadable()) {
                            readData(key); //读取客户端发来的数据
                        }
                        //一定要把当前 key 删掉，防止重复处理
                        iterator.remove();
                    }
                } else {
                    System.out.println("waitting ...");
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void readData(SelectionKey key) {
        SocketChannel channel = null;
        try {
            // 得到关联的通道
            channel = (SocketChannel) key.channel();
            //设置 buffer 缓冲区
            ByteBuffer buffer = ByteBuffer.allocate(1024);
            //从通道中读取数据并存储到缓冲区中
            int count = channel.read(buffer);
            //如果读取到了数据
            if (count > 0) {
                //把缓冲区数据转换为字符串
                String msg = new String(buffer.array());

                printInfo(msg);
                //将关联的 channel 设置为 read，继续准备接受数据
                key.interestOps(SelectionKey.OP_READ);
                sendInfoToOtherClients(channel, msg); //向所有客户端广播数据
            }
            buffer.clear();
        } catch (IOException e) {
            try {
                //当客户端关闭 channel 时，进行异常如理
                //printInfo(channel.getRemoteAddress().toString().substring(1) + "offline...");
                printInfo(channel.socket().getRemoteSocketAddress().toString().substring(1) + " 离线了 ...");
                key.cancel(); //取消注册
                channel.close(); //关闭通道
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        }
    }

    public void sendInfoToOtherClients(SocketChannel except, String msg) throws IOException {
        System.out.println("服务器进行消息转发 ...");
        //转发数据到所有的 SocketChannel 中
        for (SelectionKey key : selector.keys()) {
            Channel targetchannel = key.channel();
            //排除自身
            if (targetchannel instanceof SocketChannel && targetchannel != except) {
                SocketChannel dest = (SocketChannel) targetchannel;
                //把数据存储到缓冲区中
                ByteBuffer buffer = ByteBuffer.wrap(msg.getBytes());
                //往通道中写数据
                dest.write(buffer);
            }
        }
    }

    private void printInfo(String str) { //显示消息

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        System.out.println("服务器接收到消息 时间: [" + sdf.format(new java.util.Date()) + "] -> " + str);
    }

    public static void main(String[] args) {
        GroupChatServer server = new GroupChatServer();
        server.listen();
    }
}
```

- [细节的NIO在这](https://sunxinan12138.github.io/2020/10/02/netty/#)

#### AIO(异步非阻塞)一般用于长稳定的连接

## Reactor模式

### 什么是Reactor

wiki上reactor的解释

- The reactor design pattern is an event handling pattern for handling service requests delivered concurrently to a service handler by one or more inputs. The service handler then demultiplexes the incoming requests and dispatches them synchronously to the associated request handlers.
- 说人话就是来处理一个或者多个输入请求的事件处理模式(基于事件驱动). 采用IO复用监听事件
- 服务器端将传入的请求分派到相应的线程进行处理所以也是Dispatcher模式

> 先看一下传统的模型:



![image.png](https://i.loli.net/2020/09/10/8nVLgUWyYIswPbD.png)

**image.png**



**问题分析**

1. 当并发数很大，就会创建大量的线程，占用很大系统资源
2. 连接创建后，如果当前线程暂时没有数据可读，该线程会阻塞在read 操作，造成线程资源浪费

> Reactor模型(IO复用)



![image.png](https://i.loli.net/2020/09/10/yTOxXHjq3LoAdCP.png)

**image.png**



1. Reactor 模式，通过一个或多个输入同时传递给**服务处理器**的模式(基于事件驱动)
2. 服务器端程序处理传入的多个请求,并将它们同步分派到相应的处理线程， 因此Reactor模式也叫 Dispatcher模式
3. Reactor 模式使用IO复用监听事件, 收到事件后，分发给某个线程(进程), 这点就是网络服务器高并发处理关键

### 三种reactor实现

> 单reactor单线程实现方式

![单线程](https://i.loli.net/2020/10/18/6McxaiBhpH218Xw.png)

**单线程**

- select：通过一个阻塞对象监听多路连接请求
- 实现流程：

客户端的请求由Reactor中的select监听请求类型 :

1. 建立连接（Accept来创建handler对象处理业务）2. 其他请求由handler来处理

- 因为是的单线程所以请求多或者业务处理耗时很大时还是会发生**阻塞**情况

> 单reactor多线程



![多线程](https://i.loli.net/2020/10/18/5l9JyYQf6Tu2Hoc.png)

**多线程**



- 流程：

还是由reactor监听分发 但是handler**不做业务处理只作事件的响应** 分发给对应的worker线程池中的worker来处理(可以继续响应消息), worker返回结果由handler发送回客户端

- 由于业务在线程池中处理 性能高于单线程 但是多线程的数据处理很麻烦 而且reactor是在单线程情况下 还是会有性能瓶颈的

> 主从reactor



![主从reactor](https://i.loli.net/2020/10/18/fAW4twYm7JOXiHg.png)

**主从reactor**



- 我们可以让 Reactor 在多线程中运行
- reactor的主线程监听到消息由MainReactor分发 并且只是处理连接(Accept)请求
- 其他的请求分发到子Reactor(SubReactor), SubReactor处理客户端(除连接)的请求,并且等待worker线程处理结果发回客户端
- 主线可以对应多个子线程 每个子线程可以对应多个worker线程

**Scalable** **IO in** **Java** 对 **Multiple** **Reactors** 的原理图解：



![image.png](https://i.loli.net/2020/10/18/D6uZxUe9aM2lAH3.png)

**image.png**



**主从reactor的优点**

1. 父线程与子线程的数据交互简单职责明确，父线程只需要接收新连接，子线程完成后续的业务处理。
2. 父线程与子线程的数据交互简单，Reactor 主线程只需要把新连接传给子线程，子线程无需返回数据。

## Netty模型

上面说了主从reactor Netty是一个主从多线程模型的支持

### netty模型简单介绍

和reactor的主从模型很像 在此基础上实现了多个”Reactor”



![netty](https://i.loli.net/2020/10/18/Zxitv1FETIgbhQA.png)

**netty**





![netty模型](https://i.loli.net/2020/10/18/oHSMmUwI83rt6lp.png)

**netty模型**



### netty详细模型



![image.png](https://i.loli.net/2021/01/23/xFJ7CIuD2P1defG.png)

**image.png**



### 客户端-服务端实现（Netty的TCP实现）





java

```java
// 服务
/**
 * @author SunJusong
 * @date 2020年 11月08日 21:24:31
 */
public class NettyServer {
    public static void main(String[] args) throws InterruptedException {
        /**
         * step:
         *      1. 创建一个线程组：接收客户端连接
         *      2. 创建一个线程组：处理网络操作
         *      3. 创建服务端启动助手，配置参数
         *          1. 设置两个线程组
         *          2. 使用NioServerSocketChannel作为服务器端通道的实现
         *          3. 设置线程队列中等待的连接个数
         *          4. 保持活动连接状态
         *          5. 向PipleLine中添加handler
         *     4. 绑定端口bind
         *     5. 记得关闭连接
         */
        // 1
        NioEventLoopGroup bossGroup = new NioEventLoopGroup();
        NioEventLoopGroup workGroup = new NioEventLoopGroup();

        ServerBootstrap bootstrap = new ServerBootstrap();
        bootstrap.group(bossGroup, workGroup)
                .channel(NioServerSocketChannel.class)
                .option(ChannelOption.SO_BACKLOG, 128)
                .childOption(ChannelOption.SO_KEEPALIVE, true)
                .childHandler(new ChannelInitializer<SocketChannel>() {
                    @Override
                    protected void initChannel(SocketChannel socketChannel) throws Exception {
                        System.out.println("init...");
                        socketChannel.pipeline().addLast(new NettyServerHandler());
                    }
                });
        ChannelFuture channelFuture = bootstrap.bind(6668).sync();
        System.out.println("server is ready...");

        channelFuture.channel().closeFuture().sync();
        bossGroup.shutdownGracefully();
        workGroup.shutdownGracefully();
    }
}
// ----------------------------------------------------------------------------------
/**
 * 自定义handler
 *
 * @author SunJusong
 * @date 2020年 11月22日 18:44:08
 */
public class NettyServerHandler extends ChannelInboundHandlerAdapter {
    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
        System.out.println("Server:" + ctx);
        ByteBuf buf = (ByteBuf) msg;
        System.out.println("客户端发来的消息：" + buf.toString(CharsetUtil.UTF_8));
    }

    @Override
    public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
        System.out.println("服务端发送");
        ctx.writeAndFlush(Unpooled.copiedBuffer("服务端发：hello client(>^ω^<)喵123123", CharsetUtil.UTF_8));
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        ctx.close();
    }
}
```





java

```java
// 客户
public class NettyClient {
    public static void main(String[] args) throws InterruptedException {
        /**
         *  step:
         *      1. 创建线程组
         *      2. 创建客户端启动助手，以及配置
         *          1. 设置线程组
         *          2. 设置客户端通道实现类
         *          3. 创建通道初始化
         *          4. 网Pipeline中加入handler
         *      3. 启动客户端
         *      4. 关闭
         */

        EventLoopGroup group = new NioEventLoopGroup();
        Bootstrap bootstrap = new Bootstrap();
        bootstrap.group(group)
                .channel(NioSocketChannel.class)
                .handler(new ChannelInitializer<SocketChannel>() {
                    @Override
                    protected void initChannel(SocketChannel socketChannel) throws Exception {
                        System.out.println("init kehu");
                        socketChannel.pipeline().addLast(new NettyClientHandler());
                    }
                });
        System.out.println("client is ready");
        ChannelFuture sync = bootstrap.connect("127.0.0.1", 6668).sync();

        sync.channel().closeFuture().sync();
    }
}
// ----------------------------------------------------------------------------------
public class NettyClientHandler extends ChannelInboundHandlerAdapter {
    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        super.channelActive(ctx);
        ctx.writeAndFlush(Unpooled.copiedBuffer("hello  clientHandler", CharsetUtil.UTF_8));
    }

    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
        super.channelRead(ctx, msg);
        ByteBuf buf = (ByteBuf) msg;
        System.out.println("服务端接收到的是：" + buf.toString(CharsetUtil.UTF_8));
    }
}
```

### 任务队列 - TaskQueue

当很耗时的任务在PipeLine中可以将这个任务异步到处理队列（TaskQueue）

**使用场景：**

1. 用户程序自定义普通任务





java

```java
ctx.channel().eventLoop().execute(new Runnable().run);
```

1. 用户自定义定时任务 - ScheduleTaskQueue





java

```java
ctx.channel().eventLoop().schedule(() -> {}, 5, TimeUnit.HOURS);
```

1. 非当前Reaactor线程调用Channel的方法

   推送系统：根据客户的标识，找到Channel引用，调用Write类方法向用户推送消息，就会进入到这种场景里面，Write会提交到任务队列中被异步消费。

> 对上述方案说明
>
> 1. Netty抽象出两组**线程池**， BossGroup站门负责接收客户端的连接，WorkGroup负责网络的读写。
> 2. NioEventLoop表示一个不断循环执行处理任务的线程，每个NioEventLoop有一个select，用于监听绑定在socket上的网联络通道。
> 3. NioEventLoop采用串行设计。(读取->解码->编码->发送)。
>
> - NioEventLoopGroup下有多个NioEventLoop
> - 每个NioEventLoop中包含一个Select，一个NioChannel
> - 每个NioChannel只会绑定在唯一的NioEventLoop上，并且都有自己的一个ChannelPipeline

### 异步操作

- Listen_result(不需要等待)，Bind，Write，Connect都是异步监听操作。返回一个ChannelFuture用来监听
- 调用时不会立即有结果，通过Future-Listener机制，用户可以主动获取。
- Netty的异步模型在future（Future-Listener机制体现）和callback（回调）之上。

==链式模型==



![image.png](https://i.loli.net/2021/01/24/tvCHJ6eaBhD285M.png)

**image.png**



==Future-Listener机制==

1. 当Future对象创建时，处于非完成状态，返回一个ChannelFuture获取操作的状态，注册监听函数来执行完成后的操作。
2. - isDone / isSuccess / getCause / ……操作





java

```java
// 获取链接的状态
serverBootstrap.bind(port).addListener(future -> {
       if(future.isSuccess()) {
           System.out.println(newDate() + ": 端口["+ port + "]绑定成功!");
       } else{
           System.err.println("端口["+ port + "]绑定失败!");
       }
   });
```

## Http 服务





java

```java
// 服务端
public class TestServer {
    public static void main(String[] args) throws  Exception{
        /**
         * 事件循环组，就是死循环
         */
        //仅仅接受连接，转给workerGroup，自己不做处理
        EventLoopGroup bossGroup=new NioEventLoopGroup();
        //真正处理
        EventLoopGroup workerGroup=new NioEventLoopGroup();
        try {
            //很轻松的启动服务端代码
            ServerBootstrap serverBootstrap=new ServerBootstrap();
            //childHandler子处理器,传入一个初始化器参数TestServerInitializer（这里是自定义）
            //TestServerInitializer在channel被注册时，就会创建调用
            serverBootstrap.group(bossGroup,workerGroup).channel(NioServerSocketChannel.class).
                    childHandler(new TestServerInitializer());
            //绑定一个端口并且同步，生成一个ChannelFuture对象
            ChannelFuture channelFuture=serverBootstrap.bind(6668).sync();
            //对关闭的监听
            channelFuture.channel().closeFuture().sync();
        }
        finally {
            //循环组优雅关闭
            bossGroup.shutdownGracefully();
            workerGroup.shutdownGracefully();
        }
    }
}
```





java

```java
// 注册方法
public class TestServerInitializer extends ChannelInitializer<SocketChannel> {
    //这是一个回调的方法，在channel被注册时被调用
    @Override
    protected void initChannel(SocketChannel ch) throws Exception {
        //一个管道，里面有很多ChannelHandler，这些就像拦截器，可以做很多事
        ChannelPipeline pipeline=ch.pipeline();
        //增加一个处理器，neety提供的.名字默认会给，但还是自己写一个比较好
        /**
         * 注意这些new的对象都是多例的，每次new出来新的对象,因为每个连接的都是不同的用户
         */
        //HttpServerCodec完成http编解码，可查源码
        pipeline.addLast("httpServerCodec",new HttpServerCodec());
        //增加一个自己定义的处理器hander
        pipeline.addLast("testHttpServerHandler",new TestHttpServerHandler());
    }
}
```





java

```java
/**
 * 继承InboundHandler类，代表处理进入的请求，还有OutboundHandler,处理出去请求
 * 其中里面的泛型表示msg的类型，如果指定了HttpObject，表明相互通讯的数据被封装成HttpObject
 */
public class TestHttpServerHandler extends SimpleChannelInboundHandler<HttpObject> {
    int count = 4; // 通过这个可以看到在服务器 每一个客户端对应一个 独立的handler
    //channelRead0读取客户端请求，并返回响应的方法
    @Override
    protected void channelRead0(ChannelHandlerContext ctx, HttpObject msg) throws Exception {
        //如果不加这个判断使用curl 测试会报错，使用curl测试命令curl "http://localhost:8899"
        //判断这个是不是httprequest请求
        if (msg instanceof HttpRequest) {
            System.out.println(msg.getClass());
            System.out.println(ctx.channel().remoteAddress());
            HttpRequest httpRequest= (HttpRequest) msg;
            URI uri=new URI(httpRequest.uri());
            //判断url是否请求了favicon.ico, 可以不对此请求响应
//            if ("/favicon.ico".equals(uri.getPath())){
//                System.out.println("请求了favicon.ico");
//                return;
//            }
            /**
             * 上面这段代码是验证如果用浏览器访问
             * chrome浏览器发起了两次请求，一次是发起的端口，第二次是请求/favicon.ico图标
             * 具体可以查看360 浏览器的请求
             */
            System.out.println("请求方法名:"+httpRequest.method().name());
            //ByteBuf,neety中极为重要的概念，代表响应返回的数据
            ByteBuf content = Unpooled.copiedBuffer("Hello! 我是服务器" + (++count), CharsetUtil.UTF_8);
            //构造一个http响应,HttpVersion.HTTP_1_1:采用http1.1协议，HttpResponseStatus.OK：状态码200
            FullHttpResponse response = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1,
                    HttpResponseStatus.OK, content);
            response.headers().set(HttpHeaderNames.CONTENT_TYPE, "text/plain");
            response.headers().set(HttpHeaderNames.CONTENT_LENGTH, content.readableBytes());
            //如果只是调用write方法，他仅仅是存在缓冲区里，并不会返回客户端
            //调用writeAndFlush可以
            ctx.writeAndFlush(response);
        }
    }

    /**
     * 处理顺序如下：
     * handlerAdded
     * channelRegistered
     * channelActive
     * 请求方法名:GET（channelRead0）
     * （下面的表示的是断开连接后）
     * 1.如果是使用curl ：连接会立刻关闭
     * 2.如果是浏览器访问，http1.0：它是短连接，会立刻关闭。http1.1，是长连接，连接保持一段时间
     * channelInactive
     * channelUnregistered
     * @param ctx
     * @throws Exception
     */
    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        System.out.println("channelActive");
        super.channelActive(ctx);
    }

    @Override
    public void channelRegistered(ChannelHandlerContext ctx) throws Exception {
        System.out.println("channelRegistered");
        super.channelRegistered(ctx);
    }
    @Override
    public void handlerAdded(ChannelHandlerContext ctx) throws Exception {
        System.out.println("handlerAdded");
        super.handlerAdded(ctx);
    }
    @Override
    public void channelInactive(ChannelHandlerContext ctx) throws Exception {
        System.out.println("channelInactive");
        super.channelInactive(ctx);
    }

    @Override
    public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
        System.out.println("channelUnregistered");
        super.channelUnregistered(ctx);
    }
}
```

由于HTTP协议的无状态

所以刷新会重置handler和对应的Pipeline



![image.png](https://i.loli.net/2021/01/24/Sc5uvKQETCkshtp.png)

**image.png**



不知道为什么谷歌浏览器访问不到 todo

## 什么是RPC

RCP(Remote Procedure Call) 远程调用过程

远程调用过程? ()这玩应就跟把Socket翻译成套接字一样 说个锤子)

那有远程调用就有本地调用 – 本地就是在自己的服务里进行交互; 那很显然远调就是 自己的服务与别的服务进行交互



![通信过程](file:///C:/%5CUsers%5C25778%5CAppData%5CRoaming%5CTypora%5Ctypora-user-images%5Cimage-20200824230828180.png)

**通信过程**





![image.png](https://i.loli.net/2020/08/24/anKBl9hW1dHz8Ls.png)

**image.png**



### 举个栗子🌰

1. 普通架构计, 做一个加法计算 主函数调用 计算的add方法
2. 分布式呢就是把计算的服务单独拿出来了 但是怎么获取到计算服务的方法呢?

可以在计算服务加一个接口? 但是不能每一次都发起http请求呀

如何让使用者感受不到远程调用呢?





java

```java
@Reference
private 计算 name;
```

使用**代理模式**和Spring的**IOC**一起, 注入需要的对象

- **核心模块** 通讯 和 序列化
- **解决分布式系统中，服务之间的调用问题。**
- **远程调用时，要能够像本地调用一样方便，让调用者感知不到远程调用的逻辑。**

## dubbo



![dubbo流程](http://dubbo.apache.org/docs/zh-cn/user/sources/images/dubbo-architecture-roadmap.jpg)

**dubbo流程**



# 参考资料

[如何给老婆解释什么是RPC](https://www.jianshu.com/p/2accc2840a1b)

[NIO通信模型案例](https://www.cnblogs.com/haimishasha/p/10756448.html#autoid-0-0-0)

**Scalable** **IO in** **Java** (一本书)
