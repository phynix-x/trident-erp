const equipment=[
{id:1,cat:'access',category:'Access & Lifting',name:'Boom Lift',spec:'60 FT (18.3 M)',type:'Diesel',qty:4,apps:'Construction, Industrial, Maintenance',icon:'↗'},
{id:2,cat:'access',category:'Access & Lifting',name:'Boom Lift',spec:'80 FT (24.4 M)',type:'Diesel',qty:2,apps:'Construction, Industrial, Maintenance',icon:'↗'},
{id:3,cat:'access',category:'Access & Lifting',name:'Boom Lift',spec:'100 FT (30.5 M)',type:'Diesel',qty:1,apps:'High Reach Applications',icon:'↗'},
{id:4,cat:'access',category:'Access & Lifting',name:'Scissor Lift',spec:'12 M (Electric)',type:'Electric',qty:4,apps:'Indoor, Warehouses, Maintenance',icon:'⇧'},
{id:5,cat:'access',category:'Access & Lifting',name:'Scissor Lift',spec:'16 M (Electric)',type:'Electric',qty:4,apps:'Indoor, Warehouses, Maintenance',icon:'⇧'},
{id:6,cat:'access',category:'Access & Lifting',name:'Truck Mounted Boom Lift',spec:'28 M',type:'Diesel',qty:2,apps:'Street Light, Telecom, Maintenance',icon:'↗'},
{id:7,cat:'access',category:'Access & Lifting',name:'Spider Lift',spec:'18 M',type:'Electric',qty:1,apps:'Tight Access, Façade Work',icon:'◈'},
{id:8,cat:'access',category:'Access & Lifting',name:'Telehandler',spec:'17 M Lift / 4.5 Ton',type:'Diesel',qty:2,apps:'Material Handling, Construction',icon:'⇧'},
{id:9,cat:'material',category:'Material Handling',name:'Forklift',spec:'3 Ton Diesel',type:'Diesel',qty:2,apps:'Warehouses, Material Handling',icon:'⇧'},
{id:10,cat:'material',category:'Material Handling',name:'Forklift',spec:'5 Ton Diesel',type:'Diesel',qty:2,apps:'Warehouses, Material Handling',icon:'⇧'}
];
const grid=document.getElementById('equipmentGrid');
function render(items=equipment){grid.innerHTML=items.map(e=>`<article class="equipment-card"><div class="equipment-image">${e.icon}</div><span class="tag">${e.category.toUpperCase()}</span><h3>${e.name} — ${e.spec}</h3><p>${e.type} · Listed quantity: ${e.qty}</p><p>${e.apps}</p><div class="card-actions"><button class="small-btn" onclick="viewEquipment(${e.id})">View Details</button><button class="small-btn" onclick="openQuote(${e.id})">Quote</button></div></article>`).join('')||'<p>No matching equipment found.</p>';}
function viewEquipment(id){const e=equipment.find(x=>x.id===id);document.getElementById('detailContent').innerHTML=`<p class="eyebrow">${e.category}</p><h2>${e.name}</h2><p>${e.spec}</p><div class="detail-specs"><div><small>Specification</small><b>${e.spec}</b></div><div><small>Power / Type</small><b>${e.type}</b></div><div><small>Listed quantity</small><b>${e.qty} units</b></div><div><small>Applications</small><b>${e.apps}</b></div></div><p>Availability is subject to prior confirmation for the requested project dates and location.</p><button class="btn btn-primary" onclick="closeModals();openQuote(${e.id})">Request Quote</button>`;document.getElementById('detailModal').classList.add('open');}
function openQuote(id){const select=document.getElementById('quoteEquipment');select.innerHTML='<option value="">Select equipment</option>'+equipment.map(e=>`<option value="${e.id}" ${id===e.id?'selected':''}>${e.name} — ${e.spec}</option>`).join('');document.getElementById('quoteModal').classList.add('open');}
function closeModals(){document.querySelectorAll('.modal').forEach(m=>m.classList.remove('open'));}
document.querySelectorAll('[data-quote]').forEach(b=>b.addEventListener('click',()=>openQuote()));
document.querySelectorAll('[data-close]').forEach(b=>b.addEventListener('click',closeModals));
document.querySelectorAll('.modal').forEach(m=>m.addEventListener('click',e=>{if(e.target===m)m.classList.remove('open')}));
document.getElementById('quoteForm').addEventListener('submit',e=>{e.preventDefault();document.getElementById('formMessage').textContent='Enquiry captured in prototype mode. Connect Supabase to persist this lead.';e.target.reset();});
function filter(){const q=document.getElementById('searchInput').value.toLowerCase();const c=document.getElementById('categoryFilter').value;render(equipment.filter(e=>(c==='all'||e.cat===c)&&`${e.name} ${e.spec} ${e.apps}`.toLowerCase().includes(q)));document.getElementById('equipment').scrollIntoView({behavior:'smooth'});}
document.getElementById('searchBtn').addEventListener('click',filter);document.getElementById('searchInput').addEventListener('keydown',e=>{if(e.key==='Enter')filter()});
const menu=document.getElementById('nav');document.getElementById('menuBtn').addEventListener('click',()=>menu.classList.toggle('open'));document.querySelectorAll('#nav a').forEach(a=>a.addEventListener('click',()=>menu.classList.remove('open')));
render();
window.viewEquipment=viewEquipment;window.openQuote=openQuote;window.closeModals=closeModals;
