# 6.0前言

“模板”，Stroustrup以前称其为被参数化的型别。“称其参数化是因为，型别相关信息可自template定义式中抽离，称其型别则是因为，每一个class template或function template基本上都随着它所作用或它所内涵的型别而有性质上的变化（所以，class template或function template本身就像是某种型别）。”这样的解释看的很明白。
关于“树”与“二叉树”的概念，有个模糊的概念也就够了，百度百科上也没多说什么。下面让我们开始代码的设计，当然是跟着作者的思路。
该二叉树包含两个class，一是BinaryTree，用以存储一个指针，指向根节点，还包含一些对数的操作。另一个是BTnode，用来存储节点实值，以及连接至左、友两个子节点的链接。这是跟链表如出一辙啊。BinaryTree类应该支持的操作：
- 元素的安插（insert）（注意是接在叶节点之后），
- 移除（remove）特定的元素，
- 搜寻（find）某元素，
- 清除所有元素（clear），
- 以三种方式打印（print）整棵树：中置（inorder）、前置（preorder）、后置（postorder），所谓前、中、后是各根节点相对于其两个子节点的位置。子节点的顺序是先左后右。当树为空时，第一个安插的是根节点，以后安插的，小于根节点则安插至左侧，大于则右侧。当删除一节点时，该节点的位置由其右子节点替上，而其左子节点（包括其树）则安插在左子节点的相对位置上。

# 6.1被参数化的类型

恩，作者先来了下铺垫。

注意到，泛型算法、面向对象编程和模板都有一些共通的特点和设计思路。

设计模板是，注意哪些是“与类型相依”，而哪些是“独立于类型之外”的，将“与类型相依”的部分抽取出来，成为一个或多个参数。前面学过function template，感觉差不多。
一颗树中有什么可以模型化呢？想一想也就是节点的值吧。

```c++
class string_BTnode{
public:
    //......
private:
    string _val;
    int _cnt;
    string_BTnode *_lchild;
    string_BTnode *_rchild;
};
```

这只能保存的是string类型的值，所以将string抽离出来：
```c++
template<typename valType>
class BTnode{
public:
    //.....
private:
    valType _val;
    int _cnt;
    BTnode *_lchild;
    BTnode *_rchild;
};
```

为什么上面两指针的类型不是“BTnode<valType> *”呢？

该节后面说了“什么情形下需要以template parameter list进一步修饰class template？一般规则是，在class template及其member的定义式中不须如此。除此之外都需以parameter list加以修饰。BinaryTree会使用BTnode的数据及操作，所以应将其声明为friend class。

```c++
template<typename valType>
class BTnode{
    friend class BinaryTree<valType>;
    //......
};
```
模板的使用我们并不陌生，如vector<int> ivec;相信大家都懂。

下面将BinaryTree的数据声明出来：

```c++
template<typename elemType>
class BinaryTree{
public:
    //......
private:
    //此时，BTnode必须以template parameter list加以修饰
    BTnode<elemType> *_root;
};
```

# 6.2Class Template的定义

以下是BinaryTree class template的部分定义：

```c++
template<typename elemType>
class BinaryTree{
public:
    BinaryTree();
    BinaryTree(const BinaryTree&);
    ~BinaryTree();
    BinaryTree& operator=(const BinaryTree&);
    bool empty(){return _root==0;} //inline function
    void clear();

private:
    Btnode<elemType> *_root;
    void copy(BTnode<elemtype> *tar,BTnode<elemType> *src);//将src所指之子树复制到tar所指之子树
};

template<typename elemType>
inline BinaryTree<elemType>::
BinaryTree():_root(0){}
//格式是固定的，理解其含义最重要。BinaryTree不是一个类，BinaryTree<elemType>才是，注意class scope运算符
//之后的部分在类体内，所以下面的第二个BinaryTree不必再加修饰。

template<typename elemType>
inline BinaryTree<elemType>::
BinaryTree(const BinaryTree &rhs){copy(_root,rhs._root);}

template<typename elemType>
inline BinaryTree<elemType>::
~BinaryTree(){clear();}

template<typename elemType>
inline BinaryTree<elemType>&
BinaryTree<elemType>::
operator=(const BinaryTree &rhs){
    if(this!=&rhs) { clear(); copy(_root,rhs._root);}
    return *this;
}
```

对于private member function的使用让我想起了函数是工具这一说法。当然是我说的，可多次使用的工具，所以多个函数要执行相同的一部分功能时，应将该功能抽象为一函数，代码重用也是高效啊。

# 6.3Template型别参数的处理

这一节的内容前面就都有涉及到，作者不过是再强调一下。

1. 对于参数的传递方式，传值或传址。当然总的情况是传址优于传值，高效且不易出错。
2. 关于member initialization list 的使用。
书中的例子还是写下吧。我在前面的章节总结过，在member initialization list中才是数据成员定义的地方，所以在member initialization list中对成员的赋值是对该对象的初始化，而在构造函数体内的赋值是对已存在对象的赋值，这就不是初始化了。对于一个正在初始化的对象，不论是采用直接初始化（）还是赋值初始化=，都调用该类的构造函数，而对于一个已存在的对象赋值时=，调用的是重载的=操作符。
这样就知道为什么在member initialization list 中赋值时更高效了，毕竟只有一步。

选择在member initialization list内为每个类型参数进行初始化操作：

```c++
// 针对constructor的类型参数，以下是比较被大家喜欢的初始化做法：
template <typename valType>
inline BTnode<valType>::BTnode( const valType &val )
    // 将valType视为某种class类型
    : _val( val )
{
    _cnt = 1;
    _lchild = _rchild = 0;
}
```

而不选择在constructor函数体内进行：

```c++
template < typename valType >
inline BTnode<valType>::BTnode( const valType &val )
{
    // 不建议你这么做，因为它可能是class类型
    _val = val;
    
    // ok: 它们的类型不会改变，绝对是内置类型
    _cnt = 1;
    _lchild = _rlight = 0;
}
```

这么一来，当用户为valType指定一个class类型时，可以保证效率最佳。例如，下面将valType指定为内置类型int：

```c++
BTnode<int> btni( 42 );
```
那么上述两种方式并无效率上的差异，但是如果我们这样写：

```c++
BTnode<Matrix> btnm( transform_matrix );
```

效率上就有高下之分了。因为，constructor函数体内对_val的赋值操作可以分解为两个步骤：
- 函数体执行前，Matrix的default constructor会先作用于_val身上；
- 函数体内会以copy assignment operator将val复制给_val。

但是如果我们采用上述第一种方法，在constructor的member initialization list中将_val初始化，那么只需要一个步骤就能完成工作：以copy constructor 将 val 复制给_val。

再举一例：

```c++
// 错误做法
class ABEntry{
public:
    ABEntry(const std::string& name){
    name_ = name;//这里是赋值操作，name_在进入构造函数之前就被初始化
    }
private:
 std::string name_; 
}

// 正确做法
class ABEntry{
public:
    ABEntry(const std::string& name):name_(name){
    }
private:
 std::string name_; 
}
```

再再举个例子：

```c++
#include "stdafx.h"
#include <iostream>

using namespace std;

struct Test1
{
    Test1() // 无参构造函数
    { 
        cout << "Construct Test1" << endl ;
    }

    Test1(const Test1& t1) // 拷贝构造函数
    {
        cout << "Copy constructor for Test1" << endl ;
        this->a = t1.a ;
    }

    Test1& operator = (const Test1& t1) // 赋值运算符
    {
        cout << "assignment for Test1" << endl ;
        this->a = t1.a ;
        return *this;
    }

    int a ;
};

struct Test2
{
    Test1 test1 ;
	Test2(Test1 &t1) // 在构造函数体内进行赋值操作
    {
        test1 = t1;
    }
};

int main() {
	Test1 t1 ;
	Test2 t2(t1) ;

	system("pause");
}
```

输出结果：

```
Construct Test1
Construct Test1
assignment for Test1
```

```c++
#include "stdafx.h"
#include <iostream>

using namespace std;

struct Test1
{
    Test1() // 无参构造函数
    { 
        cout << "Construct Test1" << endl ;
    }

    Test1(const Test1& t1) // 拷贝构造函数
    {
        cout << "Copy constructor for Test1" << endl ;
        this->a = t1.a ;
    }

    Test1& operator = (const Test1& t1) // 赋值运算符
    {
        cout << "assignment for Test1" << endl ;
        this->a = t1.a ;
        return *this;
    }

    int a ;
};

struct Test2
{
    Test1 test1 ;
	Test2(Test1 &t1):test1(t1) // 使用初始化列表
    {
    }
};

int main() {
	Test1 t1 ;
	Test2 t2(t1) ;

	system("pause");
}
```

输出结果：

```
Construct Test1
Copy constructor for Test1
```

总结：**正确做法仅仅调用一次copy构造函数，而错误做法中会先调用默认构造函数在调用赋值函数，相比之下效果低。**

# 6.4 实现一个Class Template
记得第一次接触链表时很闹心，关于链表的一些操作，虽然懂点，不过不会安排循环中语句的顺序，而做的次数多了，也就会了。对二叉树中节点的建立与删除需要用new和delete。（不知为何，当我第一次接触malloc时，竟然感觉比起new跟喜欢malloc的内存请求方式，难道是因为其对于底层的操作？）。对于new和delete的内部细节，我也一无所知，不过我知道new出来的内存空间除非显示将其delete掉便会一直存在，知道程序运行结束由操作系统将其收回。new表达式可分为两个操作：

1. 向程序的自由空间请求内存。如果配置到足够的空间，就返回一个指针，指向新对象。如果空间不足，会掷出bad_alloc异常。
2. 如果第一步成功，并且外界指定了一个初值，这个对象便会以最适当的方式被初始化。

这一节的语法知识就这点，下面便是关于代码的设计了。
对于代码的讲解使我们的以更快的理解代码，良好的注释就相当于讲解了。

```c++
//将一值插入树中，若根节点不存在，其便为根节点，否则遍历树，找到其位置或遇到已插入的该值为止，该功能能由insert_value函数完成
template<typename elemType>
inline void
BinaryTree<elemType>::
insert(const elemType &elem){
    if(!_root) 
        _root=new BTnode<elemType>(elem);
    else 
        _root->insert_value(elem);
}

//注意insert（）为BinaryTree成员函数。而insert_value()为BTnode的成员函数，因为BTnode保存着左右子树的指针，所以便于递归行为
template<typename valType>
void BTnode<valType>::
insert_value(const valType &val){
    if(val==_val) 
        {_cnt++;return ;}//保存值出现的次数
    if(val<_val){
        if(!_lchild) 
            _lchild=new BTnode(val);
        else 
            _lchilde->insert_value(val);
    }
    else{
        if(!_rchilde) 
            _rchild=new BTnode(val);
        else 
            _rchild->insert_vlaue(val);
    }
}

//以下是节点的移除操作。
template<typename elemType>
inline void
BinaryTree<elemType>::
remove(const elemType &elem){
    if(_root){
        if(_root->_val==elem) 
            remove_root(); //此处将根节点的移除特例化
        else 
            _root->remove_value(elem,_root);
    }
}

//无论remove_root()或remove_value()，皆会搬移左子节点，使它成为右子节点的左子树的叶节点。
//作者将这一操作抽离至lchild_leaf()，是BTnode的static member function
template<typename valType>
void BTnode<valType>::
lchild_leaf(BTnode *leaf,BTnode *subtree){
    while(subtree->_lchild) 
        subtree=subtree->_lchild;
    subtree->_lchild=leaf;
}

//怎么都感觉这段不够严谨，可能会导致左子节点的值大于根节点。因为该函数是将左子节点（树）移至右子树的最左端。此处可能会破坏树的结构
//关于remove_root()的设计，让我感兴趣的是作者的设计思路。如果根节点拥有任何子节点，remove_root()就会重设
//根节点。如果右子节点存在，就以右子节点取代之；如果左子节点存在，就直接搬移，或通过lchild_leaf()完成。如果右子节点为null，_root便以左子结点取代。
template<typename elemType>
void BinaryTree<elemType>::
remove_root(){
    if(!_root) return;
    BTnode<elemType> *tmp=_root;
    if(_root->_rchild){
        _root=_root->_rchild;
        if(tmp->_lchild){
            BTnode<elemType> *lc=tmp->_lchild;
            BTnode<elemType> *newlc=_root->_lchild;
            if(!newlc) _root->_lchild=lc;
            else BTnode<elemType>::child_leaf(lc,newly);
        }
    }
    else _root=_root->_lchild;
    delete tmp;
}

//remove_value()有两个参数，将被删除的值以及一个指针，指向目前关注的节点的父节点。
template<typename valType>
void BTnode<valType>::
remove_value(const valType &val,BTnode *&prev){
    if(val<_val){
        if(!_lchild) return;
        else _lchild->remove_value(val,_lchild);
    }
    else if(val>_val){
        if(!_rchild) return;
        else _rchild->remove_value(val,_rchild);
    }
    else{
        if(_rchild){
            prev=_rchild;
            if(_lchild)
                if(!prev->_lchild) prev->_lchild=_lchild;
                else BTnode<valType>::child_leaf(_lchild,prev->_lchild);
        }
        else prev=_lchild;
        delete this;
    }
}

//在这里更能发现问题，lchild_leaf()的问题，prev为指向一个指针的引用，是为了改变指针本身
//一下是移除整个二叉树。
template<typename elemType>
class BinaryTree{
public:
    void clear(){if(_root) {clear(_root); _root=0;}}
    //......
private:
    void clear(BTnode<elemType>*);
    //......
};
template <typename elemType>
void BinaryTree<elemType>::
clear(BTnode<elemType> *pt){
    if(pt){
        clear(pt->_lchild);
        clear(pt->_rchild);
        delete;
    }
}

//递归啊
//这是遍历算法，这递归用的好啊
template<typenam valType>
void BTnode<valType>::
preorder(BTnode *pt,ostream &os)const{
    if(pt){
        display_val(pt,os);
        if(pt->_lchild) preorder(pt->_lchild,os);
        if(pt->_rchild)preorder(pt->_rchild,os);
    }
}

template<typenam valType>
void BTnode<valType>::
preorder(BTnode *pt,ostream &os)const{
    if(pt){
        if(pt->_lchild) preorder(pt->_lchild,os);
        display_val(pt,os);
        if(pt->_rchild)preorder(pt->_rchild,os);
    }
}

template<typenam valType>
void BTnode<valType>::
preorder(BTnode *pt,ostream &os)const{
    if(pt){
        if(pt->_lchild) preorder(pt->_lchild,os);
        if(pt->_rchild)preorder(pt->_rchild,os);
        display_val(pt,os);
    }
}
```

# 6.5一个以Function Template完成的Output运算符

很简单，不多说了，像正常的non-member function template一样。

```c++
template<typename valType>
inline ostream&
operator <<(ostream &os,const BinaryTree<elemType> &bt){
    os<<"Three:"<<endl;
    bt.print(os);
    return os;
}
```

关于print（），书中说是BinaryTree class template的一个private member function，不过未给其定义，我也懒得查了。不过可以确定的是一定调用
了上面三种遍历函数。

# 6.6常量表达式和默认参数

template的用法很多啊。
本节的内容让我想起了bitset <>
template参数并不是非得某种型别不可，也可以是常量表达式作为template参数。且模板列表可设定默认值，其规则与一般函数的默认参数值一样，由左至右进行解析。

```c++
//不带默认值的
template<int len>
class num_sequence{
public:
    num_sequence(int beg_pos=1);
//......
};
template<int len>
class Fibonacci:public num_sequence<len>{
public:
    Fibonacci(int beg_pos=1):num_sequence<len>(beg_pos){}
//......
};
```

对于其使用像别的模板一样，就是变为数字了。

```c++
Fibonacci<16> fib1;
Fibonacci<16> fib2(17);
//设置默认值
template<int len,int beg_pos>
class num_sequence{......};

template<int len,int beg_pos=1>
class Fibonacci:public num_sequence<len,beg_pos>{......};

num_sequence<32> *pns1to32=new Fibonacci<32>;
num_sequence<32,33> *pns33to64=new Fibonacci<32,33>;
```

对于参数length和beg_pos的使用如正常的 data member一样。下面这个template的使用方式更有意思。

```c++
template<void(*pf)(int pos,vector<int> &seq)>
class numeric_sequence{
public:
    numeric_sequence(int len,int beg_pos=1){
        if(!pf) //......
            _len=len>0?len:1;
        _beg_pos=beg_pos>0?beg_pos:1;
        pf(beg_pos+len-1,_elems);
}
//......
private:
    int _len;
    int _beg_pos;
    vector<int> _elems;
};
```

全局作用域（global scope）内的函数及对象，其地址也是一种常量表达式，因此，它们也可以拿来表现此一形式的参数。
```c++
void fionacci(int pos,vector<int> &seq);
void pell(int pos,vector<int> &seq);
//......
numeric_sequence<fibonacci> ns_fib(12);
numeric_sequence<pell> ns_pell(18,8);
```

# 6.7以Template参数作为一种设计策略

template的用法十分广泛，如上节所说的那些，还可以向其传递模板类对象。前几节的lessThan function object

```c++
template<typename elemType>
class LessThan{
public:
LessThan(const elemType &val):_val(val){}
bool operator()(const elemType &val)cosnt {return val<_val;}
void val(const elemType &newval){ _val=newval;}
elemType val()const { return _val; }
private:
elemType _val;
};

LessThan<int> lti(1024);
LessThan<string> lts("pooh");
```

记不记得泛型算法的设计？将其内部的比较操作参数化，上面的LessThan类也一样可以。如下：

```c++
template<typename elemType,typename BinaryComp>
class Compare{
public:
    Compare(const elemType &val):_val(val){}
    bool operator()(const elemType &val)cosnt{return BinaryComp(val,_val);}
    void val (const elemType &newval){_val=newval;}
    elemType val()cosnt{ return _val;}
private:
    elemType _val;
};

//function object
class stringlen{
public:
    bool operator()(const string &s1,const string &s2){return s1.size()<s2.size();}
};

Compare<string,stringlen> ltps("pooh");
```

当然这个一样可以设置默认值。还有，class template无法基于参数列表的不同而重载。
作者对于第5章的数列类体系又提出了一种设计方案。将数列类定义为class template，而将实际的数列类抽离出来称为参数。

```c++
template<typename num_seq>
class NumericSequence{
public:
    NumericSequence(int len=1,int bpos=1):_ns(len,bpos){ }
    //书中所谓的“命名规范”是每个num_seq参数类都必须提供下列的两个同名函数:calc_elems(),is_elem()
    void cal_elems(int sz)const{ _ns.calc_elems(sz);}
    bool is_elem(int elem)const{ return _ns.is_elem(elem); }
//......
private:
    num_seq _ns;
};
```


# 6.8Member Template Functions

本节没有难的。
1. 可将member function定义成template形式。

```c++
class PrintIt{
public:
    PrintIt(ostream &os):_os(os){ }
    template<typename elemType>
    void print (const elemType &elem,char delimiter='\n')
        { _os<<elem<<delimiter;}
private:
    ostream &_os;//注意这里是引用
};
```

2. Class template内也可定义member template function

```c++
template<typename OutStream>
class PrintIt{
public:
    PrintIt(OutStream &os):_os(os){ }
    template<typename elemType>
    void print(const elemType &elem,char delimiter='\n')
        {_os<<elem<<delimiter;}
private:
    ostream _&os;
};
```

怎么感觉这两个的功能是一样的呢。试了一下，果然是。都可以对文件、屏幕和字符串流输出。

