
#include <sys/epoll.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <openssl/ssl.h>
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

#define MAX_EVENTS 1024