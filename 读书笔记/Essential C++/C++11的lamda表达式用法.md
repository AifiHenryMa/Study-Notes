# 前言
C++11的Lambda表达式用于定义并创建匿名的函数对象，以简化编程工作。

Lambda的语法形式如下：

**[函数对象参数] (操作符重载函数参数) mutable或exception声明 -> 返回值类型 {函数体}**

可以看到，Lambda主要分为五个部分：[函数对象参数]、(操作符重载函数参数)、mutable或exception声明、-> 返回值类型、{函数体}。

下面分别进行介绍。

# 一、[函数对象参数]

标识一个Lambda的开始，这部分必须存在，不能省略。函数对象参数是传递给编译器自动生成的函数对象类的构造函数的。函数对象参数只能使用那些到定义Lambda为止时Lambda所在作用范围内可见的局部变量（包括Lambda所在类的this）。函数对象参数有以下形式：

- 1、空。没有使用任何函数对象参数。
- 2、=。函数体内可以使用Lambda所在作用范围内所有可见的局部变量（包括Lambda所在类的this），并且是值传递方式（相当于编译器自动为我们按值传递了所有局部变量）。
- 3、&。函数体内可以使用Lambda所在作用范围内所有可见的局部变量（包括Lambda所在类的this），并且是引用传递方式（相当于编译器自动为我们按引用传递了所有局部变量）。
- 4、this。函数体内可以使用Lambda所在类中的成员变量。
- 5、a。将a按值进行传递。按值进行传递时，函数体内不能修改传递进来的a的拷贝，因为默认情况下函数是const的。要修改传递进来的a的拷贝，可以添加mutable修饰符。
- 6、&a。将a按引用进行传递。
- 7、a, &b。将a按值进行传递，b按引用进行传递。
- 8、=，&a, &b。除a和b按引用进行传递外，其他参数都按值进行传递。
- 9、&, a, b。除a和b按值进行传递外，其他参数都按引用进行传递。

# 二、(操作符重载函数参数)

没有参数时，这部分可以省略。参数可以通过按值（如：(a,b)）和按引用（如：(&a, &b)）两种方式进行传递。

# 三、mutable或exception声明

这部分可以省略。按值传递函数对象参数时，加上mutable修饰符后，可以修改按值传递进来的拷贝（注意是能修改拷贝，而不是值本身）。exception声明用于指定函数抛出的异常，如抛出整数类型的异常，可以使用throw(int)。

# 四、->返回值类型
标识函数返回值的类型，当返回值为void，或者函数体中只有一处return的地方（此时编译器可以自动推断出返回值类型）时，这部分可以省略。

# 五、{函数体}
标识函数的实现，这部分不能省略，但函数体可以为空。

下面给出一段示例代码，用于演示上述提到的各种情况，代码中有简单的注释可作为参考。
```c++
#include <vector>
#include <iostream>
#include <algorithm>
#include <functional>

using namespace std;

int main(int argc, char* argv[]) {
    std::vector<int> c { 1,2,3,4,5,6,7 };
    int x = 5;
    c.erase( std::remove_if(c.begin(), c.end(), [x]( int n ) { return n < x; } ), c.end());

    std::cout << "c: ";
    for ( auto i : c ) {
        std::cout << i << ' ';
    }

    std::cout << '\n';

    std::function< int (int) > func = []( int i ) { return i + 4; }; // 尖括号里面第一个int代表输出，第二个int代表输入
    std::cout << "func: " << func( 6 ) << "\n";

}
```

再举例：
```c++
#include <iostream>

using namespace std;

int main()
{
    double m = 178;
    double w = 81;
    auto bmi = [=]( double m, double w ) -> double {
        return 10000*w/m/m;
    };

    cout << bmi(m, w) << endl;
    return 0;
}

```

auto的实际类型是function<double(double,double)>，还要加上头文件#include <functional>
```c++
#include <iostream>
#include <functional>

using namespace std;

int main()
{
    double m = 178;
    double w = 81;
    function<double (double, double)> bmi = [=]( double m, double w ) -> double {
        return 10000*w/m/m;
    };

    cout << bmi(m, w) << endl;
    return 0;
}
```

同样，lambda表达式也可以移到main()函数外面
```c++
#include <iostream>
#include <functional>

using namespace std;

function<double (double, double)> bmi = [=]( double m, double w ) -> double {
    return 10000*w/m/m;
};

int main()
{
    double m = 178;
    double w = 81;

    cout << bmi(m, w) << endl;
    return 0;
}
```

将传值方式改为传引用方式，然后输入删掉-> double ，让编译器自动推导出输出类型
```c++
#include <iostream>
#include <functional>

using namespace std;

function<double (double, double)> bmi = [&]( double m, double w ) {
    return 10000*w/m/m;
};

int main()
{
    double m = 178;
    double w = 81;

    cout << bmi(m, w) << endl;
    return 0;
}
```

