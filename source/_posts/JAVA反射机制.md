---
title: JAVA反射机制
author: 熙男
date: 2021-07-25 17:22:04
categories:
tags:
---

# 反射

## 反射概述

### 动静态语言

> - 动态语言
>   1. 运行时可以改变其结构的语言:Object-c, C#, JavaScript, PHP, Python等
> - 静态语言
>   1. 运行时结构不可变的语言:Java,C,C++
>
> 但是! Java虽不是动态语言, 但可以称为**“准动态语言”**. 因为Java有一定的动态性,可以利用Java的**反射机制**获得动态语言的特性. 可以让编程更灵活

### Reflection

> **Reflection(反射)** 是Java被视为动态语言的关键.反射机制是程序执行期间借助于Reflection API获取到**任何类的内部信息,并能直接操作任意对象的内部属性和方法**
>
> 加载完类之后, 在堆内存的方法去中就产生了一个Class类型的对象(对于每个类是唯一一个), 这个对象包含了**完整的类的结构信息**. 通过这个对象看到类的结构. 这个对象像个镜子, 透过这个镜子看到了类的结构 ,所以我们叫反射
>
> ![image.png](https://i.loli.net/2020/06/06/1YROeXfwlsizrCS.png)
>
> **image.png**

### JAVA反射机制的优缺点

> - 优点: 很明显它实现了动态创建和编译, 大大增加灵活性
> - 缺点: 对性能有影响,. 因为反射是一个解释操作, 告诉JVM,我们需要做什么来完成操作. 肯定慢于直接操作

## 1. 类加载和初始化的

> 想要了解反射机制先了解到底类加载是怎么运行的还有初始化时JVM发什么什么

### 类加载内存分析

> - Jvm中的内存部分:
>
>   1. 堆:
>
>       
>
>      存放new的对象和数组 (垃圾收集器,监控的就是这部分对象)
>
>      1. 可被所有线程共享, 不会存放别的对象引用
>
>   2. **栈:** 存放基本变量类型(会包含这个基本类型的具体数值),引用对象的变量(存的是这个引用在堆里的地址)
>
>   3. **方法区:** 可悲线程共享/ 包含所有的calss和static变量
>
> - 类加载的过程
>
>   当程序主动使用某个类, 如果该类还未被夹在到内存中, 则会发生下面的步骤:
>
>   
>
>   ![类加载的过程](https://i.loli.net/2020/06/07/hqkj6iWFR1vc9Ga.png)
>
>   **类加载的过程**
>
>   
>
>   1. **加载:** 将class文件字节码加载到内存,将静态数据转换成方法去的运行时数据结构,然后生成一个java.lang.Class对象(堆).
>
>   2. 链接:
>
>       
>
>      将二进制(字节码)代码合并到JVM运行状态中
>
>      1. ==验证==:确保加载的信息符合JVM规范
>      2. ==准备==:正式为类变量(static)分配内存,并设置初值– Java对象变量的默认值
>      3. ==解析==:虚拟机常量池内的符号引用(常量名)替换为直接引用(地址)
>
>   3. **初始化:** 执行类构造器的()方法的过程: 下面细说

### 类的初始化 – 赋初值

> - 初始化: 顺序是: ***先静态对象，后非静态对象，且静态初始化动作只进行一次\***
>
>   1. 类构造器()方法是由编译器自动收集类中**所有**的**类变量**赋值和**静态**代码块的操作(类构造器是构造类的, 不是构造该对象的)
>   2. 如果初始化时发现父类没有初始化,则初始化父类
>   3. 虚拟机会保证()方法在多线程中能正确加锁和同步
>
>   > clinit 只有静态才会生效 而且只有一次 init 在实例化时生效
>
>   - 实例化步骤为：先为属性分配空间，再执行赋默认值，然后按照顺序执行代码块或赋初始值，最后执行构造方法
>
> - 类什么时候初始化:
>
>   1. 类的主动引用(一定发生初始化)
>      1. 一定初始化main方法所在的类
>      2. new对象
>      3. 通过类调用静态成员(除了final)和静态方法
>      4. 反射调用(forName(“”))
>      5. 如果初始化时发现父类没有初始化,则初始化父类
>   2. 类的被动引用(不会发生初始化)
>      1. 访问一个静态域时, 如果没有声明这个域的类(比如子类调用父类的静态变量)就不会初始化
>      2. 通过数组定义引用 – 只会分配空间 (类A[] a = new 类A[len])
>      3. 引用常量不会触发此类的初始化 ( 常量在链接阶段就存入了常量池)
>
> 
>
> ![JVM.png](https://i.loli.net/2020/06/30/pJrK6LaXGIATNFd.png)
>
> **JVM.png**

### 类加载器

> 如果需要查找一个class对象的时候 先查找内存三种加载器一次查找 如果没有从底层加载器加载 如果都没有抛出ClassNotFoundException 或者调用自己加载器的findClass方法加装
>
> 1. 好处: 类不重复加载
> 2. 不会产生核心类被后来的覆盖
>
> 
>
> ![双亲委派](https://i.loli.net/2020/09/14/FouWQYTv6GM8zdh.png)
>
> **双亲委派**

> 类加载器就是**将class文件字节码内容加载到内存中**,并将这些静态数据转换成方法去的运行时的数据结构,在堆中生成一个java.lang.class对象,作为访问入口
>
> 类缓存: 标准JavaSE类加载器,可以按要求查找类, 一旦某个类被夹在将有一段时间缓存
>
> 1. 引导类加载器: 底层由C++编写, java自带的加载器, **负责java核心库(rt.jar)**, 装在核心类库. 这个无法直接获取
>
> 2. 扩展类加载器:负责jre/lib/ext下的jar包或者java.ext.dirs指定目录的jar加载
>
>    **sun.misc.Launcher$ExtClassLoader@1d4e2ba**
>
>    
>
>    
>
>    java
>
>    ```java
>      // 系统类的父类  扩展类 
>    ClassLoader parent = loader.getParent();
>    System.out.println(parent);
>    ```
>
> 3. 系统类加载器: 最常用的,负责java-classpath或java.class.path所指向的目录下的类与jar包的加载
>
>    **sun.misc.Launcher$AppClassLoader@dad5dc**
>
>    
>
>    
>
>    java
>
>    ```java
>       // 获取系统类加载器  
>    ClassLoader loader = ClassLoader.getSystemClassLoader();
>    ```
>
>    ------
>
>    系统类 -> 扩展类 -> 引导类 以及自定义加载器
>
> 
>
> 
>
> java
>
> ```java
> // 查看系统内类加载器可以加载的路径
>   System.out.println(System.getProperty("java.class.path"));
> ```
>
> 
>
> ![image.png](https://i.loli.net/2020/06/07/Dlpi7uRVcFm3MoT.png)
>
> **image.png**

## Class对象

> 在Object类下有一个getClass()方法,返回值是一个Class类.所有类都默认继承Object类.public final Class getClass()
>
> 是Java反射的源头, 所以反射理解为: 可以通过对象反射找到对应的类
>
> 
>
> ![image.png](https://i.loli.net/2020/06/06/9fyt2kRnvHcCihs.png)
>
> **image.png**

#### 获取Class类的方法

> 1. 已知具体类, 通过class属性来获取, 该方法**最为安全可靠**,程序性能最高
>
>    
>
>    
>
>    java
>
>    ```java
>      Class<Cat> c1 = Cat.class;
>    ```
>
> 2. 已知某个类的实例,调用它的getClass方法获取Class对象
>
>    
>
>    
>
>    java
>
>    ```java
>    Cat cat = new Cat();
>    Class c3 = cat.getClass()
>    ```
>
> 1. 已知一个类的**限定类名**,且在类路径下, 可以通过Class的静态方法forName()获取
>
>    
>
>    
>
>    java
>
>    ```java
>    Class c2 = Class.forName("com.sjs.Reflect.Cat");
>    ```
>
> 1. 内置基本数据类型可以直接调用**类名.Type**
>
>    
>
>    
>
>    java
>
>    ```java
>    Class<Integer> type = Integer.TYPE;
>    ```
>
> 1. 还可以用ClassLoader
>
>    > 只要是获取到**同一个类的Class对象都是一个对象**
>    >
>    > 
>    >
>    > 
>    >
>    > java
>    >
>    > ```java
>    >         System.out.println(c1.hashCode());
>    >         System.out.println(c2.hashCode());
>    >         System.out.println(c3.hashCode());
>    > ```
>    >
>    > 我们把上面的对象用hashCode()输出数据相同

#### Class类的常用方法

> 1. **Class getSuperClass():** 返回当前类的父类
> 2. **static ClassforName(String name):** 返回指定类名name的Class对象
> 3. **Object newInstance():** 调用缺省构造函数,返回Class对象的一个实例
> 4. **getName():** 返回Class对象所表示的实体(类, 接口等)的名称
> 5. **Class[] getInterfaces():** 返回当前Class对象的接口
> 6. **ClassLoader getClassLoader():** 返回该类的类加载器

## 2. 获取类的运行时结构

> 通过反射可以获取运行时的类的完整结构
>
>  反射创建类的Class对象Class catCl = Class.forName("com.sjs.Reflect.Animal");
>
> 1. 获取属性
>
>    
>
>    
>
>    java
>
>    ```java
>    catCl.getFields(); // 获取所有public属性
>    catCl.getDeclaredFields();// 获取所有属性
>    ```
>
> 2. 获取方法
>
>    
>
>    
>
>    java
>
>    ```java
>    catCl.getMethods(); // 获取包括父类的所有public方法
>    catCl.getDeclaredMethods();// 获取其他权限的方法
>       System.out.println(catCl.getDeclaredMethod("方法名字", 参数类型.class)); // 获取指定方法
>    ```
>
> 3. 获取构造器
>
>    
>
>    
>
>    java
>
>    ```java
>       // 获取构造器
>            catCl.getConstructors();// 获取 public所有构造器
>            catCl.getDeclaredConstructors();// 获取 public所有构造器
>    ```
>
> 4. 等等,,,能获取到类的完整结构(接口,注解, 父类………)

## 动态创建对象,调用运行时类中的结构

> - 动态创建:
>
>   
>
>   
>
>   java
>
>   ```java
>   Animal aninmalIns = (Animal) animal.newInstance(); // 反射获得的类实例创建实例
>   /*************************************************************************/
>    //调用指定构造器创建对象
>   Constructor<?> constructor = animal.getDeclaredConstructor(String.class);// 用参数来确定构造方法
>   constructor.setAccessible(true); //设置访问权限拦截(true不拦截) 因为这个构造是私有的
>   Object o = constructor.newInstance("参数");
>   ```
>
> - 调用运行时的方法
>
>   
>
>   
>
>   java
>
>   ```java
>   Animal animal1 = (Animal) animal.newInstance(); // 创建出声明类实例
>   // 调用方法
>   // 创建出Method对象
>   Method setName = animal.getDeclaredMethod("setName", String.class);// 方法参数名字和类型
>   setName.invoke(animal1, "参数"); // 参数对象是声明类的实例
>   ```
>
> - 调用属性
>
>   
>
>   
>
>   java
>
>   ```java
>    // 访问和修改属性
>   Field name = animal.getDeclaredField("name");// 属性名称
>   name.setAccessible(true);// 由于是私有修改拦截方式
>   name.set(animal1, "tuyi"); // set 将对象和参数传入
>   ```

> - class对象可以创建类的对象, 可以访问所有权限的方法和属性
> - **invoke(Object obj, Object args[])方法** 用反射创建出Method对象,用此方法调用 ,参数是类的对象和参数
> - setAccessible(boolen par)
>   1. Method, Field, Constructor对象都有setAccessible()方法
>   2. 是用来启动或者禁用访问安全检查的开关
>   3. true为取消java语言访问检察
>      1. **提高反射效率**, 如果必须用反射, 设置为true
>      2. 可以访问私有结构
>   4. false则为反射的对象开启Java语言访问检察

## 练习:通过注解和反射完成简单的类和表结构的映射关系(ORM)





java

```java
// 注解类
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface DBAnnotation {
    String value(); // 库名
}

@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@interface FieldsSJS {
    String column(); // 列明

    String type(); // 数据类型

    int len(); // 长度
}
```





java

```java
// pojo类
@DBAnnotation("student")
class Student {
    @FieldsSJS(column = "id", type = "int", len = 2)
    private int id;
    @FieldsSJS(column = "id", type = "varChar", len = 10)
    private String name;


    public Student() {

    }

    public Student(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```





java

```java
// 测试类
public class ORMExercise {
    public static void main(String[] args) throws ClassNotFoundException, IllegalAccessException, InstantiationException {
        Class studentDB = Class.forName("com.sjs.Exercise.Student");
        Student s = (Student) studentDB.newInstance();
        DBAnnotation dbAnnotation = (DBAnnotation) studentDB.getAnnotation(DBAnnotation.class);
        System.out.println("当前表是: " + dbAnnotation.value());

        Field[] fields = studentDB.getDeclaredFields();
        for (Field field : fields) {
            FieldsSJS fieldsjs = field.getAnnotation(FieldsSJS.class);
            System.out.println("类中的参数是:" + field.getName());
            System.out.print("列名字:" + fieldsjs.column() + "\t");
            System.out.print("长度:" + fieldsjs.len() + "\t");
            System.out.print("类型:" + fieldsjs.type() + "\t");
            System.out.println();
        }

    }
}
```



![image.png](https://i.loli.net/2020/06/08/euOnThtcEdpokG4.png)

**image.png**



clinitclinit
