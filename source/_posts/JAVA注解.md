---
title: JAVA注解
author: 熙男
date: 2021-07-25 17:18:45
categories:
tags:
---

# 注解

## 基本概述

> - Annotation(注解):
>   1. 作用:
>      1. 对程序作出解释(和注释(comment)一样)
>      2. 可以被其他程序读取(编译器等)
>   2. 格式 – @注释名(参数)
>   3. 作用于package/class/method/field等上, 给他们添加了额外的辅助信息,可以通过反射机制对这些元数据进行访问

## 部分常见注解

> 1. **@Override:** 重写超累的方法
>
> 2. **@Deprecated:** 定义为废弃的,不推荐使用, 或者有更好的选择
>
> 3. SuppressWarnings:
>
>     
>
>    用来抑制编译时 的警告信息(强迫症福利??) 有参数:
>
>    1. (“all”)/(“Unchecked”)/(value = {“unchecked”,”deprecation”})

## 元注解

> 元注解(Meta-Annotation) 用来注解其他注解, java提供了四个标准元注解
>
> - 这些类型和支持的类在(java.lang.annotation)包中
>
>   1. **@Target:** 描述作用范围
>   2. **@Retention:** 表示保存注释的级别, 描述注释的生命周期(SOURCE<CLASS<**RUNTIME**)
>   3. **@Document:** 说明该注释被包含在javadoc中
>   4. **@Inherited:** 说明子类可以**继承**父类的注释
>
>   
>
>   
>
>   java
>
>   ```java
>   // 描述作用域(ElementTYpe)
>   //    TYPE, //接口、类、枚举、注解
>   //    FIELD,//字段、枚举的常量
>   //    METHOD,  //方法
>   //    PARAMETER,  //方法参数
>   //    CONSTRUCTOR,   //构造函数
>   //    LOCAL_VARIABLE,  //局部变量
>   //    ANNOTATION_TYPE, //注解
>   //    PACKAGE   //包
>   @Target(value = {ElementType.METHOD, ElementType.TYPE})
>   // 生命周期(RetentionPolicy)
>   //    SOURCE, // 源码
>   //    CLASS,  // 类
>   //    RUNTIME // 运行时
>   @Retention(value = RetentionPolicy.RUNTIME)
>   // 在javaDoc中
>   @Documented
>   // 子类可继承
>   @Inherited
>   @interface MyAnnotation {
>   }
>   ```

## 自定义注解

> 使用**@interface**来声明自定义注解,public @interface name{内容}
>
> - 自动继承Annotation接口
> - 对于参数
>   1. 格式: **类型 名称();**
>   2. 内部每一个方法其实是个参数 返回值类型就是参数类型(只能是基本类)
>   3. 可以通过default来默认参数
>   4. 如果只有一个参数成员, 一般命名为Value
>   5. 注解元素必须要有值,通常使用默认为: 空字符串和0





java

```java
/ 定义作用域
@Target({ElementType.METHOD, ElementType.TYPE})
// 定义生命周期
@Retention(RetentionPolicy.RUNTIME)
@interface Demo1 {
    // 参数格式: 类型 名字();
    // 如果只有一个参数建议使用value 因为填写参数时可以省略(value = )
    String value();

    int id() default -1; // 设置默认值 如果为-1 则不存在

    String[] tel() default {};
}
```

## 注解开发

元注解灵活使用

通过反射来动态获取注解的参数





java

```java
Class userClass = User.calss;
AnnotationName name= userClass.getAnnotation(annotationName.class);
```
