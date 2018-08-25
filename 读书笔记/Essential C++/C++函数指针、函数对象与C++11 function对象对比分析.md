# 1.函数指针

函数指针：是指指向函数的指针变量，在C编译时，每一个函数都有一个入口地址，那么这个指向这个函数的函数指针便指向这个地址。函数指针主要由以下两方面的用途：**调用函数**和**用作函数参数**。

函数指针的声明方法：

数据类型标识符 (指针变量名) (形参列表);

一般函数的声明为：

```c++
int func( int x );
```

而一个函数指针的声明方法为：

```c++
int (*func) ( int x );
```

前面的那个(*func)中括号是必要的，这会告诉编译器我们声明的是函数指针而不是声明一个具有返回型为指针的函数，后面的形参要视这个函数指针所指向的函数形参而定。

函数指针例子：

```c++
#include "stdafx.h"

#include<iostream>
#include<cstdlib>
#include<vector>
using namespace std;

int AddFunc(int a, int b)  
{  
    return a + b;  
}  
int main(){
    int (*Add1)(int a,int b);
    int (*Add2)(int a,int b);
    Add1 = &AddFunc;
    Add2 = AddFunc;//两种函数指针赋初值方法，可以加取地址符也可以不加
    cout << (*Add1)(3,2)<<endl; // 5
    cout<<Add1(3,2)<<endl;//输出可以加*，也可以不加
    system("pause");
    return 0;
}
```

# 2.函数对象

C++函数对象实质上是操作符重载，实现了对()操作符的重载。C++函数对象不是函数指针。但是，在程序代码中，它的调用方式与函数指针一样，后面加个括号就可以了。

函数对象例子：
```c++
int AddFunc(int a, int b)  
{  
    return a + b;  
}  
class Add{
public:
    const int operator()(const int a,const int b){
        return a+b;
    }
};
int main(){
    //函数指针
    int (*Add1)(int a,int b);
    int (*Add2)(int a,int b);
    Add1 = &AddFunc;
    Add2 = AddFunc;//两种函数指针赋初值方法
    cout << (*Add1)(3,2)<<endl; // 5
    cout<<Add1(3,2)<<endl;//输出可以加*，也可以不加

    //函数对象
    Add addFunction;
    cout<<addFunction(2,3)<<endl;
    system("pause");
    return 0;
}
```

函数对象和指针函数比较:

函数对象可以把附加对象保存在函数对象中是它最大的优点。它的弱势也很明显，它虽然用起来象函数指针，但毕竟不是真正的函数指针。在使用函数指针的场合中，它就无能为力了。例如，你不能将函数对象传给qsort函数！因为它只接受函数指针。另外，C++函数对象还有一个函数指针无法匹敌的用法：可以用来封装类成员函数指针。

# 3.C++11 函数对象

介绍：类模版std::function是一种通用、多态的函数封装。std::function可以对任何可以调用的实体进行封装，这些目标实体包括普通函数、Lambda表达式、函数指针、以及其它函数对象等。std::function对象是对C++中现有的可调用实体的一种类型安全的包裹（我们知道像函数指针这类可调用实体，是类型不安全的）。 
通常std::function是一个函数对象类，它包装其它任意的函数对象，被包装的函数对象具有类型为T1, …,TN的N个参数，并且返回一个可转换到R类型的值。std::function使用 模板转换构造函数接收被包装的函数对象；特别是，闭包类型可以隐式地转换为std::function。 
也就是说，通过std::function对C++中各种可调用实体（普通函数、Lambda表达式、函数指针、以及其它函数对象等）的封装，形成一个新的可调用的std::function对象；让我们不再纠结那么多的可调用实体。一切变的简单粗暴。

C++11 函数对象示例

```c++
#include <functional>
#include <iostream>
using namespace std;

std::function< int(int) > Functional;

// 普通函数
int TestFunc(int a)
{
    return a;
}

// Lambda表达式
auto lambda = [](int a)->int{ return a; };

// 仿函数(functor)
class Functor
{
public:
    int operator()(int a)
    {
        return a;
    }
};

// 1.类成员函数
// 2.类静态函数
class TestClass
{
public:
    int ClassMember(int a) { return a; }
    static int StaticMember(int a) { return a; }
};

int main()
{
    // 普通函数
    Functional = TestFunc;
    int result = Functional(10);
    cout << "普通函数："<< result << endl;

    // Lambda表达式
    Functional = lambda;
    result = Functional(20);
    cout << "Lambda表达式："<< result << endl;

    // 仿函数
    Functor testFunctor;
    Functional = testFunctor;
    result = Functional(30);
    cout << "仿函数："<< result << endl;

    // 类成员函数
    TestClass testObj;
    Functional = std::bind(&TestClass::ClassMember, testObj, std::placeholders::_1);
    result = Functional(40);
    cout << "类成员函数："<< result << endl;

    // 类静态函数
    Functional = TestClass::StaticMember;
    result = Functional(50);
    cout << "类静态函数："<< result << endl;

    return 0;
}
```

对于各个可调用实体转换成std::function类型的对象，上面的代码都有，运行一下代码，阅读一下上面那段简单的代码。总结了简单的用法以后，来看看一些需要注意的事项：

关于可调用实体转换为std::function对象需要遵守以下两条原则：

- (1) 转换后的std::function对象的参数能转换为可调用实体的参数； 
- (2) 可调用实体的返回值能转换为std::function对象的返回值。 

std::function对象最大的用处就是在实现函数回调，使用者需要注意，它不能被用来检查相等或者不相等，但是可以与NULL或者nullptr进行比较。

function对象好处：

std::function实现了一套类型消除机制，可以统一处理不同的函数对象类型。以前我们使用函数指针来完成这些；现在我们可以使用更安全的std::function来完成这些任务。

