module main

@[unsafe]
fn main() {
	listenfd := C.viva_listen(8080)
	epfd := C.viva_epoll_init(listenfd)
	events := [max_events]C.epoll_event{}
	for {
		evnum := C.viva_wait_epoll_events(listenfd, epfd, &events[0], max_events, -1)
		for i := 0; i < evnum; i++ {
			fd := events[i].data.fd

			if fd == listenfd {
				handle_incom(listenfd, epfd) or { continue }
			} else if events[i].events == C.EPOLLIN {
				handle_client(listenfd, epfd, fd) or { continue }
			}
		}
		// println('hello')
	}
}

fn handle_client(listenfd int, epfd int, clientfd int) ! {
	buffer, count := fd_read(clientfd, buffer_size)
	if count == -1 {
		if C.errno != C.EAGAIN {
			C.close(clientfd)
			eprintln('read ${C.errno}')
			return error('read ${C.errno}')
		} else {
			eprintln('read')
			return error('read')
		}
	} else if count == 0 {
		trace('Connection closed on fd ${clientfd}')
		C.close(clientfd)
	} else {
		handle_response(epfd, clientfd, buffer, count)
	}
}

fn handle_incom(listenfd int, epfd int) ! {
	client_sock := C.viva_accept_new_incom(listenfd)
	if client_sock == -1 {
		return error('viva_accept_new_incom')
	}

	// mut client_event :=
	if C.epoll_add_event(epfd, client_sock, u32(C.EPOLLIN | C.EPOLLET | C.EPOLLRDHUP)) == -1 {
		C.close(client_sock)
		return error('epoll_add_event')
	}
	trace('New connection on fd ${client_sock}')
}

@[if trace ?]
pub fn trace(s string) {
	println(s)
}

fn handle_response(epfd int, clientfd int, buffer string, count int) {
	// gmt := time.utc()
	// date := gmt.http_header_string()
	// mut buff := ''
	mut response := Response{
		epfd: epfd
		fd:   clientfd
	}

	index_page := 'HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Cache-Control: no-cache
Connection: keep-alive

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simple HTTP Response</title>
</head>
<body>
    <h1>Hello, World!</h1>
    <p>This is a simple HTML response.</p>
    <p>Your request was: </p>
    <pre>${buffer}</pre>
</body>
</html>'

	response.write(index_page)
	// response.make_sse()	
	// response.write('data: hello\n\n')
	// println('${response.buf_start}  ${response.buf - response.buf_start}  ${index_page.len}')
	// v_sprintf("%.*s", response.buf - response.buf_start, response.buf_start)
	// println(tos(response.buf, response.buf - response.buf_start))
	// fd_write(fd, index_page)

	trace('Sent response to fd ${clientfd}')
	response.end()
}
