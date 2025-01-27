module main

// const certf = '/home/daniel/Software/cert/server.crt'
// const keyf = '/home/daniel/Software/cert/server.key'

const certf = '/home/daniel/Software/cert/trtest+3.pem'
const keyf = '/home/daniel/Software/cert/trtest+3-key.pem'

@[typedef]
pub struct C.SSL_METHOD {
}

@[typedef]
pub struct C.SSL_CTX {
}

@[typedef]
pub struct C.SSL {
}

fn C.SSL_CTX_new(method &C.SSL_METHOD) &C.SSL_CTX

fn C.SSL_new(ctx &C.SSL_CTX) &C.SSL

fn C.SSL_set_fd(ssl &C.SSL, fd int) int

fn C.SSL_use_certificate_chain_file(ssl &C.SSL, file &char) int
fn C.SSL_use_PrivateKey_file(ssl &C.SSL, file &char, @type int) int

fn C.SSL_accept(ssl &C.SSL) int

fn C.TLS_server_method() &C.SSL_METHOD

fn C.SSL_write(ssl &C.SSL, buf voidptr, buflen int) int

fn C.SSL_read(ssl &C.SSL, buf voidptr, buflen int) int

fn C.SSL_shutdown(&C.SSL) int

fn C.SSL_free(&C.SSL)

fn C.SSL_CTX_use_certificate_file(ctx &C.SSL_CTX, const_file &char, file_type int) int

fn C.SSL_CTX_use_PrivateKey_file(ctx &C.SSL_CTX, const_file &char, file_type int) int
