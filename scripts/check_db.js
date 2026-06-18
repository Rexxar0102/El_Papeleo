const https = require('https');

const SUPABASE_URL = 'tlfeqazjhawrzfwawwjx.supabase.co';
const SERVICE_KEY = 'pega-tu-key-aqui';

function supabaseQuery(path) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: SUPABASE_URL,
      path: path,
      method: 'GET',
      headers: {
        'apikey': SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'Content-Type': 'application/json'
      }
    };
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try { resolve(JSON.parse(data)); } catch(e) { resolve(data); }
      });
    });
    req.on('error', reject);
    req.end();
  });
}

async function main() {
  // Get ALL categorias
  console.log('=== ALL CATEGORIAS ===');
  const cats = await supabaseQuery('/rest/v1/categorias?select=*&order=orden');
  if (Array.isArray(cats)) {
    cats.forEach(c => console.log(`  ${c.id}: ${c.nombre} (icono: ${c.icono}, color: ${c.color}, orden: ${c.orden})`));
    console.log(`Total: ${cats.length}`);
  }

  // Get ALL tramites
  console.log('\n=== ALL TRAMITES ===');
  const trams = await supabaseQuery('/rest/v1/tramites?select=id,nombre,categoria_id,descripcion,requisitos,donde_hacerlo,horarios,costo_cup,plazo_dias&limit=100');
  if (Array.isArray(trams)) {
    trams.forEach(t => console.log(`  ${t.id}: ${t.nombre} [cat: ${t.categoria_id}] requisitos:${t.requisitos?.length || 0} donde:${t.donde_hacerlo ? 'SI' : 'NO'} horarios:${t.horarios ? 'SI' : 'NO'} costo:${t.costo_cup} plazo:${t.plazo_dias}`));
    console.log(`Total: ${trams.length}`);
  }

  // Try to insert a test sugerencia to see the schema
  console.log('\n=== SUGERENCIAS SCHEMA TEST ===');
  const testInsert = await supabaseQuery('/rest/v1/sugerencias?select=*&limit=0');
  console.log('Empty response:', JSON.stringify(testInsert));
}

main();
