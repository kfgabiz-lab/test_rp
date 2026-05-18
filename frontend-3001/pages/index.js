import { useState, useEffect, useCallback } from 'react';

const SERVICES = [
  { name: 'Backend (Spring Boot)', url: 'http://localhost:8080/api/ping', port: 8080, accent: '#4CAF50' },
  { name: 'Frontend A (Self)', url: 'http://localhost:3001/api/ping', port: 3001, accent: '#2196F3' },
  { name: 'Frontend B', url: 'http://localhost:3002/api/ping', port: 3002, accent: '#9C27B0' },
];

function StatusCard({ service, result }) {
  const ok = result?.ok;
  const pending = result === undefined;

  return (
    <div style={{
      background: '#16213e',
      border: `2px solid ${pending ? '#444' : ok ? service.accent : '#f44336'}`,
      borderRadius: '10px',
      padding: '20px 24px',
      marginBottom: '14px',
      transition: 'border-color 0.3s',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '10px' }}>
        <span style={{
          width: '13px', height: '13px', borderRadius: '50%',
          background: pending ? '#666' : ok ? service.accent : '#f44336',
          boxShadow: pending ? 'none' : ok ? `0 0 10px ${service.accent}` : '0 0 10px #f44336',
          display: 'inline-block',
          flexShrink: 0,
        }} />
        <span style={{ fontSize: '17px', fontWeight: 'bold', color: '#eee' }}>{service.name}</span>
        <span style={{ color: '#666', fontSize: '13px' }}>localhost:{service.port}</span>
        <span style={{
          marginLeft: 'auto',
          fontSize: '13px',
          fontWeight: 'bold',
          color: pending ? '#888' : ok ? service.accent : '#f44336',
        }}>
          {pending ? 'CHECKING...' : ok ? `OPEN  (${result.status})` : 'BLOCKED'}
        </span>
      </div>

      {result && (
        <div style={{ fontSize: '12px', color: '#888', paddingLeft: '25px' }}>
          {ok ? (
            <>
              <span style={{ marginRight: '20px' }}>latency: <b style={{ color: '#ccc' }}>{result.latency}ms</b></span>
              <span>response: <b style={{ color: '#ccc' }}>{JSON.stringify(result.data)}</b></span>
            </>
          ) : (
            <span style={{ color: '#f44336' }}>error: {result.error}</span>
          )}
        </div>
      )}
    </div>
  );
}

export default function Home() {
  const [results, setResults] = useState({});
  const [lastChecked, setLastChecked] = useState(null);
  const [checking, setChecking] = useState(false);

  const checkAll = useCallback(async () => {
    if (checking) return;
    setChecking(true);

    const newResults = {};
    await Promise.all(
      SERVICES.map(async (service) => {
        const start = Date.now();
        try {
          const controller = new AbortController();
          const timeout = setTimeout(() => controller.abort(), 3000);
          const res = await fetch(service.url, { signal: controller.signal });
          clearTimeout(timeout);
          const data = await res.json();
          newResults[service.port] = { ok: true, status: res.status, latency: Date.now() - start, data, error: null };
        } catch (err) {
          newResults[service.port] = {
            ok: false, status: null, latency: Date.now() - start, data: null,
            error: err.name === 'AbortError' ? 'Timeout (3s)' : err.message,
          };
        }
      })
    );

    setResults(newResults);
    setLastChecked(new Date().toLocaleTimeString());
    setChecking(false);
  }, [checking]);

  useEffect(() => {
    checkAll();
    const id = setInterval(checkAll, 5000);
    return () => clearInterval(id);
  }, []);

  const allOk = Object.values(results).length === SERVICES.length && Object.values(results).every((r) => r.ok);
  const anyFail = Object.values(results).some((r) => !r.ok);

  return (
    <div style={{ fontFamily: "'Courier New', monospace", padding: '48px 40px', background: '#0f0f1a', minHeight: '100vh', color: '#eee' }}>
      <div style={{ maxWidth: '700px', margin: '0 auto' }}>
        <div style={{ marginBottom: '8px', color: '#2196F3', fontSize: '13px' }}>FIREWALL TEST DASHBOARD</div>
        <h1 style={{ color: '#2196F3', margin: '0 0 6px', fontSize: '26px' }}>Frontend A — Port 3001</h1>

        <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '32px', color: '#666', fontSize: '13px' }}>
          <span>마지막 확인: {lastChecked ?? '—'}</span>
          <span style={{
            padding: '3px 10px', borderRadius: '12px', fontSize: '12px', fontWeight: 'bold',
            background: anyFail ? '#f4433622' : allOk ? '#4CAF5022' : '#66666622',
            color: anyFail ? '#f44336' : allOk ? '#4CAF50' : '#888',
            border: `1px solid ${anyFail ? '#f44336' : allOk ? '#4CAF50' : '#444'}`,
          }}>
            {anyFail ? '일부 차단됨' : allOk ? '모두 연결됨' : '확인 중...'}
          </span>
          <button
            onClick={checkAll}
            disabled={checking}
            style={{
              marginLeft: 'auto', background: '#2196F3', color: '#fff', border: 'none',
              padding: '6px 16px', cursor: checking ? 'not-allowed' : 'pointer',
              borderRadius: '5px', opacity: checking ? 0.6 : 1, fontSize: '13px',
            }}
          >
            {checking ? '확인 중...' : '새로고침'}
          </button>
        </div>

        {SERVICES.map((service) => (
          <StatusCard key={service.port} service={service} result={results[service.port]} />
        ))}

        <div style={{ marginTop: '24px', color: '#444', fontSize: '11px' }}>
          자동 새로고침: 5초 간격 &nbsp;|&nbsp; timeout: 3초
        </div>
      </div>
    </div>
  );
}
