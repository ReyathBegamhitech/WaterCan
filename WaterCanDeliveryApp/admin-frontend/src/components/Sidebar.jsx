import { NavLink } from 'react-router-dom';

export default function Sidebar() {
  return (
    <aside className="fixed left-0 top-0 h-screen w-64 bg-surface-container-lowest border-r border-outline-variant/30 z-50 flex flex-col justify-between shadow-[0_1px_8px_rgba(0,0,0,0.02)]">
      <div className="flex flex-col">
        <div className="h-16 px-space-md flex items-center gap-space-sm border-b border-outline-variant/20">
          <img
            alt="AquaFlow Water Delivery Admin Logo"
            className="h-8 w-auto object-contain"
            src="https://lh3.googleusercontent.com/aida/AEtjO1W9O2c-t0fJguo1QisCIOsVdSrR9zXwVNkWYkAAvd5fNUcKQK0Cri3MyKnu__aeWMGjzloTCkFI7E81-XHsDOLULG6vIS47vHwRqVRTnAc5IMCWjYA0y9RppSguoFEA8JJPOTHU7DjSeqSAMHBPSZJDlq-NLHZah9MNyvHmLZIVWBE1a0vYSI7RtW6dPRHF2DuQlK70oipspS5vU3bBqWhCvWAXeXZ1LUVBzgoWbgG5ACNIco2YmRivMp4"
          />
          <div className="flex flex-col">
            <span className="font-headline-sm text-headline-sm text-primary tracking-tight">AquaFlow</span>
            <span className="font-caption text-caption text-on-surface-variant leading-none">Dispatch &amp; Network</span>
          </div>
        </div>
        <div className="px-space-md py-space-sm">
          <span className="font-label-sm text-label-sm text-on-surface-variant/70 uppercase tracking-wider">Main Management</span>
        </div>
        <nav className="flex flex-col gap-space-xs px-space-sm">
          <NavLink
            to="/"
            end
            className={({ isActive }) =>
              isActive
                ? "flex items-center gap-space-sm px-space-md py-space-sm rounded-lg transition-all group bg-primary-fixed/40 text-on-primary-fixed-variant font-headline-sm border-l-4 border-primary shadow-sm"
                : "flex items-center gap-space-sm px-space-md py-space-sm rounded-lg text-on-surface-variant hover:bg-surface-container-low hover:text-on-surface transition-all group"
            }
          >
            <span className="material-symbols-outlined text-[20px] text-on-surface-variant group-hover:text-primary transition-colors">dashboard</span>
            <span className="font-label-md text-label-md">Dashboard</span>
          </NavLink>
          <NavLink
            to="/create-seller"
            className={({ isActive }) =>
              isActive
                ? "flex items-center gap-space-sm px-space-md py-space-sm rounded-lg transition-all group bg-primary-fixed/40 text-on-primary-fixed-variant font-headline-sm border-l-4 border-primary shadow-sm"
                : "flex items-center gap-space-sm px-space-md py-space-sm rounded-lg text-on-surface-variant hover:bg-surface-container-low hover:text-on-surface transition-all group"
            }
          >
            <span className="material-symbols-outlined text-[20px] text-on-surface-variant group-hover:text-primary transition-colors">person_add</span>
            <span className="font-label-md text-label-md">Create Seller</span>
          </NavLink>
        </nav>
      </div>
      <div className="p-space-md border-t border-outline-variant/20 bg-surface-container-lowest">
        <div className="flex items-center justify-between px-space-sm py-space-xs rounded-lg bg-surface-container-low">
          <div className="flex items-center gap-space-xs">
            <span className="w-2 h-2 rounded-full bg-secondary animate-pulse"></span>
            <span className="font-caption text-caption text-secondary font-semibold">Hub Active</span>
          </div>
          <span className="font-caption text-caption text-on-surface-variant">v2.4 LTS</span>
        </div>
      </div>
    </aside>
  );
}
