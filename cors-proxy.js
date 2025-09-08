const http = require('http');
const httpProxy = require('http-proxy-middleware');
const express = require('express');

const app = express();
const PORT = 8082;
const NEXUS_URL = 'http://localhost:8081';

// CORS middleware
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, HEAD, OPTIONS');
    res.header('Access-Control-Allow-Headers', '*');
    res.header('Access-Control-Expose-Headers', '*');
    res.header('Access-Control-Allow-Credentials', 'true');
    
    if (req.method === 'OPTIONS') {
        res.header('Access-Control-Max-Age', '86400');
        return res.status(204).end();
    }
    next();
});

// Proxy middleware
const proxy = httpProxy.createProxyMiddleware({
    target: NEXUS_URL,
    changeOrigin: true,
    logLevel: 'info'
});

app.use('/', proxy);

app.listen(PORT, () => {
    console.log(`🚀 CORS proxy running on http://localhost:${PORT}`);
    console.log(`📦 Proxying to Nexus: ${NEXUS_URL}`);
    console.log(`🌐 NPM registry: http://localhost:${PORT}/repository/npm-group/`);
});