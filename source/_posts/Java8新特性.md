---
title: Java8新特性
author: 熙男
date: 2021-07-25 17:22:18
categories:
tags:
---

[toc]



![image-20200923231111293](file:///C:/%5CUsers%5C25778%5CAppData%5CRoaming%5CTypora%5Ctypora-user-images%5Cimage-20200923231111293.png)

**image-20200923231111293**



# Java8新特性

## Lamda表达式

> λ表达式:
>
> 本质上也是函数式编程:
>
> 
>
> 
>
> java
>
> ```java
> (params) -> expression[表达式]
> (params) -> statement[语句]
> (params) -> {statements}
> ```
>
> - 使用原因
>   1. 避免匿名内部类过多
>   2. 代码看上去简洁
>   3. 去掉了冗余的代码,留下核心逻辑
> - 使用前提:
>   1. 一定是Function Interface(函数式接口) — Function Interface定义: 任何接口如果只包含唯一一个抽象方法, 那么这就是个函数式接口. 例如 Runnable

例子:





java

```java
// 写一个函数式接口
public Interface TestInterface{
    public void testmethod();
}

// 用lamda创建接口对象
public static void main(String[] args){
    // 匿名内部类实现 ,(我觉得Lamda表达式是匿名内部类的简化)
    new TestInterface(){
        // 重写方法
         @Override
            public void testmethod() {
            // 代码.....    
            }
    }.testmethod();//当然有参数的就可以添加参数
/*----------------------------------------------------*/  
    // Lamda表达式
   //Interface test1 = (参数)->{方法体};
     Interface test1 = () -> {
         // 代码....
            System.out.println(1);
        };
        a.testmethod();
}
```

## java四个函数式接口

|      | 函数式接口                                     | 参数类型        | 返回值          | 用途                                            |
| :--- | :--------------------------------------------- | :-------------- | :-------------- | :---------------------------------------------- |
| 1    | Consumer 消费型接口                            | T(泛型)         | void            | 对类型为T的对象应用操作                         |
| 2    | Supplier 供给型接口                            | 无              | T               | 安徽类型为T的对象                               |
|      | Function<T, K> 函数型                          | T               | R               | 参数有两个T和R – R.apply(T t)                   |
| 4    | Prediction 判断断定型接口                      | T               | Boolen          | 确定类型为T的对象是否满足约束,并且返回Boolean值 |
| 5    | BiFunction<T,U,R> 可以传递两个参数的函数型接口 | T,U             | R               | 可以传递两个参数                                |
| 6    | UnaryOperator Function的子接口                 | T               | T               | 对类型为T的对象进行操作 返回 操作后的T          |
| 7    | BinaryOperator BiFunction子接口                | T, T            | T               | 二元运算                                        |
| 8    | BiConsumer<T, U>                               | T U             | void            |                                                 |
| 9    | ToIntFunction ToLongFunction ToDoubleFunction  | T               | int Long double | 传参数返回不同类型数值                          |
| 10   | IntFunction LongFunction DoubleFunction        | int Long double | R               | 不同参数类型返回R                               |

Java巧用lambda，使用函数式接口 和lambda 可以让程序异步执行 (另外写一下) [可以看这里](https://www.jianshu.com/p/8a7aa7f93ddc?utm_campaign=hugo)

## 方法引用

> 若lambda体中的方法内容被实现了 就可以用**方法引用**的方式实现

- 对象::实例方法名
- 类::静态方法
- 类::实例方法

**使用 方法引用的方法的 ==方法的参数和返回值== 一定要和对应接口中 ==方法的参数和返回值==相等**

构造方法: 类A::new 会根据接口的 返回值和参数 自动匹配构造器





java

```java
    public static void main(String[] args) {
        method(StreamDemo::_TEST);
    }

    private static String _TEST(Object o) {
        System.out.println("操作1");
        return "000";
    }

    public static void method(MyFunction s) {
        System.out.println(s.apply(new Object()).toString() + "real");
    }
}
out:
/*操作1
000real*/
```

## stream流计算

> 流式计算

在项目中数据存储在数据库 集合等地方. 数据的处理就要交给流来计算

> 操作步骤

1. 创建Stream流

根据数据源 集合 数组中创建

1. 根据API操作数据

一个操作链进行选择排序,,,

1. 结束/终止操作

执行操作了链条产生结果 可以使用java7的try-with-resources

[API看这里](https://www.runoob.com/java/java8-streams.html)

举个🌰





java

```java
// id,age,name.major
class Student {}
public static void main(String[] args) {
        Student s1 = new Student(1, 12, "sjs", "jsj");
        Student s2 = new Student(2, 13, "zs", "dzx");
        Student s3 = new Student(3, 14, "ls", "dzx");
        Student s4 = new Student(4, 15, "ww", "xx");
        Student s5 = new Student(5, 16, "lb", "dzx");
        Student s6 = new Student(6, 17, "hhh", "jsj");
        List<Student> students = Arrays.asList(s1, s2, s3, s3, s4, s5, s6);
        // 根据集合创建一个流并操作
        /*
         * 去重
         * 找到id是偶数的
         * age 大于14的
         * 逆序排列
         * */
        Stream<Student> stream = students.stream().
                distinct().
                filter((a) -> a.getId() % 2 == 0).
                filter(a -> a.getAge() > 14).
                map(a -> a.setName(a.getName().toUpperCase())).
                sorted((a, b) -> b.getId() - a.getId());

        stream.forEach(System.out::println);
    }
```
