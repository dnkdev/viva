#include "common.h"

// returns file descriptor
int viva_listen(int port)
{
    int sock = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK, 0);
    IF(
        sock == -1,
        "socket",
        exit(1));

    // Removing 'Address already in use'
    int opt = 1;
    IF(
        setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0,
        "setsockopt",
        close(sock);
        exit(2));

    const struct sockaddr_in addr = {.sin_family = AF_INET,
                                     .sin_addr.s_addr = INADDR_ANY,
                                     .sin_port = htons(port)};

    IF(
        bind(sock, (struct sockaddr *)&addr, sizeof(addr)) == -1,
        "bind",
        close(sock);
        exit(3));

    IF(
        listen(sock, SOMAXCONN) == -1,
        "listen",
        close(sock);
        exit(4));

    printf("Listening on port %d...\n", port);
    return sock;
}

int epoll_del_event(int epfd, int sock)
{
    IF(
        epoll_ctl(epfd, EPOLL_CTL_DEL, sock, NULL) == -1,
        "epoll_ctl: EPOLL_CTL_DEL",
        return -1);
    return 0;
}

// returns -1 if error on `epoll_ctl` add event
int epoll_add_event(int epfd, int sock, uint32_t flags)
{
    struct epoll_event event = {.events = flags, .data.fd = sock};
    IF(
        epoll_ctl(epfd, EPOLL_CTL_ADD, sock, &event) == -1,
        "epoll_ctl: EPOLL_CTL_ADD",
        return -1);
    return 0;
}

// returns epoll file descriptor
int viva_epoll_init(int sock)
{
    int epfd = epoll_create1(0);
    IF(epfd == -1, "epoll_create", close(sock); exit(5));

    IF(
        epoll_add_event(epfd, sock, EPOLLIN) == -1,
        "epoll_add_event",
        close(epfd);
        close(sock); exit(7));

    return epfd;
}

// returns number of epoll awaited events and -1 on epoll_wait error
int viva_wait_epoll_events(int lfd, int epfd, struct epoll_event *events, int max_events, int timeout)
{
    int evnum = epoll_wait(epfd, events, max_events, timeout);
    IF(evnum == -1, "epoll_wait", return -1);
    // IF(evnum == -1, "epoll_wait", close(lfd); close(epfd); return -1);
    return evnum;
}

int viva_make_socket_non_blocking(int fd)
{
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags == -1)
    {
        perror("fcntl(F_GETFL)");
        return -1;
    }

    flags |= O_NONBLOCK;
    if (fcntl(fd, F_SETFL, flags) == -1)
    {
        perror("fcntl(F_SETFL)");
        return -1;
    }
    return 0;
}

int viva_accept_new_incom(int lsock)
{
    struct sockaddr_in client_addr;
    socklen_t client_len = sizeof(client_addr);
    int client_sock = accept(lsock, (struct sockaddr *)&client_addr, &client_len);
    if (client_sock == -1)
    {
        perror("accept");
        return -1;
    }

    if (viva_make_socket_non_blocking(client_sock) == -1)
    {
        close(client_sock);
        return -1;
    }
    return client_sock;
}
