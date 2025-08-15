import { Router } from 'express';
import { query } from '../db.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const router = Router();

router.post('/register', async (req, res) => {
  try {
    const { email, password } = req.body;
    const hash = await bcrypt.hash(password, 10);
    await query('INSERT INTO users (email, password_hash) VALUES ($1,$2)', [email, hash]);
    res.json({ ok: true });
  } catch (e) {
    res.status(400).json({ ok: false, error: e.message });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const r = await query('SELECT * FROM users WHERE email=$1', [email]);
  if (r.rowCount === 0) return res.status(401).json({ ok: false });

  const user = r.rows[0];
  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) return res.status(401).json({ ok: false });

  const token = jwt.sign({ uid: user.id }, process.env.JWT_SECRET, { expiresIn: '7d' });
  res.json({ ok: true, token });
});

export default router;
