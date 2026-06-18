const https = require('https');

const SUPABASE_URL = 'tlfeqazjhawrzfwawwjx.supabase.co';
const SERVICE_KEY = 'pega-tu-key-aqui';

function supabaseRequest(method, path, body) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: SUPABASE_URL,
      path: path,
      method: method,
      headers: {
        'apikey': SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
      }
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, data }));
    });

    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function main() {
  const categoriesToDelete = [
    'directorios-en-el-exterior',
    'directorios-en-cuba',
    'transporte-en-cuba',
    'servicio-militar-y-defensa-en-cuba',
    'servicios-comunales-en-cuba',
    'seguros-en-cuba',
    'seguridad-social-en-cuba'
  ];

  for (const catId of categoriesToDelete) {
    try {
      const res = await supabaseRequest('DELETE', `/rest/v1/categorias?id=eq.${catId}`);
      console.log(`Delete ${catId}: status=${res.status}`);
    } catch (e) {
      console.error(`Error deleting ${catId}:`, e.message);
    }
  }

  // Verify remaining categories
  const checkRes = await new Promise((resolve, reject) => {
    const options = {
      hostname: SUPABASE_URL,
      path: '/rest/v1/categorias?select=id,nombre&order=orden',
      method: 'GET',
      headers: {
        'apikey': SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
      }
    };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => resolve(JSON.parse(data)));
    });
    req.on('error', reject);
    req.end();
  });

  console.log('\n=== Remaining categories ===');
  checkRes.forEach(c => console.log(`  ${c.id}: ${c.nombre}`));
}

main();
