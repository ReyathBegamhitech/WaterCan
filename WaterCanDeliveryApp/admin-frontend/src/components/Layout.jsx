import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';

export default function Layout() {
  return (
    <div className="bg-surface-container font-body-md text-on-surface antialiased min-h-screen">
      <Sidebar />
      <div className="pl-64 flex flex-col min-h-screen">
        <Header />
        <main className="w-full pt-24 bg-surface-container flex-1 px-gutter pb-space-lg">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
