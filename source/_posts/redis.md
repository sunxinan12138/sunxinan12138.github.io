---
title: redis
author: sjs
date: 2021-07-25 17:25:08
categories:
tags: 笔记
---

# Redis

 ## 概述

> redis  介绍

Redis（**Re**mote **Di**ctionary **S**erver )，即远程字典服务。是一个开源的使用ANSI [C语言](https://baike.baidu.com/item/C语言)编写、支持网络、可基于**内存**亦**可持久化**的日志型、Key-Value[数据库](https://baike.baidu.com/item/数据库/103728)，并提供多种语言的API。[百度百科]

> 官网介绍

Redis是一个开源（BSD许可），内存数据结构存储，用作数据库，缓存和消息代理。 Redis提供数据结构，例如字符串，哈希列表，集合，排序集，带有范围查询，位图，超级目录，地理空间索引和流。 Redis拥有内置复制，Lua Scripting，LRU驱逐，事务和不同级别的磁盘持久性，并通过Redis Sentinel和Redis Cluster自动分区提供高可用性

> redis 用途

1. 内存存储，持久化，持久化机制（rdb,aof）
2. 高效，用于高速缓存
3. 发布订阅系统
4. 地图信息分析
5. 计量器，计数器
6. 。。。

### redis

redis  默认16个db 使用第0个

端口6379 是因为作者的偶像的9键名字。

> redis 是单线程的

redis是很快的，官方介绍，Redis基于内存操作，CPU不是Redis的性能瓶颈，Redis的瓶颈瑟吉欧根据机器的内存和网络带宽，既然可以单线程实现，就使用单线程了。

Redis是C语言写的。挂房提供数据：100000+ 的QPS， 和Memecache不相上下。

> 为什么Redis是单线程还这么快？

单线程和多线程认识误区：

1. 高性能服务器**不**一定是多线程。
2. 多线程（CPU是上下文切换）一定**不比**多线程高

速度：CPU>内存>硬盘。 cpu切换非常耗时间。

reids将所有数据存放内存中。所以单线程去操作效率就是最高的，多线程（CPU上下文切换消耗时间），对于内存系统来说，如果没有上下文切换效率就是最高的！多次读写都在同一个CPU上的，在内存情况下，这就是最佳方案。

## Redis -Benchmark 性能测试

```bash
redis-benchmark [option] [option value]
```

参数如下：

| 序号 | 选项                      | 描述                                       |           |
| :--- | :------------------------ | :----------------------------------------- | :-------- |
| 1    | **-h**                    | 指定服务器主机名                           | 127.0.0.1 |
| 2    | **-p**                    | 指定服务器端口                             | 6379      |
| 3    | **-s**                    | 指定服务器 socket                          |           |
| 4    | **-c**                    | 指定并发连接数                             | 50        |
| 5    | **-n**                    | 指定请求数                                 | 10000     |
| 6    | **-d**                    | 以字节的形式指定 SET/GET 值的数据大小      | 2         |
| 7    | **-k**                    | 1=keep alive 0=reconnect                   | 1         |
| 8    | **-r**                    | SET/GET/INCR 使用随机 key, SADD 使用随机值 |           |
| 9    | **-P**                    | 通过管道传输 <numreq> 请求                 | 1         |
| 10   | **-q**                    | 强制退出 redis。仅显示 query/sec 值        |           |
| 11   | **--csv**                 | 以 CSV 格式输出                            |           |
| 12   | ***-l\*（L 的小写字母）** | 生成循环，永久执行测试                     |           |
| 13   | **-t**                    | 仅运行以逗号分隔的测试命令列表。           |           |
| 14   | ***-I\*（i 的大写字母）** | Idle 模式。仅打开 N 个 idle 连接并等待。   |           |

## 安装

todo



### Docker

```bash
docker run -d --name redis -p 6379:6379 --restart unless-stopped -v /home/redis/data:/data -v /home/redis/conf/redis.conf:/etc/redis/redis.conf -d redis:buster redis-server /etc/redis/redis.conf 

--------
自启
/usr/local/bin/redis-server  /usr/soft/redis/redis-6.2.5/etc/redis.conf
```



## Redis Key命令

```
select num： 切换第num个数据库
DBSIZE： 查看dbSize
keys * ： 查看keys
flushdb ：清空
flushAll : 清空所有
move key （1 数据库）： 移除key 一般不用？？？
-------------------
set key val : 插入
mset 批量添加
-------------------
mget 批量获取
expire key time： time后失效
setex key time val : time后失效
setinx ： 不存在设置
setnx : 不存在创建
ttl key : 实时查看过期时间
type kay ： 查看 key的类型
Exists key ： 是否存在
-------------------
i++
decr/ incr key ： 减一/加一
decrby/ incrby key num: 减/加 num
--------------------
msetnx: 原子性 批量添加

getset key val： 不存在返回null  存在 返回旧 插入新 ==CAS==
```



## 基本类型



### String

> append key ： 追加Str
> strlen key ： 返回长度
> getRange key star end : 截取长度【star , end】
> setRange key star end "str" : 替换[s到n]字符串

### List

> lpush key val : 头部从左近入
>
> Rpush ： 尾部右插入
>
> 
>
> Lpop key ： 移出左侧
>
> rPop  ： 右侧移出
>
> 
>
> lRange key a b 获取第[a,b]数据
>
> lindex key val 获取某一个值
>
> llen ： 长度
>
> trim  a,b： 截取 剩下 [a,b] 的数据
>
> rpoplPush  souce tar : 右侧移除最后一个 左侧添加一个

### Set

> sadd key val : 添加
>
> smembers  key ： 查看
>
> sismember key val 查看是否存在set中
>
> srem 移除
>
> srandmember key  num随机查询num个数据
>
> sdiff fox king  # 查看fox集合的差集
>
> sinter fox king  # 查看两个集合的交集
>
> sunion fox king  # 查看两个集合的并集
>
> ------------
>
> srem fox one  #移除set集合中指定的元素
>
> spop fox    随机删除
>
> smove fox king 1 # 讲一个指定的值、移动到另外一个set集合中

### hash

* hash是一个String类型的field（字段）和value（值）的映射表，hash特别适合于存储对象。
* Redis中每个Hash可以存储232-1键值对（40多亿）
* hash变更的数据user name age，尤其是用户信息之类的，经常变动的信息！hash更适于对象是存储，String更加适合字符串！！

> hset name keys vals 添加
>
> hget name key
>
> hgetall name 查看
>
> --
>
> hkeys name  查看key
>
> hvals name  查看val
>
> hlen name 数量
>
> hexists name key 是否存在
>
> hdel name key 删除 name的 key段
>
> hincrby name key num  #指定增量 加num
>
> hsetnx name key val  #若不存在、则可以设置、反之不可用设置

### ZSet（sorted set:有序集合）

> zadd name ks  vs  		#添加值
>
> zcard fox  #获取有序集合的成员数
>
> zrange 获取值
>
> zrangebyscore name -inf +inf  			# 查看全部用户，并从小到大排序

## 特殊类型

### geospatial 

* geospatial 地理位置空间   官方网址：https://www.redis.net.cn/order/3689.html
* 朋友的定位，附近的人，打车距离计算？
* Redis 的 Geo 在Redis3.2版本就推出了！这个功能可以推算地理位置的信息，两地之间的距离，方圆几里的人！
* 可以查询一些测试数据：https://jingweidu.51240.com/
* GEO 底层的实现原理：Zset！ 我们可以用Zset命令来操作Geo

> getadd 添加地理位置 规则：南北两级无法直接添加，我们一般会下载城市数据，直接通过java程序一次性导入！
>
> 参数 key 值(纬度、经度、名称) (-180度到180度)
>
> 纬度: -85.05112878度到85.05112878度
> geoadd china:city 116.40 39.90 beijing
>
> geopos china:city hangzhou beijing  # 获取指定的城市的经度 和 维度！
>
> geodist china:city hangzhou beijing km geodist 返回两个给定位置之间的距离
>
> -----------------------------------------------------
>
> GEORADIUS china:city 110 30 1000 km   # 以110,30这个经纬度为中心，寻找方圆1000km内的城市 
> GEORADIUS china:city 110 30 500 km withdist # 显示到中间位置的直线距离 半径500km
>  GEORADIUS china:city 110 30 500 km withcoord # 显示到中心距离半径500km的城市 +  经纬度信息
>  GEORADIUS china:city 110 30 500 km withcoord withdist count 3 # 筛选出指定结果  
> GEORADIUSBYMEMBER china:city beijing 1000 km \# 找出位于指定范围内的元素，中心点是由给定的位置元素决定

### hyperloglog 位图

> 基数

基数（一个集合中不重复的元素）
统计疫情感染人数：存身份标识码
优点：占用的内存是固定的，2^64不同的元素的技术，只需要废12kb内存。如果要从内存角度来比较的话Hyperloglog首选！
如果允许容错，那么一定可以使用Hyperloglog **0.81的错误率**
如果不允许容错，就使用 set 或 自己的数据类型 即可

> pfadd mykey a b c d e f g h i j  # 创建第一组元素 mykey
>
> PFCOUNT mykey  # 统计mykey元素的基数数量
>
> PFMERGE mykey3 mykey mykey2 # 合并两组 mykey mykey2=>mykey3并集
> 

### bitmap 位图

> * 位存储 用于 打卡 登录与否 这类 0/1 状态切换的类型 1字节 = 8位

> setbit name a b  输入第a条数据为b（0/1）
>
> get name x 获取第x天的数据
>
> bitcount name 查看 数据

## 事务

* Redis事务本质：一组命令的集合！一个事务中所有命令都会被序列化，在事务执行过程中，会按照顺序执行！一次性、顺序性、排他性！执行一系列的命令！
  Redis事务没有隔离级别的概念！

* 所有的命令在事务中，并没有直接被执行！只有发起执行命令的时候才会执行！Exec

* Redis单条命令是保证原子性的，但是事务不保证原子性！

> Redis的事务：
> 一个事务从开始到执行会经历以下三个阶段：

> 开启事务（MULTI)
> 命令入队（）
> 执行事务（EXEC）

1. MULTI	标记一个事务块的开始。
2. EXEC	执行所有事务块内的命令。
3. DISCARD	取消事务，放弃执行事务块内的所有命令。
4. UNWATCH	取消 WATCH 命令对所有 key 的监视。
5. WATCH key [key …]	监视一个(或多个) key ，如果在事务执行之前这个(或这些) key 被其他命令所改动，那么事务将被打断。

### 事务错误异常

> 编译型异常（代码有问题、命令有错）、事务中所有的命令都不会被执行

> 运行时异常（1/0）,如果事务队列中存在语法性、那么执行命令的时候、其他命令是可以正常执行的、错误命令抛出异常！

## 乐观锁

> watch 监控

悲观锁：

* 任务怎么样都会出问题，无论什么操作都要加锁。

乐观锁：

* 认为不会出问题，只有需要的时候才会上锁。更新数据的时候回去判断一下，在此期间是否数据被修改。
* 获取version
* 更新时比较version

> watch 监视 unwatch 解锁 提交失败 所有都失败

```bash
127.0.0.1:6379>watch money #监视money
OK
127.0.0.1:6379>mu1ti
OK
127.0.0.1:6379>DECRBY money 10
QUEUED
127.0.0.1:6379>INCRBY out 10
QUEUED
127.0.0.1;6379> exec #执行之前，另外一个线程。修改「我们的值，这个时候，就会导改事务执行失败!
(ni1)
```

## jedis

我们要使用java来操作Redis

> 什么是Jedis？ 是Redis官方推荐的java连接开发工具！使用java操作Redis的中间件！如果要使用java操作Redis、一定要对Jedis十分的熟悉！

```xml
 <!--导入Jedis的包-->
    <!-- https://mvnrepository.com/artifact/redis.clients/jedis -->
    <dependencies>
        <dependency>
            <groupId>redis.clients</groupId>
            <artifactId>jedis</artifactId>
            <version>3.4.1</version>
        </dependency>

        <!--fastjson-->
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>fastjson</artifactId>
            <version>1.2.75</version>
        </dependency>
    </dependencies>
```

#### string

```java
 public static void main(String[] args) {
        Jedis jedis = new Jedis("8.*.*.76", 6379);
        System.out.println("清空数据：" + jedis.flushDB());
        System.out.println("判断某个键是否存在：" + jedis.exists("username"));
        System.out.println("新增<'username','username'>的键值对：" + jedis.set("username", "username"));
        System.out.println("新增<'password','password'>的键值对：" + jedis.set("password", "password"));
        System.out.println("系统中所有的键如下：");
        Set<String> keys = jedis.keys("*");
        System.out.println(keys);
        System.out.println("删除键password：" + jedis.del("password"));
        System.out.println("判断键password是否存在：" + jedis.exists("password"));
        System.out.println("查看username所存储的值的类型：" + jedis.type("username"));
        System.out.println("随机返回key空间的一个：" + jedis.randomKey());
        System.out.println("重命名key：" + jedis.rename("username", "name"));
        System.out.println("取出改后的name：" + jedis.get("name"));
        System.out.println("按索引查询：" + jedis.select(0));
        System.out.println("删除当前选择数据库中的所有key：" + jedis.flushDB());
        System.out.println("返回当前数据库中的key的数目：" + jedis.dbSize());
        System.out.println("删除所有数据库中的所有key：" + jedis.flushAll());
    }
```

#### list

```java
 public static void main(String[] args) {
        Jedis jedis = new Jedis("8.*.*.*", 6379);
        jedis.flushDB();
        System.out.println("==========增加数据==========");
        System.out.println(jedis.set("key1", "value1"));
        System.out.println(jedis.set("key2", "value2"));
        System.out.println(jedis.set("key3", "value3"));
        System.out.println("删除键key2：" + jedis.del("key2"));
        System.out.println("获取键key2：" + jedis.get("key2"));
        System.out.println("修改key1：" + jedis.set("key1","valueChanged"));
        System.out.println("获取key1的值：" + jedis.get("key1"));
        System.out.println("在key3后面加入值：" + jedis.append("key3", "End"));
        System.out.println("key3的值：" + jedis.get("key3"));
        System.out.println("增加多个键值对：" + jedis.mset("key01", "value01", "key02", "value02", "key03", "value03"));
        System.out.println("获取多个键值对：" + jedis.mget("key01",  "key02",  "key03"));
        System.out.println("删除多个键值对：" + jedis.del("key01",  "key02"));
        System.out.println("获取多个键值对：" + jedis.mget("key01",  "key02","key03"));

        jedis.flushDB();
        System.out.println("=============新增键值对防止覆盖原先值=================");
        System.out.println(jedis.setnx("key1", "value1"));
        System.out.println(jedis.setnx("key2", "value2"));
        System.out.println(jedis.setnx("key2", "value2-new"));
        System.out.println(jedis.get("key1"));
        System.out.println(jedis.get("key2"));

        System.out.println("新增键值对并设置有效时间");
        System.out.println(jedis.setex("key3", 2, "value3"));
        System.out.println(jedis.get("key3"));
        try {
            TimeUnit.SECONDS.sleep(3);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(jedis.get("key3"));

        System.out.println("================获取原值，更新为新值==============");
        System.out.println(jedis.getSet("key2", "key2GetSet"));
        System.out.println(jedis.get("key2"));
        System.out.println("获得key2的值的字串：" + jedis.getrange("key2", 2, 4));
    }
```

#### set

```java
public static void main(String[] args) {
    Jedis jedis = new Jedis("*.*.*.*", 6379);
    jedis.flushDB();
    System.out.println("==============向集合中添加元素(不重复)==============");
    System.out.println(jedis.sadd("eleSet", "e1", "e2", "e3", "e4", "e5", "e6", "e7"));
    System.out.println(jedis.sadd("eleSet", "e8"));
    System.out.println(jedis.sadd("eleSet", "e8"));
    System.out.println("eleSet的所有元素为：" + jedis.smembers("eleSet"));
    System.out.println("删除一个元素e1:" + jedis.srem("eleSet", "e1"));
    System.out.println("eleSet的所有元素为：" + jedis.smembers("eleSet"));
    System.out.println("删除两个元素e7和e4:" + jedis.srem("eleSet", "e7", "e4"));
    System.out.println("eleSet的所有元素为：" + jedis.smembers("eleSet"));
    System.out.println("随机的移除集合中的一个元素：" + jedis.spop("eleSet"));
    System.out.println("eleSet的所有元素为：" + jedis.smembers("eleSet"));
    System.out.println("eleSet中包含元素的个数：" + jedis.scard("eleSet"));
    System.out.println("e3是否在eleSet中：" + jedis.sismember("eleSet", "e3"));
    System.out.println("===========================================");
    System.out.println(jedis.sadd("eleSet1", "e1", "e2", "e3", "e4", "e5", "e6", "e7"));
    System.out.println(jedis.sadd("eleSet2", "e1", "e2", "e3", "e4", "e5"));
    System.out.println("将eleSet1中删除e1并存入eleSet3中：" + jedis.smove("eleSet1", "eleSet3", "e1"));
    System.out.println("将eleSet1中删除e2并存入eleSet3中：" + jedis.smove("eleSet1", "eleSet3", "e2"));
    System.out.println("eleSet1中的元素：" + jedis.smembers("eleSet1"));
    System.out.println("eleSet3中的元素：" + jedis.smembers("eleSet3"));
    System.out.println("==================集合运算=================");
    System.out.println("eleSet1中的元素：" + jedis.smembers("eleSet1"));
    System.out.println("eleSet2中的元素：" + jedis.smembers("eleSet2"));
    System.out.println("eleSet1和eleSet2的交集："+jedis.sinter("eleSet1","eleSet2"));
    System.out.println("eleSet1和eleSet2的并集："+jedis.sunion("eleSet1","eleSet2"));
    System.out.println("eleSet1和eleSet2的差集："+jedis.sdiff("eleSet1","eleSet2"));
    System.out.println("eleSet1和eleSet2的交集个数为："+jedis.sinterstore("eleSet4", "eleSet1", "eleSet2"));
    System.out.println("把eleSet1和eleSet2的交集存储到eleSet4中、eleSet4的元素为："+jedis.smembers("eleSet4"));
}
```

#### hash

```java
public static void main(String[] args) {
    Jedis jedis = new Jedis("*.*.*.*", 6379);
    jedis.flushDB();
    HashMap<String, String> map = new HashMap<>();
    map.put("key1", "value1");
    map.put("key2", "value2");
    map.put("key3", "value3");
    map.put("key4", "value4");
    System.out.println("=========添加名称为hash(key)的hash元素============");
    jedis.hmset("hash", map);
    System.out.println("===向名称为hash的hash中添加key为key5，value为value5的元素====");
    jedis.hset("hash", "key5", "value5");
    System.out.println("散列hash的所有键值对为："+jedis.hgetAll("hash"));
    System.out.println("散列hash的所有键为："+jedis.hkeys("hash"));
    System.out.println("散列hash的所有值为："+jedis.hvals("hash"));
    System.out.println("将key6保存的值加上一个整数，如果key6不存在则添加key6："+jedis.hincrBy("hash","key6",6));
    System.out.println("散列hash的所有键值对为："+jedis.hgetAll("hash"));
    System.out.println("将key6保存的值加上一个整数，如果key6不存在则添加key6："+jedis.hincrBy("hash","key6",3));
    System.out.println("散列hash的所有键值对为："+jedis.hgetAll("hash"));
    System.out.println("删除一个或者多个键值对："+jedis.hdel("hash","key2"));
    System.out.println("散列hash的所有键值对为："+jedis.hgetAll("hash"));
    System.out.println("散列hash中键值对的个数："+jedis.hlen("hash"));
    System.out.println("判断hash中是否存在key2："+jedis.hexists("hash","key2"));
    System.out.println("判断hash中是否存在key3："+jedis.hexists("hash","key3"));
    System.out.println("获取hash中的key3的值："+jedis.hmget("hash","key3"));
    System.out.println("获取hash中的key3、key4的值："+jedis.hmget("hash","key3","key4"));
}
```

#### 事务

```java
public static void main(String[] args) {
    Jedis jedis = new Jedis("服务器IP地址", 6379);
    jedis.auth("密码");
    jedis.flushDB();
    JSONObject jsonObject = new JSONObject();
    jsonObject.put("hello", "world");
    jsonObject.put("name", "fox");
    //        开启事务
    Transaction multi = jedis.multi();
    String string = jsonObject.toJSONString();
    //        jedis.watch(string);

    try {
        multi.set("user1", string);
        multi.set("user2", string);
        //            int i = 1 / 0;//代码抛出异常，执行失败！
        multi.exec();//执行事务
    } catch (Exception e) {
        multi.discard();//放弃事务
        e.printStackTrace();
    } finally {
        System.out.println(jedis.get("user1"));
        System.out.println(jedis.get("user2"));
        jedis.close();//关闭连接
    }
}
```

## SpringBoot 整合

* 在springboot2.X之后，原来使用的jedis被替换为了lettuce
* jedis：采用的直接连接，多个线程操作的话，会不安全，如果要避免不安全，使用jedis Pool连接池 类似BIO模式。
* lettuce：采用nett ，实例可以再多个线程中共享，不存在线程不安全的情况！可以减少线程数据，更像NIO模式。

```properties
# RedisAutoConfigUration 自动配置类
# RedisProperTies 配置文件
# 配置文件：
spring.redis.host=8.131.86.76
spring.redis.port=6379
spring.redis.password=密码
```

```java
@SpringBootTest
class Redis02SpringbootApplicationTests {

    @Autowired
    private RedisTemplate redisTemplate;

    @Test
    void contextLoads() {
   /*   redisTemplate 操作不同的数据类型.api和我们的指令是一样的
        opsForValue 操作字符串 类似String
        opsForList  操作list
        opsForSet
        opsForHash
        opsForZSet
        opsForGeo
        opsForHyperLogLog
        redisTemplate.opsForHyperLogLog();*/

/*      除了以上的基本操作，我们常用的方法都可以通过redisTemplate直接操作、比如事务、基本的crud
        redisTemplate.multi();*/

 /*     获取Redis的连接对象
        RedisConnection connection = redisTemplate.getConnectionFactory().getConnection();
        connection.flushAll();
        connection.flushDb();*/
        redisTemplate.opsForValue().set("mykey", "fox");
        System.out.println(redisTemplate.opsForValue().get("mykey"));

    }
}
```

#### 序列化问题

![image-20210808153523713.png](https://i.loli.net/2021/08/08/skLK9pEQCtjqogU.png)

![image-20210808153633948.png](https://i.loli.net/2021/08/08/Y1ByTrLKbf7IhOe.png)



### SpringBoot Redis Template

```java
@Configuration
public class RedisConfig {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory redisConnectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<String, Object>();
        template.setConnectionFactory(redisConnectionFactory);

        //Json序列化配置
        Jackson2JsonRedisSerializer jackson2JsonRedisSerializer = new Jackson2JsonRedisSerializer<>(Object.class);
        ObjectMapper om = new ObjectMapper();
        om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        om.activateDefaultTyping(LaissezFaireSubTypeValidator.instance, ObjectMapper.DefaultTyping.NON_FINAL);
        jackson2JsonRedisSerializer.setObjectMapper(om);
        //String 的序列化
        StringRedisSerializer stringRedisSerializer = new StringRedisSerializer();
        //key采用String的序列化方式
        template.setKeySerializer(stringRedisSerializer);
        //hash的key采用String的序列化方式
        template.setHashKeySerializer(stringRedisSerializer);
        //value序列化方式采用jackson
        template.setValueSerializer(jackson2JsonRedisSerializer);
        //hash的value序列化方式采用jackson
        template.setHashValueSerializer(jackson2JsonRedisSerializer);
        template.afterPropertiesSet();

        return template;
    }

}
```

实体需要序列化





# 文章资料

官网:https://www.redis.io/

中文官网:http://www.redis.cn/

# todo

安装。

