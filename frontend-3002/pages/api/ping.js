export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.status(200).json({
    status: 'ok',
    service: 'frontend-b',
    port: 3002,
    timestamp: new Date().toISOString(),
  });
}
