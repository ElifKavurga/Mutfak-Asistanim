const http = require("http");
const https = require("https");
const fs = require("fs");
const path = require("path");

const isProduction = process.env.NODE_ENV === "production";
const host = process.env.HOST || (isProduction ? "0.0.0.0" : "127.0.0.1");
const port = Number.parseInt(process.env.PORT || "3000", 10);
const backendUrl = (process.env.BACKEND_URL || "").trim();
const rootDir = path.join(__dirname, "build", "web");

const mimeTypes = {
  ".css": "text/css; charset=utf-8",
  ".dart": "application/dart; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".ico": "image/x-icon",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".map": "application/json; charset=utf-8",
  ".png": "image/png",
  ".svg": "image/svg+xml; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
  ".wasm": "application/wasm",
  ".xml": "application/xml; charset=utf-8",
};

function resolveRequestPath(urlPath) {
  const sanitizedPath = decodeURIComponent((urlPath || "/").split("?")[0]);
  const requestedPath = sanitizedPath === "/" ? "/index.html" : sanitizedPath;
  const normalizedPath = path.normalize(requestedPath).replace(/^(\.\.[/\\])+/, "");
  return path.join(rootDir, normalizedPath);
}

function isApiRequest(urlPath) {
  const sanitizedPath = (urlPath || "/").split("?")[0];
  return (
    sanitizedPath === "/authenticate" ||
    sanitizedPath === "/register" ||
    sanitizedPath === "/refreshToken" ||
    sanitizedPath === "/dashboard" ||
    sanitizedPath.startsWith("/rest/api/")
  );
}

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
  });
  res.end(JSON.stringify(payload));
}

function proxyRequest(req, res) {
  if (!backendUrl) {
    sendJson(res, 503, {
      status: "error",
      message: "BACKEND_URL tanimli degil.",
    });
    return;
  }

  const targetUrl = new URL(req.url, backendUrl);
  const transport = targetUrl.protocol === "https:" ? https : http;
  const forwardedFor = req.socket.remoteAddress || "";
  const forwardedProto =
    req.headers["x-forwarded-proto"] || (req.socket.encrypted ? "https" : "http");
  const headers = {
    ...req.headers,
    host: targetUrl.host,
    "x-forwarded-host": req.headers.host || "",
    "x-forwarded-proto": forwardedProto,
    "x-forwarded-for": forwardedFor,
  };

  const proxyReq = transport.request(
    {
      protocol: targetUrl.protocol,
      hostname: targetUrl.hostname,
      port: targetUrl.port || undefined,
      method: req.method,
      path: `${targetUrl.pathname}${targetUrl.search}`,
      headers,
    },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode || 502, proxyRes.headers);
      proxyRes.pipe(res);
    },
  );

  proxyReq.on("error", (error) => {
    sendJson(res, 502, {
      status: "error",
      message: "Backend proxy istegi basarisiz oldu.",
      detail: error.message,
    });
  });

  req.pipe(proxyReq);
}

const server = http.createServer((req, res) => {
  const requestPath = (req.url || "/").split("?")[0];

  if (requestPath === "/health") {
    sendJson(res, 200, {
      status: "ok",
      service: "frontend",
      backendConfigured: backendUrl.length > 0,
    });
    return;
  }

  if (isApiRequest(req.url)) {
    proxyRequest(req, res);
    return;
  }

  const targetPath = resolveRequestPath(req.url);

  fs.readFile(targetPath, (readError, fileBuffer) => {
    if (!readError) {
      const extension = path.extname(targetPath).toLowerCase();
      res.writeHead(200, {
        "Content-Type": mimeTypes[extension] || "application/octet-stream",
      });
      res.end(fileBuffer);
      return;
    }

    const fallbackPath = path.join(rootDir, "index.html");
    fs.readFile(fallbackPath, (fallbackError, fallbackBuffer) => {
      if (fallbackError) {
        res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
        res.end("Not Found");
        return;
      }

      res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
      res.end(fallbackBuffer);
    });
  });
});

server.listen(port, host, () => {
  const browserUrl = !isProduction && host === "127.0.0.1"
    ? `http://127.0.0.1:${port}`
    : `http://${host}:${port}`;
  console.log(`Serving ${rootDir} at ${browserUrl}`);
  if (backendUrl) {
    console.log(`Proxying API requests to ${backendUrl}`);
  } else {
    console.log("BACKEND_URL tanimli olmadigi icin API istekleri 503 donecek.");
  }
});
