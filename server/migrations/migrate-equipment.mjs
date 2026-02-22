/**
 * migrate-equipment.mjs — One-time migration: game_data items/equippedArtifacts → inventory_items + equip_slots
 * 
 * Run: node server/migrations/migrate-equipment.mjs
 * Safe to run multiple times (checks original_id to avoid duplicates).
 */
import pg from 'pg';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const env = process.env.GAME_ENV || 'test';
dotenv.config({ path: join(__dirname, '..', '.env.' + env) });
dotenv.config({ path: join(__dirname, '..', '.env') });

const pool = new pg.Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://roon_user:RoonG%40ming2026!@127.0.0.1:5432/xiuxian_test',
  max: 5
});

async function migrate() {
  console.log('[Migration] Starting equipment migration...');
  console.log('[Migration] DB:', (process.env.DATABASE_URL || '').split('/').pop());

  const players = await pool.query('SELECT id, wallet, game_data FROM players');
  let totalItems = 0, totalEquipped = 0, skipped = 0;

  for (const p of players.rows) {
    const gd = typeof p.game_data === 'string' ? JSON.parse(p.game_data) : (p.game_data || {});
    const items = gd.items || [];
    const equipped = gd.equippedArtifacts || {};

    // Migrate bag items (only equipment, not pills/herbs/pet items)
    for (const item of items) {
      if (!item.type || !item.stats) continue; // skip non-equipment
      if (item.type === 'pill' || item.type === 'pet' || item.type === 'herb') continue;

      const origId = String(item.id);
      // Check if already migrated
      const exists = await pool.query('SELECT id FROM inventory_items WHERE player_id=$1 AND original_id=$2', [p.id, origId]);
      if (exists.rows.length) { skipped++; continue; }

      await pool.query(
        `INSERT INTO inventory_items (player_id, original_id, name, type, quality, stats, attributes, enhance_level, source)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [p.id, origId, item.name || '未知装备', item.type, item.quality || 'common',
         JSON.stringify(item.stats || {}), JSON.stringify(item.attributes || {}),
         item.enhanceLevel || 0, 'migration']
      );
      totalItems++;
    }

    // Migrate equipped items
    for (const [slot, item] of Object.entries(equipped)) {
      if (!item || !item.stats) continue;

      const origId = String(item.id);
      // Check if already migrated
      let invRow = await pool.query('SELECT id FROM inventory_items WHERE player_id=$1 AND original_id=$2', [p.id, origId]);
      
      if (!invRow.rows.length) {
        // Insert the equipped item into inventory_items first
        invRow = await pool.query(
          `INSERT INTO inventory_items (player_id, original_id, name, type, quality, stats, attributes, enhance_level, source)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING id`,
          [p.id, origId, item.name || '未知装备', item.type || slot, item.quality || 'common',
           JSON.stringify(item.stats || {}), JSON.stringify(item.attributes || {}),
           item.enhanceLevel || 0, 'migration']
        );
        totalItems++;
      }

      const itemId = invRow.rows[0].id;

      // Upsert equip_slots
      await pool.query(
        `INSERT INTO equip_slots (player_id, slot, item_id) VALUES ($1, $2, $3)
         ON CONFLICT (player_id, slot) DO UPDATE SET item_id = $3, updated_at = now()`,
        [p.id, slot, itemId]
      );
      totalEquipped++;
    }
  }

  console.log(`[Migration] Done: ${totalItems} items migrated, ${totalEquipped} slots set, ${skipped} skipped (already exists)`);
  console.log(`[Migration] Players processed: ${players.rows.length}`);
  await pool.end();
}

migrate().catch(e => { console.error('[Migration] ERROR:', e); pool.end(); process.exit(1); });
