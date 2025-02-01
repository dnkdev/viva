module viva

pub fn start[T](app T, port int) {
	unsafe {
		listenfd := C.viva_listen(8080)
		epfd := C.viva_epoll_init(listenfd)
		events := [max_events]C.epoll_event{}
		for {
			evnum := C.viva_wait_epoll_events(listenfd, epfd, &events[0], max_events,
				-1)
			if evnum == -1 {
				continue
			}
			for i := 0; i < evnum; i++ {
				fd := events[i].data.fd

				if fd == listenfd {
					handle_incom(listenfd, epfd) or { continue }
				} else if events[i].events == C.EPOLLIN {
					handle_client[T](app, listenfd, epfd, fd) or { continue }
				}
			}
		}
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

fn handle_client[T](app T, listenfd int, epfd int, clientfd int) ! {
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
		handle_response[T](app, epfd, clientfd, buffer, count)
	}
}

fn handle_response[T](app T, epfd int, clientfd int, buffer string, count int) {
	// gmt := time.utc()
	// date := gmt.http_header_string()
	// mut buff := ''

	// get first line with method and path
    method_path := buffer.all_before('\n').all_before(' HTTP/1.')
    
	response := Response {
		epfd: epfd,
		fd: clientfd,
		request: buffer
	}
   	trace('${method_path}')
	$for method in T.methods {
        if method_path in method.attrs {
            app.$method(response)
			return
        }
	}
	
	response.end()
}
