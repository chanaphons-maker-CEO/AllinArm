import express from 'express';
import cors from 'cors';
import authRouter from './routes/auth.js';
import jobsRouter from './routes/jobs.js';

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

app.get('/health', (req, res) => res.json({ ok: true }));

app.use('/auth', authRouter);
app.use('/jobs', jobsRouter);

// STT proxy (placeholder)
app.get('/stt/ping', (req, res) => res.json({ ok: true, mode: 'whisper-proxy-alive' }));

export default app;
