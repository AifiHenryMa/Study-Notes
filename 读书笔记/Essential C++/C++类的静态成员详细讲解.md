# 前言
在C++中，静态成员是属于整个类的而不是某个对象，静态成员变量只存储一份供所有对象共用。所以在所有对象中都可以共享它。使用静态成员变量实现多个对象之间的数据共享不会破坏隐藏的原则，保证了安全性还可以节省内存。静态成员的定义或声明要加个关键static。静态成员可以通过双冒号来使用即<类名>::<静态成员名>。

在C++中类的静态成员变量和静态成员函数是个容易出错的地方，本文先通过几个例子来总结静态成员变量和成员函数使用规则，再给出一个实例来加深印象。希望阅读本文可以使读者对类的静态成员变量和成员函数有更为深刻的认识。

# 第一个例子，通过类名调用静态成员函数和非静态成员函数

```c++
class Point {
public:
    void init()
    {
    }

    static void output()
    {
    }
};

void main()
{
    Point::init();
    Point::output();
}
```

**编译出错**：error C2352: 'Point::init' : illegal call of non-static member function

**结论1**：不能通过类名来调用类的非静态成员函数。


# 第二个例子，通过类的对象调用静态成员函数和非静态成员函数

将上例的main()改为：
```c++
void main() {
    Point pt;
    pt.init();
    pt.output();
}
```

**编译通过**。

**结论2**：类的对象可以使用静态成员函数和非静态成员函数。

# 第三个例子，在类的静态成员函数中使用类的非静态成员

```c++
#include <iostream>

class Point {
public:
    void init()
    {
    }
    static void ouput()
    {
        printf("%d\n", m_x);
    }

private:
    int m_x;
};

void main()
{
    Point pt;
    pt.output();
}
```

**编译出错**：error C2597: illegal reference to data member 'Point::m_x' in a static member function

因为静态成员函数属于整个类，在类实例化对象之前就已经分配空间了，而类的非静态成员必须在类实例化对象后才有内存空间，所以这个调用就出错了，就好比没有声明一个变量却提前使用它一样。

**结论3**：静态成员函数中不能引用非静态成员。

# 第四个例子，在类的非静态成员函数中使用类的静态成员

```c++
class Point 
{
public:
    void init()
    {
        output();
    }
    static void output()
    {
    }
};
void main()
{
    Point pt;
    pt.init();
}
```

**编译通过**。

**结论4**：类的非静态成员函数可以调用静态成员函数，但反之不能。

# 第五个例子，使用类的静态成员变量

```c++
class Point
{
public:
    Point()
    {
        m_nPointCount++;
    }

    ~Point()
    {
        m_nPointCount--;
    }

    static void output()
    {
        printf("%d\n",m_nPointCount);
    }

private:
    static int m_nPointCount;
};

void main()
{
    Point pt;
    pt.output();
}
```

**编译出错**：error LNK2001: unresolved external symbol "private: static int Point::m_nPointCount" (?m_nPointCount@Point@@0HA)

这是因为类的静态成员变量在使用前必须先初始化。在main()函数前加上int Point::m_nPointCount = 0;再编译链接无错误，运行程序将输出1。

**结论5**：类的静态成员变量必须先初始化再使用。

# 总结

结合上面的五个例子，对类的静态成员变量和成员函数做个总结：
- 一、静态成员函数中不能调用非静态成员；
- 二、非静态成员函数中可以调用静态成员。因为静态成员属于类本身，在类的对象产生之前就已经存在了，所以在非静态成员函数中是可以调用静态成员的。
- 三、静态成员变量使用前必须先初始化（如int MyClass::m_nNumber = 0;）,否则会在linker时出错。

再给一个利用类的静态成员变量和函数的例子以加深理解，这个例子是建立一个学生类，每个学生类的对象将组成一个双向链表，用一个静态成员变量记录这个双向链表的表头，一个静态成员函数输出这个双向链表。

```c++
#include "stdafx.h"
#include <iostream>
#include <string>
const int MAX_NAME_SIZE = 30;

class Student
{
public:
    Student(char *pszName);
    ~Student();

public:
    static void PrintfAllStudents();

private:
    char m_name[MAX_NAME_SIZE];
    Student *next;
    Student *prev;
    static Student *m_head;
};

Student::Student(char *pszName)
{
    strcpy(this->m_name, pszName);

    // 建立双向链表，新数据从链表头部插入。
    this->next = m_head;
    this->prev = NULL;
    if ( m_head != NULL )
        m_head->prev = this;
    m_head = this;
}

Student::~Student() // 析构过程就是节点的脱离过程
{
    if ( this == m_head ) // 该节点就是头节点。 
    {
        m_head = this->next;
    }
    else 
    {
        this->prev->next = this->next;
        this->next->prev = this->prev;
    }
}

void Student::PrintfAllStudents()
{
    for ( Student *p = m_head; p != NULL; p = p->next )
        printf("%s\n", p->m_name);
}
Student* Student::m_head = NULL;    
  
void main()    
{     
    Student studentA("AAA");  
    Student studentB("BBB");  
    Student studentC("CCC");  
    Student studentD("DDD");  
    Student student("MoreWindows");  
    Student::PrintfAllStudents();

    system("pause");
}  

```

