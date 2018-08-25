组合类：一个类里面的数据成员是另一个类的对象，即内嵌其他类的对象作为自己的成员。

创建组合类的对象：首先创建各个内嵌对象，难点在于构造函数的设计。创建对象时既要对基本类型的成员进行初始化，又要对内嵌对象初始化。

示例：

```c++
#include <iostream>
#include <cmath>
using namespace std;

class Point{
private:
    int x, y;

public:
    Point(int a = 0, int b = 0)
    {
        x = a; y = b;
        cout << "Point construction: " << x << ", " << y << endl;
    }

    Point(Point &p) // copy constructor,其实数据成员是int类型，默认也是一样的
    {
        x = p.x;
        y = p.y;
        cout << "Point copy construction: " << x << ", " << y << endl;
    }

    int getX()
    {
        return x;
    }

    int getY()
    {
        return y;
    }
};

class Line {
    private:
        Point start, end;

    public:
        Line(Point pstart, Point pend):start(pstart),end(pend) //组合类的构造函数对内嵌对象成员的初始化必须采用初始化列表形式
        {
            cout << "Line constrctor " << endl; 
        }

        float getDistance() {
            double x = double(end.getX()-start.getX());
            double y = double(end.getX()-start.getX());
            return (float)(sqrt)(x*x+y*y);
        }
};

int main() {
    Point p1(10,20), p2(100,200);
    Line line(p1, p2);
    cout << "The distance is: " << line.getDistance() << endl;

    return 0;
}
```

创建组合类的对象，构造函数的执行顺序：先调用内嵌对象的构造函数，然后按照内嵌对象成员在组合类中的定义顺序，与组合类构造函数的初始化列表顺序无关。然后执行组合类构造函数的函数体。析构函数调用顺序相反。

上例中当创建Point类对象p1, p2时调用Point类构造函数2次；当创建组合类Line对象line时，调用了组合类Line的构造函数（首先是参数：需要实参传递给形参，需要调用Point类的拷贝构造函数2次，注意参数传递顺序是从右到左；然后是初始化列表：再调用Point类的拷贝构造函数2次，分别完成内前对象成员start, end的初始化）；然后才开始执行Line类的构造函数的函数体。

输出：
```
Point construction: 10, 20  
Point construction: 100, 200  
Point copy construction: 100, 200  
Point copy construction: 10, 20  
Point copy construction: 10, 20  
Point copy construction: 100, 200  
Line constructior  
The distance is: 201.246 
```


组合类的拷贝构造函数：系统也可以自动添加，自动调用内嵌对象的拷贝构造函数，对各个内嵌对象成员进行初始化。
```c++
Line(Line &ll):start(ll.start),end(ll.end) {
    cout << "Line copy constructor " << endl;
}
```

调用：

```c++
Point p1(10,20),p2(100,200);
Line line1(p1,p2);
Line line2(line1);
cout << "The distance is: " << line2.getDistance() << endl;
```

输出：
```
Point construction: 10, 20  
Point construction: 100, 200  
Point copy construction: 100, 200  
Point copy construction: 10, 20  
Point copy construction: 10, 20  
Point copy construction: 100, 200  
Line constructior  
Point copy construction: 10, 20  
Point copy construction: 100, 200  
Line copy constructor  
The distance is: 201.246
```
