import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  if (req.method !== 'POST') return new Response(JSON.stringify({error:'Method not allowed'}), {status:405,headers:{...cors,'Content-Type':'application/json'}});

  try {
    const body = await req.json();
    const required = ['customer_name','phone','project_location'];
    for (const field of required) {
      if (!String(body[field] ?? '').trim()) throw new Error(`${field} is required`);
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    const payload = {
      customer_name: String(body.customer_name).trim(),
      company_name: body.company_name ? String(body.company_name).trim() : null,
      email: body.email ? String(body.email).trim() : null,
      phone: String(body.phone).trim(),
      equipment_id: body.equipment_id || null,
      quantity: Math.max(1, Number(body.quantity || 1)),
      project_location: String(body.project_location).trim(),
      start_date: body.start_date || null,
      rental_duration: body.rental_duration ? String(body.rental_duration).trim() : null,
      message: body.message ? String(body.message).trim() : null,
      source: 'website',
      status: 'new'
    };

    const { data, error } = await supabase.from('enquiries').insert(payload).select('id,enquiry_number').single();
    if (error) throw error;

    return new Response(JSON.stringify({ok:true, enquiry:data}), {status:201,headers:{...cors,'Content-Type':'application/json'}});
  } catch (error) {
    return new Response(JSON.stringify({ok:false,error:error instanceof Error ? error.message : 'Unable to create enquiry'}), {status:400,headers:{...cors,'Content-Type':'application/json'}});
  }
});
