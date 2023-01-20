#include <signal.h>
#include <stdio.h>
#include <winsock2.h>
#include <thread>
using namespace std;
//#pragma comment(lib, "WS2_32")

typedef int socklen_t;
#define MSGLEN 128 /* Size of our datagrams */
void narrate(const char *, const char *, struct sockaddr_in *);
int setup();
void handle_request(char *, struct sockaddr_in *, socklen_t);
void ticket_reclaim();
int main(int ac, char *av[])
{
    struct sockaddr_in client_addr;
    socklen_t addrlen;
    char buf[MSGLEN];
    int ret;
    int sock;

    sock = setup();
    thread *heartTh = new thread(ticket_reclaim);
    heartTh->detach();
    while (1)
    {
        addrlen = sizeof(client_addr);
        ret = recvfrom(sock, buf, MSGLEN, 0, (sockaddr *)&client_addr, &addrlen);
        if (ret != -1)
        {
            buf[ret] = '\0';
            narrate("GOT:", buf, &client_addr);
            handle_request(buf, &client_addr, addrlen);
        }
        else if (errno != EINTR)
            perror("recvfrom");
    }
}
