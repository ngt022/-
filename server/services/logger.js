/**
 * logger.js — Centralized pino logger with request-id support.
 */
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: process.env.NODE_ENV === 'development' ? {
    target: 'pino/file',
    options: { destination: 1 } // stdout
  } : undefined,
  formatters: {
    level(label) { return { level: label }; }
  },
  timestamp: pino.stdTimeFunctions.isoTime
});

export default logger;

/**
 * Express middleware: attach request-id and child logger to req.
 */
let reqCounter = 0;
export function requestLogger(req, res, next) {
  const reqId = req.headers['x-request-id'] || `r${++reqCounter}`;
  req.reqId = reqId;
  req.log = logger.child({ reqId, method: req.method, url: req.url });
  
  const start = Date.now();
  res.on('finish', () => {
    const ms = Date.now() - start;
    const lvl = res.statusCode >= 500 ? 'error' : res.statusCode >= 400 ? 'warn' : 'info';
    req.log[lvl]({ status: res.statusCode, ms }, 'request');
  });
  
  next();
}
