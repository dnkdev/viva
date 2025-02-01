
#include <sys/epoll.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <errno.h>

#define IF(x, msg, then_do) \
    if (x)                  \
    {                       \
        perror(msg);        \
        then_do;            \
    }


int epoll_del_event(int epfd, int sock);
int epoll_add_event(int epfd, int sock, uint32_t flags);

int viva_listen(int port);
int viva_epoll_init(int sock);
int viva_wait_epoll_events(int lfd, int epfd, struct epoll_event *events, int max_events, int timeout);
int viva_make_socket_non_blocking(int fd);
int viva_accept_new_incom(int lsock);