import './globals.css';
import {Header} from '@/components/header';
import {Footer} from '@/components/footer';

export const metadata = {
  title: 'Sangam Yatra — Gaya Pitru Paksha yatra, simple and fair.',
  description:
    'A transparent directory for stays, pandas and local services in Gaya, Bihar.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="hi">
      <body>
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
