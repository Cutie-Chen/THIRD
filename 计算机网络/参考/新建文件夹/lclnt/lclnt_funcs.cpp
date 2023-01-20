#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#pragma comment(lib, "ws2_32.lib")
#include <iostream>
//#include <winsock2.h>
//#pragma comment(lib, "WS2_32")
#define _CRT_SECURE_NO_DEPRECATE

using namespace std;
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

#define MSGLEN 1024
#define SERVER_PORTNUM 2020
#define HOSTLEN 512
#define oops(p)    \
    {              \
        perror(p); \
        exit(1);   \
    }
int make_dgram_server_socket(int);
int get_internet_address(char *, int, int *, struct sockaddr_in *);
int make_dgram_client_socket();
int make_internet_address(char *, int, struct sockaddr_in *);
char *do_transaction(char *);

void narrate(const char *msg1, const char *msg2)
{
    fprintf(stderr, "CLIENT[%d]:%s %s\n", pid, msg1, msg2);
}

void syserr(const char *msg1)
{
    char buf[MSGLEN];
    sprintf(buf, "CLIENT[%d]:%s", pid, msg1);
    perror(buf);
}

void setup()
{
    char hostname[BUFSIZ];
    pid = getpid();
    sd = make_dgram_client_socket();
    if (sd == -1)
        oops("Cannot create socket");
    gethostname(hostname, HOSTLEN);
    make_internet_address(hostname, SERVER_PORTNUM, (sockaddr_in *)&serv_addr);
    serv_alen = sizeof(serv_addr);
}

void shut_down()
{
    Close(sd);
}

int get_ticket()
{
    char *response;
    char buf[MSGLEN];
    if (have_ticket)
        return 0;

    // sprintf(buf, "HELO %d", pid);
    sprintf(buf, "HELO %s %s %d", username.c_str(), password.c_str(), tick);
    if ((response = do_transaction(buf)) == NULL)
        return -1;
    if (strncmp(response, "TICK", 4) == 0)
    {
        strcpy(ticket_buf, response + 5);
        have_ticket = 1;
        narrate("got ticket", ticket_buf);
        return 0;
    }

    if (strncmp(response, "FAIL", 4) == 0)
        narrate("Could not get ticket", response);
    else
        narrate("Unkonwn message:", response);
    return -1;
}

int release_ticket()
{
    char buf[MSGLEN];
    char *response;
    if (!have_ticket)
        return 0;
    sprintf(buf, "GBYE %s", ticket_buf);
    if ((response = do_transaction(buf)) == NULL)
        return -1;

    if (strncmp(response, "THNX", 4) == 0)
    {
        narrate("release ticket OK", "");
        return 0;
    }

    if (strncmp(response, "FAIL", 4) == 0)
        narrate("release failed", response + 5);
    else
        narrate("Unknown message: ", response);
    return -1;
}

char *do_transaction(char *msg)
{
    static char buf[MSGLEN];
    struct sockaddr retaddr;
    socklen_t addrlen = sizeof(retaddr);
    int ret;

    ret = sendto(sd, msg, strlen(msg), 0, &serv_addr, serv_alen);
    if (ret == -1)
    {
        syserr("sendto");
        return NULL;
    }
    ret = recvfrom(sd, buf, MSGLEN, 0, &retaddr, &addrlen);
    if (ret == -1)
    {
        syserr("recvfrom");
        return NULL;
    }
    return buf;
}

//发送心跳包，证明自己的存在
void send_heart()
{
    char bufsend[MSGLEN] = {'\0'}, bufresv[MSGLEN] = {'\0'};
    struct sockaddr retaddr;
    socklen_t addrlen = sizeof(retaddr);
    int ret;

    sprintf(bufsend, "VALD %s %s %s", username.c_str(), password.c_str(), ticket_buf);
    while (true)
    {
        //由于在客户端存在期间要一直发送，故而要将该函数放在子线程中无限循环直到主线程结束
        ret = sendto(sd, bufsend, strlen(bufsend), 0, &serv_addr, serv_alen);

        ret = recvfrom(sd, bufresv, MSGLEN, 0, &retaddr, &addrlen);
        if (ret == -1)
        {
            // syserr("recvfrom");
            sprintf(bufresv, "Server crash!");
        }
        narrate("Valid? ", bufresv);

        //间歇性发送，此处每隔4秒发送一次
        Sleep(4);
    }
}