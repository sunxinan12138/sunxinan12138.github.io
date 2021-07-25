---
title: Spring事务
author: 熙男
date: 2021-07-25 17:17:53
categories:
tags:
---

# 事务

## 事务说明

> 什么是事务

事务式代表单个工作单元的一组SQL语句.

所有这些语句都应该成功完成, 否则事务会运行失败.

我们在需要对数据库进行多次更改的情况下使用事务

> 四大特性(ACID)

1. Atomicity: 原子性 每个事物不可分割

2. **Consistency: 一致性 :** 使用事务 数据库始终保持一致的状态

   - 完整约束

3. Isolation: 隔离性 事物之间不可干扰

   - 锁行

     如果多个事务想要更新相同的数据

     受影响的行会被锁定

     因此只有一个事务可以更新行

4. Durability: 持续性 一旦提交 事务的更改是永久的

> Mysql对事务处理

mysql会封装我们写的sql 如果检查无误自动提交



![mysql自动提交属性](https://i.loli.net/2020/08/23/LaimKnoYh1dc2P5.png)

**mysql自动提交属性**



mysql innodb引擎已经通过MVCC、间隙锁&临键锁解决了可重复读隔离级别下的幻读问题

## 事务实现技术/原理



![image.png](https://i.loli.net/2020/08/23/O1uMT6z3eIAVWS7.png)

**image.png**



### 事务的实现原理

1. 事务的

   原子性 通过undo log

    

   实现

   - ~~undo log : 操作任何数据之前,将数据备份到一个地方 (Undo log). 然后进行数据修改. 如果出现错误或者执行RollBack语句. 系统用备份在undo log 下的数据进行回滚(sql执行相反操作delect – insetr update – 相反的update)~~

2. 事务的

   持久性 通过redo log

    

   实现

   - 和undo log 相反, redo 是记录是新数据的备份 系统崩溃时 可以根据redo 恢复?

3. 事务的隔离性 通过(**读写锁+MVCC**[多版本并发控制])来实现

4. ==事务一致性通过 原子性, 持久性, 隔离性实现!!!!!==

- bin log (binary log)

### 隔离性实现原理 : **锁**

1. Mysql 分为:
   - 共享锁(Shared): ==锁行== 将数据对象变为**只读**形式, 不能进行更新 也是**读写**锁定. 多个事务共享但是 不能修改
   - 排它锁(Exclusive): ==锁行== **不与其他锁共存** 如果一个事务获取了排它锁. 其他事务就不能在获取锁了, 只有获取锁的事务对数据进行修改
   - 还有个自增锁(对于自增列自增长的一个特殊的表级锁)
2. 锁得粒度(粒度越高效率低但是安全)
   - 记录
   - 表
   - 数据库
3. 锁的并发流程
   - 事务根据自己的草最获取对应的锁
   - 申请的请求被发给 锁管理器 (是否冲突 是否可以获得)
   - 若被授予锁 则继续 否则等待 直到其他的事务释放

## 创建事务





sql

```sql
START TRANSACTION ;
 // sql语句...
Commit; -- 提交
RollBack -- 回滚
-- 保存点
SAVEPOINT point_name
RollBack  to point_name 回滚到保存点
```

## 并发和锁定

> 在真实场景中肯定会有多个用户去访问相同的数据 这就是 并发 如果正在访问被修改的数据 那就回出现问题

- mysql 默认并发处理 – 锁行

当一个事务修改行没有结束时 另一个事务再次对其修改会被锁住发生超时





sql

```sql
> 1205 - Lock wait timeout exceeded; try restarting transaction
// 超过了锁定等待超时；尝试重新启动事务  -- 事务会失效
```

## 四种隔离级别

> sql
>
> ```sql
> select @@tx_isolation; 查看事务隔离级别
> ```

1. 默认

2. Read UNCOMMITTED（未提交内容读）

3. Read Committed（提交内容读）

4. Repeatable Read（可重读）

5. Serializable（可串行化(可序列化)）

   

   ![image.png](https://i.loli.net/2020/08/23/42nrMJzVkWZ7Fp6.png)

   **image.png**

   

   脏度:读取到了**另一个事务未结束**的数据(回滚前 或者更新前)

   不可重复读: 再**一次事务**中, 两次查询不一致,可能在两次查询中更改了数据

   幻读: 两次查询,第二次查到了新的行(多了一行)





sql

```sql
set session / globel transaction isolation level 级别 // 设置级别 
session(当前会话) / globel (全局)
```

### ~~Read UNCOMMITTED（未提交内容读）~~

### ~~Read Committed（提交内容读）~~

### ~~Repeatable Read（可重读）~~

### ~~Serializable（可串行化(可序列化)）~~

### 死锁

- 某两个或以上的事务 获取了其他事务执行时必要的锁 且不能释放 那么就会发生死锁

# Spring事务

### 声明式事务

传播特性

### 编程式事务

### 参考资料

http://blog.codinglabs.org/articles/theory-of-mysql-index.html

http://blog.codinglabs.org/articles/index-condition-pushdown.html
