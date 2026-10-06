import {createClient} from './supabase/server';
import type {Category,Listing} from './types';

const fallback: Listing[] = [
  {
    id:'fallback-stay-1',category:'stay',title:'गया धर्मशाला',title_hi:null,slug:'gaya-dharmshala',
    description:'साफ़-सुथरी बजट ठहरने की जगह।',description_hi:null,locality:'विष्णुपद',
    full_address:null,latitude:null,longitude:null,distance_to_vishnupad_km:0.6,status:'published',
    is_verified:true,is_founder_family:false,featured:true,sort_order:1,platform_fee_amount:0,
    created_at:new Date(0).toISOString(),updated_at:new Date(0).toISOString(),images:[]
  },
  {
    id:'fallback-panda-1',category:'panda',title:'पितृ कर्म सेवा',title_hi:null,slug:'pitru-karma-seva',
    description:'पिंड दान एवं श्राद्ध कर्म के लिए संपर्क अनुरोध भेजें।',description_hi:null,locality:'फल्गु घाट',
    full_address:null,latitude:null,longitude:null,distance_to_vishnupad_km:1.2,status:'published',
    is_verified:true,is_founder_family:false,featured:true,sort_order:2,platform_fee_amount:0,
    created_at:new Date(0).toISOString(),updated_at:new Date(0).toISOString(),images:[]
  }
];

function hasSupabaseEnv(){
  return Boolean(process.env.NEXT_PUBLIC_SUPABASE_URL && process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY);
}

export async function getListings(category?:Category,params?:{q?:string;locality?:string;verified?:boolean;sort?:string}){
  if(!hasSupabaseEnv()){
    let rows=fallback.filter(x=>!category||x.category===category);
    if(params?.q){
      const q=params.q.toLowerCase();
      rows=rows.filter(x=>[x.title,x.title_hi,x.description,x.description_hi].some(v=>v?.toLowerCase().includes(q)));
    }
    if(params?.verified) rows=rows.filter(x=>x.is_verified);
    if(params?.sort==='nearest') rows=[...rows].sort((a,b)=>(a.distance_to_vishnupad_km??999)-(b.distance_to_vishnupad_km??999));
    return rows;
  }
  const supabase=await createClient();
  let query=supabase.from('listings').select('*,listing_images(*)').eq('status','published');
  if(category)query=query.eq('category',category);
  if(params?.q)query=query.or(`title.ilike.%${params.q}%,title_hi.ilike.%${params.q}%,description.ilike.%${params.q}%`);
  if(params?.locality)query=query.eq('locality',params.locality);
  if(params?.verified)query=query.eq('is_verified',true);
  if(params?.sort==='nearest')query=query.order('distance_to_vishnupad_km',{ascending:true,nullsFirst:false});
  else if(params?.sort==='newest')query=query.order('created_at',{ascending:false});
  else query=query.order('featured',{ascending:false}).order('sort_order',{ascending:true});
  const{data,error}=await query.limit(48);
  if(error)throw error;
  return((data??[])as any[]).map(row=>({...row,images:(row.listing_images??[]).map((img:any)=>({...img,public_url:img.public_url||img.storage_path}))}))as Listing[];
}

export async function getListing(slug:string){
  if(!hasSupabaseEnv()) return fallback.find(x=>x.slug===slug)??null;
  const supabase=await createClient();
  const{data,error}=await supabase.from('listings').select('*,listing_images(*),stay_details(*),panda_details(*),food_details(*),transport_details(*),shop_details(*),guide_details(*),other_details(*)').eq('slug',slug).eq('status','published').maybeSingle();
  if(error)throw error;
  if(!data)return null;
  return{...data,images:(data.listing_images??[]).map((img:any)=>({...img,public_url:img.public_url||img.storage_path}))}as Listing;
}
