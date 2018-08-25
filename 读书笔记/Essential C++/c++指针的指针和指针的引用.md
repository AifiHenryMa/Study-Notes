# 为什么需要使用它们

当我们把一个指针做为参数传一个方法时，其实是把指针的复本传递给了方法，也可以说传递指针是指针的值传递。如果我们在方法内部修改指针会出现问题，在方法里做修改只是修改的指针的copy而不是指针本身，原来的指针还保留着原来的值。我们用下边的代码说明一下问题：

```c++
int m_value = 1;

void func(int *p)
{
    p = &m_value;
}

int main(int argc, char *argv[])
{
    int n = 2;
    int *pn = &n;
    cout << *pn << endl;
    func(pn);
    cout << *pn <<endl;
    return 0;
}
```

输出结果： 2 2

# 使用指针的指针

展示一下使用指针的指针做为参数

```c++
void func(int **p)
{
    *p = &m_value;

    // 也可以根据你的需求分配内存
    *p = new int;
    **p = 5;
}

int main(int argc, char *argv[])
{
    int n = 2;
    int *pn = &n;
    cout << *pn << endl;
    func(&pn);
    cout << *pn <<endl;
    return 0;
}
```

输出结果：2 5

我们看一下 func(int **p)这个方法

- p：  是一个指针的指针，在这里我们不会去对它做修改，否则会丢失这个指针指向的指针地址
- *p:  是被指向的指针，是一个地址。如果我们修改它，修改的是被指向的指针的内容。换句话说，我们修改的是main（）方法里 *pn指针
- **p: 两次解引用是指向main()方法里*pn的内容

# 指针的引用

再看一下指针的引用代码

```c++
int m_value = 1;

void func(int *&p)
{
    p = &m_value;

    // 也可以根据你的需求分配内存
    p = new int;
    *p = 5;
}

int main(int argc, char *argv[])
{
    int n = 2;
    int *pn = &n;
    cout << *pn << endl;
    func(pn);
    cout << *pn <<endl;
    return 0;
}
```

输出：2 5

看一下func(int *&p)方法

- p:  是指针的引用，main()方法里的 *pn
- <font color=red>***p:是main()方法里的pn指向的内容。**</font>

