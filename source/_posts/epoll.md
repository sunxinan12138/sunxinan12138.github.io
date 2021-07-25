---
title: epoll
author: 熙男
date: 2021-07-25 16:42:00
categories:
tags:
---

# epoll为什么性能好

> 对 select/poll/epoll 一个记录吧，一些自己的理解

服务端开发嘛，所以很重要的是网络编程，epoll作为linux下的高性能网络服务所以了解一下也蛮重要的。比如epoll和select的区别是什么？epoll高效率的原因是什么？

## 如何处理网络信息

- 一台机器接收到了一条消息后，硬件的传输后，写入到内存。这个写入内存的操作是一个优先级较高的中断程序。当很多很多的消息从客户端传来，怎么处理？
- 计算机如何知道网络数据对应哪个(socket)连接？如何同时监控这些数据。

=.=

- 首先第一个：建立多个连接，每个连接一个线程（如果是一个多线程的程序，一个用户一个线程，上下文切换会消耗很多性能，如果单线程下如何处理大量的网络消息呢？）
- 第二个：
  - **如何识别哪个连接：** ip和端口号在操作系统的socket的索引。
  - **同时监控呢？** 多路复用是重点

## select

先写一个程序来在用户态实现这个功能：





java

```java
首先在一个的循环程序下，遍历这个所有的连接，有数据进行处理。
while(1){
    for(fdx in fd(1)~fd(n){
        if(fd 有数据){
            处理。。。
        }   
    }
}
// todo ----
```

网络数据不应该在用户态进行监控，所以基于内核的select技术出现了，源码：





c++

```c++
int do_select(int n, fd_set_bits *fds, s64 *timeout)    
{    
 struct poll_wqueues table;    
 poll_table *wait;    
 int retval, i;    

 rcu_read_lock();    
 /*根据已经打开fd的位图检查用户打开的fd, 要求对应fd必须打开, 并且返回最大的fd*/   
 retval = max_select_fd(n, fds);    
 rcu_read_unlock();    

 if (retval < 0)    
  return retval;    
 n = retval;    


 /*将当前进程放入自已的等待队列table, 并将该等待队列加入到该测试表wait*/   
 poll_initwait(&table);    
 wait = &table.pt;    

 if (!*timeout)    
  wait = NULL;    
 retval = 0;    

 for (;;) {/*死循环*/   
  unsigned long *rinp, *routp, *rexp, *inp, *outp, *exp;    
  long __timeout;    

  /*注意:可中断的睡眠状态*/   
  set_current_state(TASK_INTERRUPTIBLE);    

  inp = fds->in; outp = fds->out; exp = fds->ex;    
  rinp = fds->res_in; routp = fds->res_out; rexp = fds->res_ex;    


  for (i = 0; i < n; ++rinp, ++routp, ++rexp) {/*遍历所有fd*/   
   unsigned long in, out, ex, all_bits, bit = 1, mask, j;    
   unsigned long res_in = 0, res_out = 0, res_ex = 0;    
   const struct file_operations *f_op = NULL;    
   struct file *file = NULL;    

   in = *inp++; out = *outp++; ex = *exp++;    
   all_bits = in | out | ex;    
   if (all_bits == 0) {    
    /*   
    __NFDBITS定义为(8 * sizeof(unsigned long)),即long的位数。   
    因为一个long代表了__NFDBITS位，所以跳到下一个位图i要增加__NFDBITS   
    */   
    i += __NFDBITS;    
    continue;    
   }    

   for (j = 0; j < __NFDBITS; ++j, ++i, bit <<= 1) {    
    int fput_needed;    
    if (i >= n)    
     break;    

    /*测试每一位*/   
    if (!(bit & all_bits))    
     continue;    

    /*得到file结构指针，并增加引用计数字段f_count*/   
    file = fget_light(i, &fput_needed);    
    if (file) {    
     f_op = file->f_op;    
     mask = DEFAULT_POLLMASK;    

     /*对于socket描述符,f_op->poll对应的函数是sock_poll   
     注意第三个参数是等待队列，在poll成功后会将本进程唤醒执行*/   
     if (f_op && f_op->poll)    
      mask = (*f_op->poll)(file, retval ? NULL : wait);    

     /*释放file结构指针，实际就是减小他的一个引用计数字段f_count*/   
     fput_light(file, fput_needed);    

     /*根据poll的结果设置状态,要返回select出来的fd数目，所以retval++。   
     注意：retval是in out ex三个集合的总和*/   
     if ((mask & POLLIN_SET) && (in & bit)) {    
      res_in |= bit;    
      retval++;    
     }    
     if ((mask & POLLOUT_SET) && (out & bit)) {    
      res_out |= bit;    
      retval++;    
     }    
     if ((mask & POLLEX_SET) && (ex & bit)) {    
      res_ex |= bit;    
      retval++;    
     }    
    }    

    /*   
    注意前面的set_current_state(TASK_INTERRUPTIBLE);   
    因为已经进入TASK_INTERRUPTIBLE状态,所以cond_resched回调度其他进程来运行，   
    这里的目的纯粹是为了增加一个抢占点。被抢占后，由等待队列机制唤醒。   

    在支持抢占式调度的内核中（定义了CONFIG_PREEMPT），cond_resched是空操作   
    */     
    cond_resched();    
   }    
   /*根据poll的结果写回到输出位图里*/   
   if (res_in)    
    *rinp = res_in;    
   if (res_out)    
    *routp = res_out;    
   if (res_ex)    
    *rexp = res_ex;    
  }    
  wait = NULL;    
  if (retval || !*timeout || signal_pending(current))/*signal_pending前面说过了*/   
   break;    
  if(table.error) {    
   retval = table.error;    
   break;    
  }    

  if (*timeout < 0) {    
   /*无限等待*/   
   __timeout = MAX_SCHEDULE_TIMEOUT;    
  } else if (unlikely(*timeout >= (s64)MAX_SCHEDULE_TIMEOUT - 1)) {    
   /* 时间超过MAX_SCHEDULE_TIMEOUT,即schedule_timeout允许的最大值，用一个循环来不断减少超时值*/   
   __timeout = MAX_SCHEDULE_TIMEOUT - 1;    
   *timeout -= __timeout;    
  } else {    
   /*等待一段时间*/   
   __timeout = *timeout;    
   *timeout = 0;    
  }    

  /*TASK_INTERRUPTIBLE状态下，调用schedule_timeout的进程会在收到信号后重新得到调度的机会，   
  即schedule_timeout返回,并返回剩余的时钟周期数   
  */   
  __timeout = schedule_timeout(__timeout);    
  if (*timeout >= 0)    
   *timeout += __timeout;    
 }    

 /*设置为运行状态*/   
 __set_current_state(TASK_RUNNING);    
 /*清理等待队列*/   
 poll_freewait(&table);    

 return retval;    
}    
```

一个实例：





c++

```c++
// 创建连接的描述符 fd[x]
// max 表示集合中最大的数字
sockfd = socket(AF_INET, SOCK_STREAM, 0);
memset(&addr, 0, sizeof(addr));
addr.sin_family = AF_INET;
addr.sin_port = htons(20OO);
addr.sin_addr.s_addr = INADDR_ANY;
bind(sockfd，(struct sockaddr *) & addr, sizeof(addr));
listen(sockfd，S);

for (i = 0; i < 5; i++)
{
    memset(&client，0，sizeof(client));
    addrlen = Sizeof(client);
    // 创建了五个连接
    fds[i] = accept(sockfd，(struct sockaddr *) & client, &addrlen);
    if (fdsp[i] > max)
        max = fds[i];
}
// while 来处理网络消息  执行
while (1)
{
    // set 是一个bitMap 半段哪些会被监听
    /*
            bitMap有1024位
            如果：1，2，5，6，7（fd中数据） 
            所以：就是 0 1 1 0 0 1 1 1 0 0。。。。
    */
    FD_ZERO(&rset);
    for (i = 0; i < 5; i++)
    {
        FD_SET(fds[i], &set);
    }
    puts("round again");
    /*  1. max+1
        2. 读文件描述符集合
        3. 写文件描述符集合
        4. 异常集合
        5. 超时时间
    */
    select(max + l, &rset, NULL, NULL, NULL);
    for (i = 0; i < 5; i++)
    {
            // 要对每一个有数据的描述符(fd)进行处理
            if (FD_ISSET(fds[i]，&rset))
            {
                memset(buffer, 0, MAXBUF);
                read(fds[i], buffer, MAXBUF);
                puts(buffer);// 处理函数
            }
    }
}
```

1. 用户创建 出rset 给内核来监听 判断到数据发送回用户态对应到fd[x]
2. select函数如果没有数据会一致阻塞
3. rset置位，select执行结束。用户可以根据rset的变化来判断哪个收到了数据，并且处理

- 图中列出了缺点



![select](https://i.loli.net/2021/01/17/HkrL4MjAeB3sSuq.png)

**select**



## poll/epoll

用例：





c++

```c++
// 结构体的改变
/*
    fd
    events: 在意的事件 （POLLIN， POLLOUT）
    revents: 对事件的反馈
*/
struct pollfd{ 
int fd;
short events;
short revents;
}
// --------------------
// 创建连接
for(i=0; i<5; i++){
    memset(&cltent, 0, sizeof(client));
    addrlen = sizeof(client);
    pollfds[i].fd=accept(sockfd,struct sockaddr*)&cltent, &addrlen);
    pollfds[i].events=POLLIN;
}
sleep(l);
// 执行
while(l){
    puts("roundagain");
    /* 
        1. poofd:结构体
        2. 数量
        3. 超时时间
    */
    poll(pollfds, 5, 50000);
    for(i=0; i<5; i++){
    if(po11fds[i].revents & POLLIN){
        // 置位回去
        pollfds[i]].revents = 0；
        memset(buffer，0，MAXBUF);
        read(pollfds[i].fd, buffer, MAXBUF)；
        puts(buffer);
    }
}
```

1. 内核判断有数据 置位revent我们就知道哪个有数据了
2. 置位方式所以可以重用



![image-20210117175836804](file:///C:/%5CUsers%5C25778%5CAppData%5CRoaming%5CTypora%5Ctypora-user-images%5Cimage-20210117175836804.png)

**image-20210117175836804**



## epoll

将复杂度简化为O(1)

用例：





c++

```c++
struct epolI_event events[5];
int epfd = epoll_create(10);
...
...
// 创建EPFD
for (i = 0;i < 5; i++)
{
    static struct epoll_event ev;
    memset(&cltent, 0, sizeof(client));
    addrlen = sizeof(client);
    ev.data.fd =accept(sockfd，(struct sockaddr*)&client，&addrlen);
    ev.events = EPOLLIN;
    // 在结构体添加 fd - events （有五个）
    epoll_ctl(epfd, EPOLL_CTL_ADD, ev.data.fd, &ev);
}
// 执行:
while(l){
    puts("roundagain");
    // 具体函数
    nfds = epoll_wait(epfd, events,5, 10000）;
    for(i = 0; i < nfds; i++){
        memset(buffer,0,MAXBUF);
        read(events[i],data,fd,buffer,MAXBUF);
        puts(buffer);
    }
}
```

1. epfd 是一个公用的 所以不用拷贝了
2. 置位方式：重排序（将有数据的fd放到最前） 所以不需要单独的结构来处理置位
3. 复杂度降低O(1) 不需要遍历所有的fd 因为返回的 只是接收的数据（nfds）



![image-20210117175854638](file:///C:/%5CUsers%5C25778%5CAppData%5CRoaming%5CTypora%5Ctypora-user-images%5Cimage-20210117175854638.png)

**image-20210117175854638**



## 总结



![image-20210117175913944](file:///C:/%5CUsers%5C25778%5CAppData%5CRoaming%5CTypora%5Ctypora-user-images%5Cimage-20210117175913944.png)

**image-20210117175913944**



# 参考

https://zhuanlan.zhihu.com/p/63179839

https://www.bilibili.com/video/BV1qJ411w7du?from=search&seid=12266065751194287806

### todo

epoll 没有深入

代码实现

底层
