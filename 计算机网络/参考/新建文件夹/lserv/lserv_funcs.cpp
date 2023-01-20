#include <signal.h>
#include <sys/types.h>
#include <unordered_map>
#include <ctime>
#include <mutex>
#include <winsock.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <winsock2.h>
#include <windows.h>
//#pragma comment(lib, "WS2_32")
using namespace std;
typedef int socklen_t;
mutex mtx;

#define SERVER_PORTNUM 2020 /* Our server's port number */
#define MSGLEN 1024         /* Size of our datagrams */
#define TICKET_AVAIL 0      /* Slot is available for use */
#define MAXUSERS 1          /* Only 3 users for us */
#define oops(x)    \
    {              \
        perror(x); \
        exit(-1);  \
    }

/****************************************************************************
 * Important variables
 */
unordered_map<int, int> tickets;                // ticket和使用ticket的人数
unordered_map<int, pair<string, string>> users; //不同ticket对应的账号密码
unordered_map<string, int> ip_pid_map_tick;     //不同客户端ip和pid对应的ticket
unordered_map<string, clock_t> alarm_time;      //用来判断客户端是否超时
int sd = -1;                                    /* Our socket */

char *do_hello(char *, char *);
char *do_goodbye(char *, char *);
static char *do_validate(char *, char *);
void narrate(const char *, const char *, struct sockaddr_in *);
void free_all_tickets();
int make_dgram_server_socket(int);
int get_internet_address(char *, int, int *, struct sockaddr_in *);
int make_dgram_client_socket();
int make_internet_address(char *, int, struct sockaddr_in *);

/****************************************************************************
 * setup() - initialize license server
 */
int setup()
{
    sd = make_dgram_server_socket(SERVER_PORTNUM);
    if (sd == -1)
        oops("make socket");
    free_all_tickets();
    return sd;
}
void free_all_tickets()
{
    tickets.clear();
    users.clear();
}

/****************************************************************************
 * shut_down() - close down license server
 */
void shut_down()
{
    close(sd);
}

void handle_request(char *req, struct sockaddr_in *client, socklen_t addlen)
{
    char *response;
    int ret;

    char ip_pid[32];
    sprintf(ip_pid, "%s %d", inet_ntoa(client->sin_addr), ntohs(client->sin_port));
    /* act and compose a response */
    if (strncmp(req, "HELO", 4) == 0)
        response = do_hello(req, ip_pid);
    else if (strncmp(req, "GBYE", 4) == 0)
        response = do_goodbye(req, ip_pid);
    else if (strncmp(req, "VALD", 4) == 0)
        response = do_validate(req, ip_pid);
    else
        response = "FAIL invalid request";

    /* send the response to the client */
    narrate("SAID:", response, client);
    ret = sendto(sd, response, strlen(response), 0,
                 (struct sockaddr *)client, addlen);
    if (ret == -1)
        perror("SERVER sendto failed");
}

char *do_hello(char *msg_p, char *ip_pid)
{
    static char replybuf[MSGLEN];
    char username[128];
    char password[128];
    int tick = 0;

    sscanf(msg_p + 5, "%s %s %d", username, password, &tick);

    if (tick == 0)
    {
        tick = (int)time(0);
        users[tick] = make_pair(username, password);
        tickets[tick] = 0;
    }
    if (users.count(tick) == 0 || tickets[tick] >= MAXUSERS || users[tick].first != username || users[tick].second != password)
        return "FAIL no ticket/user available";
    mtx.lock();
    ip_pid_map_tick[ip_pid] = tick;
    alarm_time[ip_pid] = clock();
    tickets[tick]++;
    mtx.unlock();
    sprintf(replybuf, "TICK %d", tick);
    return replybuf;
} /* do_hello2 */

char *do_goodbye(char *msg_p, char *ip_pid)
{

    int tick = 0;

    if ((sscanf(msg_p + 5, "%d", &tick) != 1) ||
        (users.count(tick) == 0))
    {
        narrate("Bogus ticket", msg_p + 5, NULL);
        return "FAIL invalid ticket";
    }

    /* The ticket is valid.  Release it. */
    mtx.lock();
    tickets[tick]--;
    ip_pid_map_tick.erase(ip_pid);
    alarm_time.erase(ip_pid);
    mtx.unlock();
    /* Return response */
    return "THNX See ya!";
} /* do_goodbye2 */

/****************************************************************************
 * narrate() - chatty news for debugging and logging purposes
 */
void narrate(const char *msg1, const char *msg2, struct sockaddr_in *clientp)
{
    fprintf(stderr, "\t\tSERVER: %s %s ", msg1, msg2);
    if (clientp)
        fprintf(stderr, "(%s : %d)", inet_ntoa(clientp->sin_addr),
                ntohs(clientp->sin_port));
    putc('\n', stderr);
}

//最大超时时限，十秒
#define RECLAIM_INTERVAL 10
void ticket_reclaim()
{
    while (true)
    {
        mtx.lock();
        for (auto it = alarm_time.begin(); it != alarm_time.end();)
        {
            double delta = (clock() - it->second) / (double)CLOCKS_PER_SEC;
            //超时，将该客户端的ticket收回
            if (delta >= RECLAIM_INTERVAL)
            {
                int tick = ip_pid_map_tick[it->first];
                string username = users[tick].first;
                fprintf(stderr, "\t\tovertime: %s %s %d", username.c_str(), it->first.c_str(), (int)delta);
                ip_pid_map_tick.erase(it->first);
                it = alarm_time.erase(it);
                tickets[tick]--;
            }
            else
                ++it;
        }
        mtx.unlock();
    }
}

static char *do_validate(char *msg, char *ip_pid)
{
    char username[128];
    char password[128];
    int tick = 0;
    if (sscanf(msg + 5, "%s %s %d", username, password, &tick) == 3)
    {
        mtx.lock();
        if (ip_pid_map_tick.count(ip_pid) == 0)
        {
            ip_pid_map_tick[ip_pid] = tick;
            users[tick] = make_pair(username, password);
            tickets[tick]++;
        }
        alarm_time[ip_pid] = clock();
        mtx.unlock();
        return "GOOD Valid ticket";
    }

    narrate("Bogus ticket", msg + 5, NULL);
    return "FAIL invalid ticket";
}