import 'dotenv/config';
import app from './app.js';
import { startWsServer } from './ws.js';

const port = Number(process.env.SERVER_PORT || 8080);
const wsPort = Number(process.env.WS_PORT || 8081);

app.listen(port, () => console.log('[http] listening on', port));
startWsServer(wsPort);
