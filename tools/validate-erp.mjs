#!/usr/bin/env node
/**
 * Lightweight static preflight for the Rental Mediator ERP prototype.
 * Run from repository root: node tools/validate-erp.mjs
 * This does not replace browser, database, permissions, migration or accounting tests.
 */
import { readFileSync, existsSync } from 'node:fs';

const required = [
  'index.html',
  'assets/erp.css',
  'assets/erp.js',
  'supabase/rental_erp_schema.sql',
  'tools/setup-and-test.md'
];
const errors = [];
for (const file of required) {
  if (!existsSync(file)) errors.push(`Missing required file: ${file}`);
}
if (errors.length) {
  console.error(errors.join('\n'));
  process.exit(1);
}

const html = readFileSync('index.html', 'utf8');
const app = readFileSync('assets/erp.js', 'utf8');
const sql = readFileSync('supabase/rental_erp_schema.sql', 'utf8');
const readme = readFileSync('README.md', 'utf8');

for (const [label, condition] of [
  ['HTML loads ERP CSS', html.includes('assets/erp.css')],
  ['HTML loads ERP JS', html.includes('assets/erp.js')],
  ['Project closure gate exists', /machine_returned/.test(sql) && /commercial_settled/.test(sql) && /documents_complete/.test(sql) && /reconciled/.test(sql)],
  ['Customer invoice table exists', /create table if not exists public\.erp_customer_invoices/.test(sql)],
  ['Vendor bill table exists', /create table if not exists public\.erp_vendor_bills/.test(sql)],
  ['Payment allocation table exists', /create table if not exists public\.erp_invoice_allocations/.test(sql)],
  ['PO revision history table exists', /create table if not exists public\.erp_po_revisions/.test(sql)],
  ['Prototype limitation disclosed', /localStorage/i.test(readme) && /not production-ready/i.test(readme)],
  ['App uses prototype-local storage (not silently presented as shared database)', /localStorage/.test(app)]
]) {
  if (!condition) errors.push(`FAIL: ${label}`);
  else console.log(`PASS: ${label}`);
}

if (errors.length) {
  console.error('\nPreflight failed:\n' + errors.join('\n'));
  process.exit(1);
}
console.log('\nStatic preflight passed. This is not a production-readiness approval.');
