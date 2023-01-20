#include <stdio.h>
#include <string.h>
#include <winsock2.h>
//#pragma comment(lib, "WS2_32")

#define HOSTLEN 256
int make_internet_address(char *hostname, int port, struct sockaddr_in *addrp);
int make_dgram_server_socket(int portnum)
{
    struct sockaddr_in saddr;
    char hostname[HOSTLEN];
    int sock_id;

    // Windows 必须有的步骤，否者无法发送数据报
    WORD wVersionRequested;
    WSADATA wsaData;
    int err;
    wVersionRequested = MAKEWORD(1, 1);
    err = WSAStartup(wVersionRequested, &wsaData);
    if (err != 0)
    {
        perror("WSAStartup error");
    }

    sock_id = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sock_id == -1)
        return -1;
    gethostname(hostname, HOSTLEN);
    make_internet_address(hostname, portnum, &saddr);

    if (bind(sock_id, (struct sockaddr *)&saddr, sizeof(saddr)) != 0)
        return -1;
    return sock_id;
}

int get_internet_address(char *host, int len, int *portp, struct sockaddr_in *addrp)
{
    strncpy(host, inet_ntoa(addrp->sin_addr), len);
    *portp = ntohs(addrp->sin_port);
    return 0;
}

int make_dgram_client_socket()
{
    WORD wVersionRequested;
    WSADATA wsaData;
    int err;
    wVersionRequested = MAKEWORD(1, 1);
    err = WSAStartup(wVersionRequested, &wsaData);
    if (err != 0)
    {
        perror("WSAStartup error");
    }
    return socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
}

int make_internet_address(char *hostname, int port, struct sockaddr_in *addrp)
{
    struct hostent *hp;
    memset((void *)addrp, 0, sizeof(struct sockaddr_in));
    hp = gethostbyname(hostname);
    if (hp == NULL)
        return -1;
    memcpy((void *)&addrp->sin_addr, (void *)hp->h_addr, hp->h_length);
    addrp->sin_port = htons(port);
    addrp->sin_family = AF_INET;
    return 0;
}
