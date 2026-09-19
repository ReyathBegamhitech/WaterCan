import { useState, useMemo, useEffect } from 'react';
import { Link } from 'react-router-dom';

export default function Dashboard() {
  const [sellers, setSellers] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [filter, setFilter] = useState('all');
  const [isForcedEmpty, setIsForcedEmpty] = useState(false);
  const [selectedSeller, setSelectedSeller] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetch('http://localhost:3000/api/auth/admin/sellers')
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          const formatted = data.sellers.map(s => {
            const date = new Date(s.created_at);
            const joined = date.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
            return {
              name: s.organization_name,
              phone: s.phone_number,
              sellerId: s.seller_id,
              status: 'active', // Assuming all newly created are active
              cap: '0 Cans/day', // Mock default
              hub: s.location || 'Unknown',
              joined: joined,
              routes: s.location || 'Pending assignment',
              totalDelivered: '0', // Mock default
              initials: s.organization_name.substring(0, 2).toUpperCase()
            };
          });
          setSellers(formatted);
        }
      })
      .catch(err => console.error("Failed to fetch sellers:", err))
      .finally(() => setIsLoading(false));
  }, []);

  const filteredSellers = useMemo(() => {
    if (isForcedEmpty) return [];
    return sellers.filter(seller => {
      const matchesSearch = !searchQuery || 
        seller.name.toLowerCase().includes(searchQuery.toLowerCase()) || 
        seller.sellerId.toLowerCase().includes(searchQuery.toLowerCase()) || 
        seller.phone.toLowerCase().includes(searchQuery.toLowerCase());
      
      const matchesFilter = filter === 'all' || seller.status === filter;

      return matchesSearch && matchesFilter;
    });
  }, [sellers, searchQuery, filter, isForcedEmpty]);

  const toggleSellerStatus = (id) => {
    setSellers(sellers.map(s => {
      if (s.sellerId === id) {
        const newStatus = s.status === 'active' ? 'inactive' : 'active';
        if (selectedSeller?.sellerId === id) {
          setSelectedSeller({ ...s, status: newStatus });
        }
        return { ...s, status: newStatus };
      }
      return s;
    }));
  };

  return (
    <div className="flex flex-col w-full gap-space-lg">
      <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-space-md">
        <div className="flex flex-col gap-space-xs">
          <div className="flex items-center gap-space-sm">
            <h1 className="font-headline-lg text-headline-lg text-on-surface">Dashboard</h1>
            <span className="px-space-sm py-0.5 rounded-full bg-secondary-fixed/40 text-on-secondary-fixed-variant font-label-sm text-label-sm font-semibold flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-secondary"></span> Live Fleet
            </span>
          </div>
          <p className="font-body-md text-body-md text-on-surface-variant">
            Manage water delivery sellers, distribution coverage, and active vendor accounts.
          </p>
        </div>
        <div className="flex items-center flex-wrap sm:flex-nowrap gap-space-sm">
          <div className="relative w-full sm:w-80">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[18px] text-tertiary">search</span>
            <input
              className="w-full pl-9 pr-3 py-2 bg-surface-container-lowest rounded-xl border border-outline-variant/40 text-on-surface font-body-md text-body-md placeholder-tertiary focus:outline-none focus:ring-2 focus:ring-primary/40 transition-all shadow-sm"
              placeholder="Search seller by name, ID or mobile..."
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
          <Link to="/create-seller" className="inline-flex items-center justify-center gap-space-xs px-space-md py-2 bg-primary text-on-primary font-label-md text-label-md rounded-xl hover:bg-primary-container active:bg-primary transition-all shadow-sm shrink-0">
            <span className="material-symbols-outlined text-[18px]">person_add</span>
            <span>+ Create Seller</span>
          </Link>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-space-sm">
        <div className="p-space-md rounded-xl bg-surface-container-lowest border border-outline-variant/30 flex items-center justify-between shadow-sm">
          <div className="flex flex-col">
            <span className="font-caption text-caption text-on-surface-variant uppercase tracking-wider font-semibold">Total Sellers</span>
            <span className="font-headline-lg text-headline-lg text-on-surface mt-0.5">{sellers.length}</span>
            <span className="font-caption text-caption text-secondary flex items-center gap-0.5 mt-0.5">
              <span className="material-symbols-outlined text-[14px]">arrow_upward</span> +3 this month
            </span>
          </div>
          <div className="w-11 h-11 rounded-xl bg-primary-fixed/40 flex items-center justify-center text-primary">
            <span className="material-symbols-outlined text-[24px]">local_shipping</span>
          </div>
        </div>
        <div className="p-space-md rounded-xl bg-surface-container-lowest border border-outline-variant/30 flex items-center justify-between shadow-sm">
          <div className="flex flex-col">
            <span className="font-caption text-caption text-on-surface-variant uppercase tracking-wider font-semibold">Active Now</span>
            <span className="font-headline-lg text-headline-lg text-secondary mt-0.5">{sellers.filter(s => s.status === 'active').length}</span>
            <span className="font-caption text-caption text-on-surface-variant mt-0.5">91.6% operational</span>
          </div>
          <div className="w-11 h-11 rounded-xl bg-secondary-fixed/40 flex items-center justify-center text-secondary">
            <span className="material-symbols-outlined text-[24px]">verified</span>
          </div>
        </div>
        <div className="p-space-md rounded-xl bg-surface-container-lowest border border-outline-variant/30 flex items-center justify-between shadow-sm">
          <div className="flex flex-col">
            <span className="font-caption text-caption text-on-surface-variant uppercase tracking-wider font-semibold">Daily Delivered Cans</span>
            <span className="font-headline-lg text-headline-lg text-primary mt-0.5">1,840</span>
            <span className="font-caption text-caption text-on-surface-variant mt-0.5">20L Standard Jars</span>
          </div>
          <div className="w-11 h-11 rounded-xl bg-primary-fixed/40 flex items-center justify-center text-primary">
            <span className="material-symbols-outlined text-[24px]" style={{ fontVariationSettings: '"FILL" 1' }}>water_drop</span>
          </div>
        </div>
      </div>

      <div className="flex flex-col gap-space-md">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-space-sm pb-space-sm">
          <div className="flex items-center gap-space-sm">
            <h2 className="font-headline-sm text-headline-sm text-on-surface">Registered Sellers</h2>
            <span className="px-2.5 py-0.5 rounded-full bg-surface-container-high text-on-surface-variant font-caption text-caption font-semibold">
              {filteredSellers.length} Sellers
            </span>
          </div>
          <div className="flex items-center gap-space-sm self-start sm:self-auto">
            <div className="flex items-center bg-surface-container-low p-1 rounded-xl">
              <button
                className={`px-3 py-1 rounded-lg font-label-sm text-label-sm transition-all ${filter === 'all' ? 'bg-surface-container-lowest text-primary shadow-xs font-semibold' : 'text-on-surface-variant hover:text-on-surface'}`}
                onClick={() => setFilter('all')}
              >
                All ({sellers.length})
              </button>
              <button
                className={`px-3 py-1 rounded-lg font-label-sm text-label-sm transition-all ${filter === 'active' ? 'bg-surface-container-lowest text-primary shadow-xs font-semibold' : 'text-on-surface-variant hover:text-on-surface'}`}
                onClick={() => setFilter('active')}
              >
                Active ({sellers.filter(s => s.status === 'active').length})
              </button>
              <button
                className={`px-3 py-1 rounded-lg font-label-sm text-label-sm transition-all ${filter === 'inactive' ? 'bg-surface-container-lowest text-primary shadow-xs font-semibold' : 'text-on-surface-variant hover:text-on-surface'}`}
                onClick={() => setFilter('inactive')}
              >
                Inactive ({sellers.filter(s => s.status === 'inactive').length})
              </button>
            </div>
            <button
              className="flex items-center gap-1 px-3 py-1.5 rounded-xl border border-outline-variant/40 hover:bg-surface-container-low text-on-surface-variant font-caption text-caption font-semibold transition-colors"
              onClick={() => setIsForcedEmpty(!isForcedEmpty)}
              title="Toggle Empty State preview"
            >
              <span className="material-symbols-outlined text-[16px]">visibility</span>
              <span>{isForcedEmpty ? 'Show Sellers' : 'Preview Empty'}</span>
            </button>
          </div>
        </div>

        {filteredSellers.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 2xl:grid-cols-6 gap-5">
            {filteredSellers.map(seller => (
              <div 
                key={seller.sellerId} 
                onClick={() => setSelectedSeller(seller)}
                className={`seller-card group relative bg-surface-container-lowest rounded-xl border border-outline-variant/40 transition-all duration-300 p-space-md flex flex-col justify-between aspect-square cursor-pointer shadow-sm ${seller.status === 'active' ? 'hover:border-primary/50 hover:shadow-[0_0_20px_rgba(0,97,148,0.15)] hover:ring-1 hover:ring-primary/20' : 'hover:border-tertiary/50 hover:shadow-[0_0_20px_rgba(84,92,114,0.15)] hover:ring-1 hover:ring-tertiary/20'}`}
              >
                <div className="flex flex-col">
                  <div className="flex items-start justify-between">
                    <div className="relative">
                      <div className={`w-10 h-10 rounded-xl ${seller.status === 'active' ? 'bg-primary/10 text-primary' : 'bg-surface-container text-tertiary'} flex items-center justify-center font-headline-sm text-headline-sm font-bold`}>
                        {seller.initials}
                      </div>
                      <span className={`material-symbols-outlined text-[13px] absolute -bottom-1 -right-1 ${seller.status === 'active' ? 'text-primary bg-surface-container-lowest shadow-xs' : 'text-tertiary bg-surface-container-lowest shadow-xs'} rounded-full p-0.5`} style={seller.status === 'active' ? {fontVariationSettings: '"FILL" 1'} : {}}>
                        water_drop
                      </span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <span className={`flex items-center gap-1 px-2 py-0.5 rounded-full ${seller.status === 'active' ? 'bg-secondary-fixed/40 text-on-secondary-fixed-variant' : 'bg-surface-container-high text-on-surface-variant'} font-caption text-caption font-semibold`}>
                        <span className={`w-1.5 h-1.5 rounded-full ${seller.status === 'active' ? 'bg-secondary' : 'bg-outline'}`}></span> {seller.status === 'active' ? 'Active' : 'Inactive'}
                      </span>
                      <span className={`material-symbols-outlined text-[18px] text-tertiary ${seller.status === 'active' ? 'group-hover:text-primary group-hover:translate-x-0.5' : 'group-hover:text-on-surface group-hover:translate-x-0.5'} transition-all`}>chevron_right</span>
                    </div>
                  </div>
                  <div className="mt-3">
                    <h3 className={`font-headline-sm text-headline-sm text-on-surface truncate ${seller.status === 'active' ? 'group-hover:text-primary transition-colors' : ''}`}>
                      {seller.name}
                    </h3>
                    <span className="inline-block mt-0.5 font-caption text-caption bg-surface-container text-on-surface-variant font-mono px-1.5 py-0.5 rounded">ID: {seller.sellerId}</span>
                  </div>
                  <div className="mt-2.5 flex items-center gap-1 text-on-surface-variant font-body-md text-body-md">
                    <span className="material-symbols-outlined text-[16px] text-tertiary">call</span>
                    <span className="truncate">{seller.phone}</span>
                  </div>
                </div>
                <div className="pt-2 border-t border-outline-variant/20 flex items-center justify-between font-caption text-caption text-on-surface-variant">
                  <span className="truncate max-w-[55%]">{seller.hub}</span>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center py-16 px-4 text-center">
            <div className="w-20 h-20 rounded-2xl bg-surface-container-low flex items-center justify-center text-tertiary mb-space-md border border-outline-variant/30">
              <span className="material-symbols-outlined text-[42px] text-primary" style={{ fontVariationSettings: '"FILL" 1' }}>water_drop</span>
            </div>
            <h3 className="font-headline-md text-headline-md text-on-surface">No sellers registered yet</h3>
            <p className="font-body-md text-body-md text-on-surface-variant max-w-md mt-1.5 mb-space-lg">
              Get started by adding your first regional water delivery partner to the network to begin tracking fleets, stock reserves, and route dispatching.
            </p>
            <Link to="/create-seller" className="inline-flex items-center gap-space-xs px-space-lg py-2.5 bg-primary text-on-primary font-label-md text-label-md rounded-xl hover:bg-primary-container active:bg-primary transition-all shadow-sm">
              <span className="material-symbols-outlined text-[20px]">person_add</span>
              <span>Create Seller</span>
            </Link>
          </div>
        )}
      </div>

      <div className={`fixed inset-0 bg-inverse-surface/40 backdrop-blur-xs z-50 transition-opacity duration-300 ${selectedSeller ? 'opacity-100' : 'opacity-0 pointer-events-none'}`} onClick={() => setSelectedSeller(null)}></div>
      
      <aside className={`fixed top-0 right-0 h-screen w-full sm:w-[420px] bg-surface-container-lowest z-50 transform transition-transform duration-300 ease-in-out flex flex-col justify-between shadow-2xl border-l border-outline-variant/30 ${selectedSeller ? 'translate-x-0' : 'translate-x-full'}`}>
        {selectedSeller && (
          <>
            <div className="p-space-lg border-b border-outline-variant/20 flex items-center justify-between bg-surface-container-low">
              <div className="flex items-center gap-space-sm">
                <div className="w-11 h-11 rounded-xl bg-primary text-on-primary flex items-center justify-center font-headline-sm text-headline-sm font-bold">
                  {selectedSeller.initials}
                </div>
                <div className="flex flex-col">
                  <h3 className="font-headline-sm text-headline-sm text-on-surface leading-tight">{selectedSeller.name}</h3>
                  <span className="font-caption text-caption text-on-surface-variant font-mono">ID: {selectedSeller.sellerId}</span>
                </div>
              </div>
              <button
                className="w-8 h-8 rounded-lg hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant transition-colors"
                onClick={() => setSelectedSeller(null)}
              >
                <span className="material-symbols-outlined text-[20px]">close</span>
              </button>
            </div>
            
            <div className="p-space-lg flex-1 overflow-y-auto flex flex-col gap-space-lg">
              <div className="grid grid-cols-2 gap-space-sm">
                <div className="p-space-md rounded-xl bg-surface-container-low border border-outline-variant/30 flex flex-col">
                  <span className="font-caption text-caption text-on-surface-variant">Account Status</span>
                  <div className="mt-1 flex items-center gap-1.5">
                    <span className={`w-2 h-2 rounded-full ${selectedSeller.status === 'active' ? 'bg-secondary' : 'bg-outline'}`}></span>
                    <span className="font-label-md text-label-md font-semibold text-on-surface">{selectedSeller.status === 'active' ? 'Active' : 'Inactive'}</span>
                  </div>
                </div>
                <div className="p-space-md rounded-xl bg-surface-container-low border border-outline-variant/30 flex flex-col">
                  <span className="font-caption text-caption text-on-surface-variant">Total Jars Delivered</span>
                  <span className="font-headline-sm text-headline-sm font-bold text-primary mt-1">{selectedSeller.totalDelivered}</span>
                </div>
              </div>

              <div className="flex flex-col gap-space-md">
                <span className="font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant font-bold">Operational Info</span>
                <div className="flex flex-col gap-space-sm divide-y divide-outline-variant/20">
                  <div className="pt-2 first:pt-0 flex items-center justify-between">
                    <span className="font-body-md text-body-md text-on-surface-variant flex items-center gap-2">
                      <span className="material-symbols-outlined text-[18px] text-tertiary">call</span> Phone Contact
                    </span>
                    <span className="font-label-md text-label-md text-on-surface font-mono">{selectedSeller.phone}</span>
                  </div>
                  <div className="pt-2 flex items-center justify-between">
                    <span className="font-body-md text-body-md text-on-surface-variant flex items-center gap-2">
                      <span className="material-symbols-outlined text-[18px] text-tertiary">chat</span> WhatsApp Alert
                    </span>
                    <span className="font-caption text-caption text-secondary font-semibold bg-secondary-fixed/30 px-2 py-0.5 rounded-full">Connected</span>
                  </div>
                  <div className="pt-2 flex items-center justify-between">
                    <span className="font-body-md text-body-md text-on-surface-variant flex items-center gap-2">
                      <span className="material-symbols-outlined text-[18px] text-tertiary">warehouse</span> Distribution Hub
                    </span>
                    <span className="font-label-md text-label-md text-on-surface">{selectedSeller.hub}</span>
                  </div>
                  <div className="pt-2 flex items-center justify-between">
                    <span className="font-body-md text-body-md text-on-surface-variant flex items-center gap-2">
                      <span className="material-symbols-outlined text-[18px] text-tertiary">speed</span> Daily Quota
                    </span>
                    <span className="font-label-md text-label-md text-primary font-semibold">{selectedSeller.cap}</span>
                  </div>
                  <div className="pt-2 flex items-center justify-between">
                    <span className="font-body-md text-body-md text-on-surface-variant flex items-center gap-2">
                      <span className="material-symbols-outlined text-[18px] text-tertiary">calendar_today</span> Registered Since
                    </span>
                    <span className="font-label-md text-label-md text-on-surface">{selectedSeller.joined}</span>
                  </div>
                </div>
              </div>

              <div className="flex flex-col gap-space-xs">
                <span className="font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant font-bold">Assigned Dispatch Corridors</span>
                <div className="p-space-md bg-surface-container-low rounded-xl border border-outline-variant/30 flex items-start gap-2 text-on-surface-variant">
                  <span className="material-symbols-outlined text-[20px] text-primary shrink-0 mt-0.5">alt_route</span>
                  <p className="font-body-md text-body-md leading-relaxed text-on-surface">{selectedSeller.routes}</p>
                </div>
              </div>

              <div className="p-space-md rounded-xl bg-surface-container-low/50 border border-outline-variant/20 flex items-center gap-3">
                <span className="material-symbols-outlined text-[24px] text-secondary">verified_user</span>
                <div className="flex flex-col">
                  <span className="font-label-sm text-label-sm text-on-surface font-semibold">FSSAI &amp; Water Quality Certified</span>
                  <span className="font-caption text-caption text-on-surface-variant">Batch testing logs synchronized daily</span>
                </div>
              </div>
            </div>

            <div className="p-space-lg border-t border-outline-variant/20 bg-surface-container-low flex items-center gap-space-sm">
              <button
                className="flex-1 py-2.5 px-4 rounded-xl border border-outline-variant/50 hover:bg-surface-container text-on-surface font-label-md text-label-md transition-colors"
                onClick={() => toggleSellerStatus(selectedSeller.sellerId)}
              >
                {selectedSeller.status === 'active' ? 'Deactivate Seller' : 'Activate Seller'}
              </button>
              <Link to="/create-seller" className="flex-1 py-2.5 px-4 rounded-xl bg-primary text-on-primary font-label-md text-label-md text-center hover:bg-primary-container transition-colors shadow-sm">
                Edit Vendor
              </Link>
            </div>
          </>
        )}
      </aside>
    </div>
  );
}
