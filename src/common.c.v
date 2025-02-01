module viva

#include "@VMODROOT/common.h"
#flag "@VMODROOT/common.c"

const max_events = 1024
const buffer_size = 8096

fn C.viva_listen(port int) int
fn C.viva_epoll_init(port int) int
fn C.viva_wait_epoll_events(lfd int, epfd int, events &C.epoll_event, max_events int, timeout int) int
fn C.viva_accept_new_incom(lfd int) int
fn C.epoll_add_event(epfd int, sock int, flags u32) int
fn C.epoll_del_event(epfd int, sock int) int

fn C.close(fd int) int
fn C.read(fd int, buf voidptr, count usize) int
fn C.write(fd int, buf voidptr, count usize) int
fn C.shutdown(fd int, how int) int

@[typedef]
union C.epoll_data {
mut:
	ptr voidptr
	fd  int
	u32 u32
	u64 u64
}

@[packed]
struct C.epoll_event {
	events u32
	data   C.epoll_data
}

@[inline]
pub fn epoll_close_conn(epfd int, fd int) {
	if C.epoll_del_event(epfd, fd) == -1 {
		eprintln('epoll_del_event ${fd}')
	}
	C.close(fd)
}

@[if trace ?]
pub fn trace(s string) {
	println(s)
}

fn fd_read(fd int, maxbytes int) (string, int) {
	unsafe {
		mut buf := malloc_noscan(maxbytes + 1)
		nbytes := C.read(fd, buf, maxbytes)
		if nbytes < 0 {
			free(buf)
			return '', nbytes
		}
		buf[nbytes] = 0
	    trace('Got ${nbytes} bytes on fd ${fd}')
		return tos(buf, nbytes), nbytes
	}
}

fn fd_write(fd int, s string) {
	mut sp := s.str
	mut remaining := s.len
	for remaining > 0 {
		written := C.write(fd, sp, remaining)
		if written < 0 {
			eprintln('write')
			return
		}
		remaining = remaining - written
		sp = unsafe { voidptr(sp + written) }
	}

	trace('Sent ${s.len} bytes to fd ${fd}')
}

pub struct Response {
	header map[string]string
pub:
	epfd int // epoll file descriptor, used in end()
	fd   int // client file descriptor
	request string
}

// directly writes to file descriptor
@[inline]
pub fn (r Response) write(s string) {
	fd_write(r.fd, s)
}

pub fn (r Response) end() {
	if C.shutdown(r.fd, C.SHUT_WR) == -1 {
		eprintln('shutdown')
	}
	trace('Closing connection on fd ${r.fd}')
	epoll_close_conn(r.epfd, r.fd)
}
