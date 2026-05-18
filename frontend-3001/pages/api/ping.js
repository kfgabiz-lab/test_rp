export default function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.status(200).json({
    status: 'ok',
    service: 'frontend-a',
    port: 3001,
    timestamp: new Date().toISOString(),
  });
}
