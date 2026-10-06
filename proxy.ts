import {createServerClient} from '@supabase/ssr';
import {NextResponse,type NextRequest} from 'next/server';
export async function proxy(request:NextRequest){
 let response=NextResponse.next({request});
 const supabase=createServerClient(process.env.NEXT_PUBLIC_SUPABASE_URL!,process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,{cookies:{getAll:()=>request.cookies.getAll(),setAll:(cookies)=>{cookies.forEach(({name,value})=>request.cookies.set(name,value));response=NextResponse.next({request});cookies.forEach(({name,value,options})=>response.cookies.set(name,value,options));}}});
 await supabase.auth.getClaims();
 const requireBrowse=process.env.REQUIRE_LOGIN_TO_BROWSE==='true';
 if(requireBrowse&&(request.nextUrl.pathname.startsWith('/listings')||request.nextUrl.pathname.startsWith('/listing'))){const{data:{user}}=await supabase.auth.getUser();if(!user)return NextResponse.redirect(new URL('/auth/login?next='+encodeURIComponent(request.nextUrl.pathname),request.url));}
 response.headers.set('Cache-Control','private, no-store');
 response.headers.set('X-Content-Type-Options','nosniff');response.headers.set('Referrer-Policy','strict-origin-when-cross-origin');response.headers.set('X-Frame-Options','DENY');response.headers.set('Permissions-Policy','camera=(),microphone=(),geolocation=()');
 return response;
}
export const config={matcher:['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)']};
