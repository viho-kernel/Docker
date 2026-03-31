const http = require("http");

http.createServer((req, res) => {
  res.end("Hello from Node Docker!");
}).listen(3000);