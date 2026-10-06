import './globals.css';
import {NextIntlClientProvider} from 'next-intl';
import {getLocale, getMessages} from 'next-intl/server';
import {Header} from '@/components/header';
import {Footer} from '@/components/footer';

export const metadata = {
  title: 'Sangam Yatra — Gaya Pitru Paksha yatra, simple and fair.',
  description:
    'A transparent directory for stays, pandas and local services in Gaya, Bihar.',
};

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const locale = await getLocale();
  const messages = await getMessages();

  return (
    <html lang={locale}>
      <body>
        <NextIntlClientProvider messages={messages}>
          <Header />
          <main>{children}</main>
          <Footer />
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
