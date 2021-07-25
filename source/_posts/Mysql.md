---
title: Mysql
author: 熙男
date: 2021-07-25 16:44:53
categories:
tags:
---

# mysql

## Mysql介绍

- java企业级开发离不开数据库
- **数据是所有软件体系中核心存在** (DBA职位)

> 只会写代码,学好数据库,混饭吃
>
> 操作系统,数据结构 ! 不错的程序猿
>
> 离散数学,数字电路, 体系结构, 编译原理 + 经验 大佬

### 1. 数据库(DB, DataBase)

数据的仓库

SQL: 可以存储大量数据 500万以下都没问题

#### 数据库分类(SQL/NOSQL)

- 关系型数据库(SQL)
  - Mysql, Oracle, Sql Server, DB2, SQLlite
  - 通过表和表之间, 行和列之间的关系进行数据存储.
- 菲关系型数据库(NOSQL)
  - Redis, MongDB
  - 存储对象,通过对象的自身属性. 而且使用key-value的关系存储的

==DBSM(数据库管理系统)==

- 数据库的管理软件, 管理和维护我们的数据
- MySql 就是DBMS

### Mysql操作语句

| 操作语句                                | 作用                    |
| :-------------------------------------- | :---------------------- |
| mysqld - install                        | 安装数据库(在bin目录下) |
| mysqld –initialize-insecure –user=mysql | 初始化数据文件          |
| flush privileges;                       | 刷新权限                |
| net start mysql                         | 启动Mysql服务           |
| net stop mysql                          | 结束Mysql服务           |
| exit                                    | 退出Mysql               |

### InnoDB和MyISAM

- 现在都是默认使用InnoDB
- MySAM 比较老,以前用

> 区别:

|                 | MySAM    | INNODB             |
| :-------------- | :------- | :----------------- |
| 1. 事务         | 不支持   | **支持**(ACID)     |
| 2. 数据锁定方式 | 表锁定   | **行锁定,表锁定**  |
| 3. 外键约束     | 不支持   | **支持**           |
| 4. 全文索引     | **支持** | 不支持             |
| 5, 表空间大小   | 小       | 大,约为MySAM的两倍 |
| 6. 索引         | b+树     | b+树               |

> 在物理空间:

所有数据库都是以文件形式存储在data目录下,一组文件对应一个数据库,本质还是文件存储

Mysql引擎

- INNODB在数据库上只有一个*.frm, 以及上级目录的ibdata1文件
- MySAM
  - *.frm 表结构
  - *.myd 数据文件(data)
  - *.MYI 索引文件(index)

## 数据库操作语句

> 书写顺序
>
> select – from – where – group by – order by





sql

```sql
-- 查看有什么数据库
show database;
-- 创建库
creat database;
-- 使用库
user 库名;
-- 展示表
show tables;
-- 显示结构
describe 表名;
desc 表名;
-- 创建表
create table 表名(列名 类型(长度));
-- 更新
alter table 表名 add  column  列名 类型();
alter table 表名 add  列名 类型();
--------------------------------------------------
--查看数据库建库语句
show create database 库;
-- 查看表的定义语句
show create table 表;
-- 展示表结构
desc 表;
```

## 数据库聚合函数

> 聚合函数: 他们只运行非空值,如果有空值将不会计算在内
>
> 而且默认重复值会被取到





sql

```sql
-- 基本计算
MAX()
MIN()
AVG()
SUM()
COUNT()
count(参数) 一共多少行
如果是* 那就是总数
count(DISTINCT 参数)  除去重复
-- 去重
DISTINCT 名字
--日期
    -- 格式化日期
    data _format(获取的日期,'%Y%m%d')
    -- 当前时间
    CURDATE()
-- 正则表达式 
regexp()
    -- 模糊查询不用%
    -- ^a 表示以a开始
    -- a$ 以a结尾
    -- |  逻辑与
    -- [abc] 包括其中任一个
    -- [a-b] - 表示a到b的任一个
LAST_INSERT_ID() -- 最后一个INSERT或 UPDATE 自增长(AUTO_INCREMENT)列的ID
-- 分组
group by 列1,列2...
-- 在聚合函数(分组)后使用 的条件筛选
having条件 .. and 条件2
-- WITH ROLLUP运算
用来统计当前列的总和， 统计的是聚合函数的列  
计算的结果是聚合函数的方式 sum是和， AVG是平均数
GROUP BY 列1,列2... WITH ROLLUP 
```

| having                 | where          |
| :--------------------- | :------------- |
| 只能判断select过的列名 | 能判断所有列名 |
| 其他差不多             |                |





sql

```sql
-- 家早va的并且 订单总额大于100
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM( oi.quantity * oi.unit_price ) AS spend 
FROM
    orders o
    JOIN customers c USING ( customer_id )
    JOIN order_items oi USING ( order_id ) 
WHERE
    c.state = 'VA' 
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING
    spend > 90
```

## CURD

增删改查

### 查询

#### 查询/排序





sql

```sql
-- 自动那个提交状态
show variables like 'autocommit'
-- 条件查询
where ... and ... or ... ;
    -- 是否存在 可以代替and操作
    in (a,b,c)
    not in (a,b,c)
    --  是否存在
    exist (返回的是 true/false) 
    -- 在...之间
    WHERE between 10 and 100;
    -- 空, 非空
    is null / is not null  
-- 模糊查询 like %表示任意数量字符 _表示单个任意字符 可以有多个_
where 列 like '%val%'
LIKE '___啊'
-- 排序
order by 列  desc 降序 asc 升序
-- 截取
limit x 表示从头截取x个
limit y,x 表示从y开始截取x个 (分页会用)
```

#### 内连接查询:

> 复合主键: 表中主键数量超过一列





sql

```sql
-- inner可以省略
inner join 表1 on 条件
-- 跨数据库链接
join a库.a表
-- 多表查询
from 表1 join 表2 on ... join 表3 on ... ...
-- 复合链接: 知识点:复合主键 就是多了一个判断条件
join 表 on ... and ...
-- 隐式链接 
把 join on 用 where 代替 尽量不使用where
```

#### 外连接查询:

> 内连接如果不满足 on 的条件不会返回
>
> 外连接会以 left/right 为主表 不满足也会返回
>
> outer join (outer可以省略)
>
> - 两种:
>   - 左连接: left join (一般情况使用左连接)
>   - 右链接: right join





sql

```sql
-- 多表连接
例子:
SELECT
    o.order_date,
    o.order_id,
    c.first_name AS customer,
    s.`name` AS shipper,
    os.NAME AS 'status' 
FROM
    orders o
    JOIN customers c ON o.customer_id = c.customer_id
    LEFT JOIN shippers s ON s.shipper_id = o.shipper_id
    JOIN order_statuses os ON os.order_status_id = o.`status`
-- using(列1,列2...)
using(列1,列2...)
可以替换掉 on 但是要求要查询的两个表的的列明相等 当然也可以给多个参数用, 隔开
```

#### 其他链接查询

- 自然连接 natural join:
  数据库引擎自动匹配 不建议使用
- 交叉连接:

> 将两个表的数据交叉组合(三种饮料和三种杯子尺寸 交叉连接出所有状态)





sql

```sql
表1 CROSS JOIN 表2 (建议使用)
from 表1, 表2  
```

- 联合查询(UNION)

> 将多个查询结构集,合成一个 列数要相同, 列明取第一个查询语句





sql

```sql
select 1... union select 1... union select 1... ...
```

#### 复杂查询





sql

```sql
-- 子查询（嵌套查询)
一个查询语句的结果是另一个的条件
select * from 表 where a = （ select ..） 
```

#### 相关子查询





sql

```sql
-- 在嵌套查询中有用到嵌套外的数据 (缺点: 慢,内存消耗高)
select * from 表 a where val > (select val from 表 b where a.id = b.id)  
```

##### 子查询在 select 和 from中使用





sql

```sql
-- 计算和和平均值做差  在select中
SELECT
    c.client_id,
    ( SELECT SUM( invoice_total ) FROM invoices WHERE c.client_id = client_id  ) AS sum1_total,
    ( SELECT AVG( invoice_total ) FROM invoices ) AS avg_total,
    ( SELECT sum1_total ) - ( SELECT avg_total ) 
FROM
    `invoices` i,
    clients c 
    WHERE 条件
```

### 插入/复制





sql

```sql
-- 增加数据
-- defaut 表示默认
insert into 表名 value( defaut ,字段值1,值2,值3) ;
insert into 表名(字段名1,名2名3) value(字段值1,值2,值3) ;
-- 多行插入
insert into 表(字段...) values (值...),(值...) ... 插入多个数据
-- 多表 插入
LAST_INSERT_ID() -- 最近插入ID
-- 复制表
create table 表 select... -- 创建一个你查询出来的表
insert into 表 select...  -- 插入一个你查询的表
```

### 更新/删除





sql

```sql
-- 更新
update 表名 set 字段1 = 值1, 字段2 = 值2... where 字段位置 = 值;
-- 多行更新
UPDATE 表名 SET 字段1 = 值1+50,字段2 = 值2... WHERE 条件 -- 条件可以选定多行数据
-- 在update中使用 select
嵌套查询结果集
UPDATE 表名 SET 字段1 = 值1 WHERE 列1=( select 语句)
--------------删除--------------
delete / truncate table 表名;  删除全表
delete from 表名 where 字段名 = 字段值;
当然可以嵌套select语句:
delete 表名 WHERE 列1=( select 语句)
```

## 一些函数、关键字





sql

```sql
-- 判断空
IFNULL(a,b) 如果第一个a是空那么返回b
```

### 关键字





sql

```sql
-- in/not in
in / not in
当子查询是一个集合 就用 in
select * from 表 where a in （ select ..） 
-- ALL 查询
-- 表示括号里的全部  (> ALl) 大于全部
select * from 表 where 字段 > ALL (1,2,3,4....);
-- = ANY / SOME  (= ANY  和  IN 等效)
-- 返回一个集合中所有条件的
select * from 表 where 字段 = ANY (1,2,3,4....);
-- explain + 语句
查看性能 sql优化
```

## 视图

> 视图数据是同步的(数据同步的)
>
> 创建视图时 **不使用** Distinct / union 以及 sum / group by … 聚合函数 的view 就是可更新表
>
> 视图可以减小数据库设计改动的影响 简化查询操作





sql

```sql
-- 创建视图
CREATE VIEW clients_balance AS select ... 把查询的东西存进去
create or replace  或者用这个语句 
-- 删除视图
drop view name
-- 修改视图 防止数据被删掉
在创建视图后加上
with check option
```

## 存储过程





sql

```sql
-- 创建函数(存储过程) 
CREATE PROCEDURE get_invoices_and_balance() -- 参数 相当于函数的参数
BEGIN
SELECT
    * 
FROM
    invoices 
WHERE
    ( invoice_total - payment_total ) > 0;
END
-- 定义结束符号
DELIMITER $$ 
DELIMITER ;
-- 添加参数 当然查询时也要加参数
CREATE PROCEDURE name ( valName1 TYPE1,valName2 TYPE2 ) 
BEGIN 
-- 如果要判断条件
IF valName1 is null and valName2 is NULL THEN
ELSE
END IF;
```





sql

```sql
-- 执行过程
CALL get_invoices_and_balance;
-- 删除过程 If exists 判断是否存在 可以不加
drop procedure If exists name;
```

## 数据结构

sql 可以存的格式

- String
- Number
- Data and Time
- Blob
- Spatial

### 1. 常见的String

|      | Name       | MAX                     |
| :--- | :--------- | :---------------------- |
| 1    | char()     | 固定长度                |
| 2    | varChar()  | 65000 Characters(~64kb) |
| 3    | mediumText | 16MB                    |
| 4    | longT`ext  | 4GB                     |
| 5    | TinyText   | 255 bytes               |
| 6    | Text       | 64kb                    |

### 2. 整数类型

|      | Data type | Bytes |
| :--- | :-------- | :---- |
| 1    | TINYINT   | 1     |
| 2    | SMALLINT  | 2     |
| 3    | MEDIUMINT | 3     |
| 4    | INTEGER   | 4     |
| 5    | BIGINT    | 8     |

### 3. 浮点数

|      | Data type         | explain                       |
| :--- | :---------------- | :---------------------------- |
| 1    | Decimal(P, S)     | p: 位数 s: 小数 位 (比较精准) |
| 2    | Dec/Numeric/Fixed | 和上面名字不同                |
| 3    | Float / Double    | 科学计数 不是特别精准         |

### 4. 时间

存储时间

1. Data:
2. Time:
3. Datetime: 8b
4. Timestamp: 4b (因为4b所以会有2038问题(时间存储会出问题) 好奇可以搜索一下)
5. Year

### 5. blob类型

存储所有的二进制结构的文件: 图片 pdf word 等等

|      | Data type  | size |
| :--- | :--------- | :--- |
| 1    | TinyBlob   | 225b |
| 2    | Blob       | 65kb |
| 3    | mediumBlob | 16mb |
| 4    | LongBlob   | 4gb  |

**因为将数据库中存入文件会将数据库变得很大. 而且读取效率 备份时间 以及开发代码 都会变得多 所以考虑存储文件前 线考虑这些问题**

### 6 Json

mysql 8 以后开始支持

- Json

- 写: Json_Object(json对象)

- 查询

  

  

  sql

  ```sql
  select id, properties -> '$. name.childName' from *** where ***
   properties ->> '$. name.childName' : 值读取值
  ```

  - json函数 很多都比较方便 可以试试

### . 布尔, 集合和枚举

1. bool / boolean: T/F (1/0)

2. set 并不是很好用

3. enum(A,B,C) 也不是很建议使用: 是固定的 而且

   ## 数据库设计

这一部分只是大概介绍一下： 因为需要很多实践就不放在这里了

如果需要设计一个数据库：

1. Understand the requirements（了解需求是很重要的）
2. 建立 **概念，逻辑，实体** 模型

### 模型建立

数据库概念模型实际上是现实世界到机器世界的一个中间层次。侧重于具体的功能在实际世界的实现，

逻辑模型在概念模型的基础上更细化。 更侧重于数据库的实现



![概念模型和概念模型](https://i.loli.net/2020/12/20/USWmxrKMesuA5To.png)

**概念模型和概念模型**



实体模型：具体的数据库模型

主键：数据库标识（唯一的） 还可以复合主键

外键： 如果一个字段X在A表中是主关键字，而在另外一张表B表中不是主关键字，则字段X称为表二的外键；

- 外键约束： 虽说主键尽量不可修改 但是外键有 对应修改和删除的操作：

  ==**on delete/update 规则：**==

  1. CASCADE：级联

     （1）所谓的级联删除，就是删除主键表的同时，外键表同时删除。

  2. NO ACTION(非活动，默认)、RESTRICT：约束/限制

     当取值为No Action或者Restrict时，则当在主键表中删除对应记录时，首先检查该记录是否有对应外键，如果有则不允许删除。（即外键表约束主键表）

     **NO ACTION**和**RESTRICT**的区别：只有在及个别的情况下会导致区别，前者是在其他约束的动作之后执行，后者具有最高的优先权执行。

  3. SET NULL

     当取值为Set Null时，则当在主键表中删除对应记录时，首先检查该记录是否有对应外键，如果有则设置子表中该外键值为null（一样是外键表约束主键表，不过这就要求该外键允许取null）。

#### 标准化

数据库七大约束中三范式最为重要 ： 保证了数据库的不冗余， 便捷等

### 数据库三范式

1. 表的每一列都是**不可分割的原子数据**
2. 非主键必须**完全依赖于主键**
3. 非主键必须**直接**依赖主键(不能有传递和间接关系)

##### 实际应用

其实这些范式我记的并不全面，而且实际应用当中 *并不一定严格准守这些约束* 尽可能的消除冗余就好了。

1. 但是 尽量先建立模型 ， 在建立数据库， 否则会很糟糕。
2. 但是 并不一定都需要建模， 因为建模可能和实际不符合，并且过于复杂且无用，值需要为当下确定一个可行方案， 而不是想要设计一个永远不出问题的模型

- 模型正向工程： 我们创建了模型 – 将模型转换为脚本 – 执行 （可以同步修改表和模型）
- 模型逆向工程： 将数据库转换为 模型



![image.png](https://i.loli.net/2020/12/21/WtrYFqwLo5fkzS9.png)

**image.png**



- 练习 [航空系统](https://sunxinan12138.github.io/2020/07/07/Mysql/todo) 链接

## 数据库保护

因为一直在本地运行，如果在真实项目要考虑安全问题

### 用户和权限

CURD 管理可访问到数据库的用户





sql

```sql
CREATE USER join11 @172.0.0.1 IDENTIFIED BY '123123';
CREATE USER join11 IDENTIFIED BY '123123';
SELECT    * FROM    mysql.`user`;
DROP USER join11 @172.0.0.1;
------------
权限：
GRANT 权限 on tablename from name -- 增加
ROvoke 。。。 -- 撤销
```

[Mysql所有权限](https://blog.csdn.net/weixin_30892763/article/details/95682481)

| Privilege                                                    | Column                   | Context                               |
| :----------------------------------------------------------- | :----------------------- | :------------------------------------ |
| [`CREATE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create) | `Create_priv`            | databases, tables, or indexes         |
| [`DROP`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_drop) | `Drop_priv`              | databases, tables, or views           |
| [`GRANT OPTION`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_grant-option) | `Grant_priv`             | databases, tables, or stored routines |
| [`LOCK TABLES`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_lock-tables) | `Lock_tables_priv`       | databases                             |
| [`REFERENCES`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_references) | `References_priv`        | databases or tables                   |
| [`EVENT`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_event) | `Event_priv`             | databases                             |
| [`ALTER`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_alter) | `Alter_priv`             | tables                                |
| [`DELETE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_delete) | `Delete_priv`            | tables                                |
| [`INDEX`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_index) | `Index_priv`             | tables                                |
| [`INSERT`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_insert) | `Insert_priv`            | tables or columns                     |
| [`SELECT`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_select) | `Select_priv`            | tables or columns                     |
| [`UPDATE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_update) | `Update_priv`            | tables or columns                     |
| [`CREATE TEMPORARY TABLES`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-temporary-tables) | `Create_tmp_table_priv`  | tables                                |
| [`TRIGGER`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_trigger) | `Trigger_priv`           | tables                                |
| [`CREATE VIEW`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-view) | `Create_view_priv`       | views                                 |
| [`SHOW VIEW`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_show-view) | `Show_view_priv`         | views                                 |
| [`ALTER ROUTINE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_alter-routine) | `Alter_routine_priv`     | stored routines                       |
| [`CREATE ROUTINE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-routine) | `Create_routine_priv`    | stored routines                       |
| [`EXECUTE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_execute) | `Execute_priv`           | stored routines                       |
| [`FILE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_file) | `File_priv`              | file access on server host            |
| [`CREATE TABLESPACE`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-tablespace) | `Create_tablespace_priv` | server administration                 |
| [`CREATE USER`](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_create-user) | `Create_user_priv`       | server administration                 |
| [PROCESS](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_process) | `Process_priv`           | server administration                 |
| [PROXY](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_proxy) | see `proxies_priv` table | server administration                 |
| [RELOAD](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_reload) | `Reload_priv`            | server administration                 |
| [REPLICATION CLIENT](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_replication-client) | `Repl_client_priv`       | server administration                 |
| [REPLICATION SLAVE](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_replication-slave) | `Repl_slave_priv`        | server administration                 |
| [SHOW DATABASES](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_show-databases) | `Show_db_priv`           | server administration                 |
| [SHUTDOWN](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_shutdown) | `Shutdown_priv`          | server administration                 |
| [SUPER](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_super) | `Super_priv`             | server administration                 |
| [ALL [PRIVILEGES\]](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_all) |                          | server administration                 |
| [USAGE](https://dev.mysql.com/doc/refman/5.7/en/privileges-provided.html#priv_usage) |                          | server administration                 |

------

## InnoDB和MySAM

- 现在都是默认使用InnoDB
- MySAM 比较老,以前用

> 区别:

|              | MySAM                | INNODB               |
| :----------- | :------------------- | :------------------- |
| 事务         | 不支持               | **支持**             |
| 数据锁定方式 | 表锁定               | **行锁定**           |
| 外键约束     | 不支持               | **支持**             |
| 全文索引     | **支持**             | 不支持               |
| 表空间大小   | 小                   | 大,约为MySAM的两倍   |
| 聚集索引     | 比普通索引多了个约束 | 叶子节点就是数据节点 |

> 在物理空间:

所有数据库都是以文件形式存储在data目录下,一组文件对应一个数据库,本质还是文件存储

Mysql引擎

- INNODB在数据库上只有一个*.frm, 以及上级目录的ibdata1文件
- MySAM
  - *.frm 表结构
  - *.myd 数据文件(data)
  - *.MYI 索引文件(index)

## 索引

MySQL官方对索引的定义为：索引（Index）是帮助MySQL高效获取数据的数据结构。提取句子主干，就可以得到索引的本质：索引是数据结构。

IO次数和数据结构的次数有关(树 – 就是高度) , 如果没有索引那就是一个数据一次IO

### 优缺点

https://zhuanlan.zhihu.com/p/29118331

### 分类

mysql的索引分为单列索引(主键索引(聚集索引),唯一索引(UNIQUE INDEX),普通索引(INDEX ))和组合索引.

单列索引:一个索引只包含一个列,一个表可以有多个单列索引.

组合索引:一个组合索引包含两个或两个以上的列,

------

聚集索引: 数据行的物理顺序与列值的**顺序相同**

非聚集索引: 该索引中索引的逻辑顺序与磁盘上行的物理存储顺序不同，一个表中可以拥有多个非聚集索引。(普通索引，唯一索引，全文索引)

回表查询解决方式: 复合索引（覆盖索引）





sql

```sql
-- 组合
CREATE INDEX IndexName On `TableName`(`字段名`(length),`字段名`(length),...);
```

覆盖索引: select 的 和查找的都是索引

> 索引的数据结构:

哈希:

B树

B+树

> 索引
>
> https://www.jianshu.com/p/2879225ba243

## LOG

*TODO：*

- P52 - p63 一些函数和语句: 我跳了
- P74 - P84 存储过程的其他东西 和 触发器 我跳了
- 还差索引
- 整理

## 参考资料

[Mysql调优 – explain](https://blog.csdn.net/jiadajing267/article/details/81269067)

[MySQL索引背后的数据结构及算法原理](http://blog.codinglabs.org/articles/theory-of-mysql-index.html)
