module main

import viva { Response, start }

struct MyServer {
}

@['GET /']
fn (s MyServer) index(res Response) {
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
		<p>This is a simple HTML response.</p
		<p>Your request was:</p>
		<pre>${res.request}</pre>
</body>
</html>'

	res.write(index_page)
	res.end()
}

fn main() {
	mut app := MyServer{}
	start(app, 8080)
}
