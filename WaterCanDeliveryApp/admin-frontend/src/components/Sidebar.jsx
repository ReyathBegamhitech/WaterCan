import { NavLink } from 'react-router-dom';

export default function Sidebar() {
  return (
    <aside className="fixed left-0 top-0 h-screen w-64 bg-surface-container-lowest border-r border-outline-variant/30 z-50 flex flex-col justify-between shadow-[0_1px_8px_rgba(0,0,0,0.02)]">
      <div className="flex flex-col">
        <div className="h-16 px-space-md flex items-center gap-space-sm border-b border-outline-variant/20">
          <div className="flex items-center justify-center h-10 w-10 rounded-xl bg-gradient-to-br from-primary to-[#005cbb] shadow-md border border-primary/20 flex-shrink-0">
            <span className="material-symbols-outlined text-[24px] text-white font-light">water_drop</span>
          </div>
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
          <NavLink
            to="/sellers"
            className={({ isActive }) =>
              isActive
                ? "flex items-center gap-space-sm px-space-md py-space-sm rounded-lg transition-all group bg-primary-fixed/40 text-on-primary-fixed-variant font-headline-sm border-l-4 border-primary shadow-sm"
                : "flex items-center gap-space-sm px-space-md py-space-sm rounded-lg text-on-surface-variant hover:bg-surface-container-low hover:text-on-surface transition-all group"
            }
          >
            <span className="material-symbols-outlined text-[20px] text-on-surface-variant group-hover:text-primary transition-colors">list_alt</span>
            <span className="font-label-md text-label-md">Sellers List</span>
          </NavLink>
        </nav>
      </div>

    </aside>
  );
}
