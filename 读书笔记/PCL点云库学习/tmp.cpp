#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
const int buf_size = 4096;
int main()
{
    int fds[2];
    pipe(fds); //  创建管道
    pid_t pid = fork();
    if (pid == (pid_t)0) //  子进程
    {
        close(fds[0]); //  关闭管道读取端
        dup2(fds[1], STDOUT_FILENO); //  管道挂接到标准输出流
        char* args[] = { "ls", "-l", "/", NULL }; //  使用“ls”命令替换子进程
        execvp(args[0], args);
    }

    else //  父进程
    {
        close(fds[1]); //  关闭管道写入端
        char buf[buf_size];
        FILE* stream = fdopen(fds[0], "r"); //  以读模式打开管道读取端，返回文件指针
        fprintf(stdout, "Data received: \n");
        //  在流未结束，未发生读取错误，且能从流中正常读取字符串时，输出读取到的字符串
        while (!feof(stream) && !ferror(stream) && fgets(buf, sizeof(buf), stream) != NULL) {
            fputs(buf, stdout);
        }
        close(fds[0]); //  关闭管道读取端
        waitpid(pid, NULL, 0); //  等待子进程结束
    }
    return 0;
}