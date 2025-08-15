import { WebSocketServer } from 'ws';

export function startWsServer(port) {
  const wss = new WebSocketServer({ port });
  const clients = new Set();

  wss.on('connection', (ws) => {
    clients.add(ws);
    ws.on('message', (msg) => {
      // broadcast แบบง่าย
      for (const c of clients) {
        if (c.readyState === 1) c.send(msg.toString());
      }
    });
    ws.on('close', () => clients.delete(ws));
  });

  console.log('[ws] listening on', port);
}
