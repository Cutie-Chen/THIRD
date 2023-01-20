#include <stdio.h>
#include <stdlib.h>
#include <ctime>
#include <windows.h>
#pragma comment(lib, "ws2_32.lib")
#include <thread>
#include <iostream>
using namespace std;

void setup();
void do_regular_work();
void shut_down();
int get_ticket();
int release_ticket();
void send_heart();
typedef int socklen_t;

static int pid = -1;
static int sd = -1;
static struct sockaddr serv_addr;
static socklen_t serv_alen;
static char ticket_buf[128];
static bool have_ticket = false;
extern string username;
extern string password;
extern int tick;




bool startup()
{
    cout << "Welcome! Do you have a account [y/n]?" << endl;
    char c;
    cin >> c;
    if (c == 'y' || c == 'Y')
    {
        cout << "Please input your username:" << endl;
        cin >> username;
        cout << "Please input your password:" << endl;
        cin >> password;
        cout << "Please input your ticket:" << endl;
        cin >> tick;
    }
    else if (c == 'N' || c == 'n')
    {
        cout << "Do you want sign up [y/n]?" << endl;
        char c;
        cin >> c;
        if (c == 'y' || c == 'Y')
        {
            cout << "Please input your username:" << endl;
            cin >> username;
            cout << "Please input your password:" << endl;
            cin >> password;
        }
        else
            return false;
    }
    else
    {
        cout << "Invalid input, progress ending..." << endl;
        return false;
    }
    return true;
}

int main(int ac, char *av[])
{
    setup();

    if (!startup())
        return -1;

    if (get_ticket() != 0)
    {
        exit(0);
    }
    thread *heartTh = new thread(send_heart);
    heartTh->detach();

    do_regular_work();
    release_ticket();
    shut_down();
}

void do_regular_work()
{
    printf("SuperSleep version 1.0 Running-Licensed Software\n");
    Sleep(60);
}
