#!/usr/bin/env node
// Per-file and total line coverage from an lcov file (M2 files marked *).
//   flutter test --coverage && node scripts/coverage_summary.cjs coverage/lcov.info
const fs = require('fs');
const records = fs.readFileSync(process.argv[2] || 'coverage/lcov.info', 'utf8').split('end_of_record');
const rows = [];
let H = 0, F = 0;
for (const r of records) {
  const sf = (r.match(/SF:(.*)/) || [])[1];
  if (!sf) continue;
  const lf = +(r.match(/LF:(\d+)/) || [0, 0])[1];
  const lh = +(r.match(/LH:(\d+)/) || [0, 0])[1];
  H += lh; F += lf;
  rows.push([sf.split(/[\\/]/).join('/').replace(/.*lib\//, 'lib/'), lh, lf]);
}
const m2 = ['basket_balance_service', 'basket_balance_sheet', 'wic_categories', 'apl_service', 'app_state', 'nutritional_utils'];
rows.sort((a, b) => (a[0] < b[0] ? -1 : 1));
for (const [f, h, l] of rows) {
  const mark = m2.some((k) => f.includes(k)) ? '* ' : '  ';
  console.log(mark + f.padEnd(50), `${h}/${l}`.padStart(9), `${(100 * h / l).toFixed(1)}%`);
}
console.log('TOTAL', `${H}/${F}`, `${(100 * H / F).toFixed(1)}%`);
