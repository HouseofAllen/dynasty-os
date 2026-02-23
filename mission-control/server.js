const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const WORKSPACE_DIR = path.join(__dirname, '..'); // Up one level to workspace root

const MIME_TYPES = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpg',
    '.gif': 'image/gif',
};

const server = http.createServer((req, res) => {
    console.log(`${req.method} ${req.url}`);

    // API: Get Tasks
    if (req.url === '/api/tasks' && req.method === 'GET') {
        const tasksPath = path.join(__dirname, 'tasks.json');
        if (fs.existsSync(tasksPath)) {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(fs.readFileSync(tasksPath));
        } else {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ todo: [], "in-progress": [], done: [] }));
        }
        return;
    }

    // API: Save Tasks
    if (req.url === '/api/tasks' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            try {
                fs.writeFileSync(path.join(__dirname, 'tasks.json'), body);
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ status: 'ok' }));
            } catch (e) {
                res.writeHead(500);
                res.end(JSON.stringify({ error: e.message }));
            }
        });
        return;
    }

    // API: Get Leads
    if (req.url === '/api/leads' && req.method === 'GET') {
        const leadsPath = path.join(WORKSPACE_DIR, 'solar', 'leads.json');
        if (fs.existsSync(leadsPath)) {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(fs.readFileSync(leadsPath));
        } else {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify([]));
        }
        return;
    }

    // API: Get Gigs
    if (req.url === '/api/gigs' && req.method === 'GET') {
        const gigsPath = path.join(WORKSPACE_DIR, 'gigs', 'leads.json');
        if (fs.existsSync(gigsPath)) {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(fs.readFileSync(gigsPath));
        } else {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify([]));
        }
        return;
    }

    // Static File Serving
    let filePath = req.url === '/' ? 'index.html' : req.url;
    // Strip leading slash
    if (filePath.startsWith('/')) filePath = filePath.substring(1);
    
    // Resolve path (security check: ensure it stays within workspace)
    let fullPath = path.join(__dirname, filePath);
    
    // Allow reading from root workspace for things like solar/leads.json if needed directly
    // But for this simple server, we assume everything is relative to mission-control or explicity exposed via API
    
    const ext = path.extname(fullPath);
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    fs.readFile(fullPath, (err, content) => {
        if (err) {
            if (err.code === 'ENOENT') {
                res.writeHead(404);
                res.end('404 Not Found');
            } else {
                res.writeHead(500);
                res.end(`Server Error: ${err.code}`);
            }
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content, 'utf-8');
        }
    });
});

server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
});