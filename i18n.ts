import {getRequestConfig} from 'next-intl/server';
export const locales=['hi','en'] as const;
export type Locale=(typeof locales)[number];
export default getRequestConfig(async ({requestLocale})=>{const locale=(await requestLocale)||'hi';const safe=(locales as readonly string[]).includes(locale)?locale:'hi';return {locale:safe,messages:(await import(`./messages/${safe}.json`)).default};});
