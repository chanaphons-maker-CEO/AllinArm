import { Router } from 'express';
import { query } from '../db.js';
import jwt from 'jsonwebtoken';

const router = Router();

function auth(req, res, next) {
  const h = req.headers.authorization || '';
  const token = h.startsWith('Bearer ') ? h.slice(7) : null;
  if (!token) return res.status(401).json({ ok: false });
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ ok: false });
  }
}

router.get('/', auth, async (req, res) => {
  const r = await query('SELECT * FROM jobs WHERE user_id=$1 ORDER BY id DESC', [req.user.uid]);
  res.json({ ok: true, data: r.rows });
});

router.post('/', auth, async (req, res) => {
  const { title, description } = req.body;
  const r = await query(
    'INSERT INTO jobs (user_id, title, description) VALUES ($1,$2,$3) RETURNING *',
    [req.user.uid, title, description]
  );
  res.json({ ok: true, data: r.rows[0] });
});

router.delete('/:id', auth, async (req, res) => {
  const id = Number(req.params.id);
  await query('DELETE FROM jobs WHERE id=$1 AND user_id=$2', [id, req.user.uid]);
  res.json({ ok: true });
});

export default router;
