import { useState, useMemo } from 'react';
import { Link } from 'react-router-dom';

const INITIAL_SELLERS = [
  { cap: '380 Cans/day', hub: 'Indiranagar', joined: '12 Jan 2024', name: 'Sri Venkateshwara Water', phone: '+91 98451 23456', routes: 'Indiranagar, HAL 2nd Stage, Domlur', sellerId: 'S-0101', status: 'active', totalDelivered: '14,200', initials: 'SV' },
  { cap: '450 Cans/day', hub: 'Koramangala', joined: '18 Feb 2024', name: 'Ganga Pure Waters', phone: '+91 97312 88410', routes: 'Koramangala 4th-8th Block, Sony World', sellerId: 'S-0102', status: 'active', totalDelivered: '19,500', initials: 'GP' },
  { cap: '520 Cans/day', hub: 'Whitefield', joined: '05 Mar 2024', name: 'BlueDrop Logistics', phone: '+91 94481 77312', routes: 'ITPL, Hope Farm, Kadugodi', sellerId: 'S-0103', status: 'active', totalDelivered: '22,100', initials: 'BD' },
  { cap: '320 Cans/day', hub: 'Jayanagar', joined: '15 Mar 2024', name: 'Kavery Mineral Water', phone: '+91 99002 44319', routes: 'Jayanagar 3rd-9th Block, JP Nagar 1st', sellerId: 'S-0104', status: 'active', totalDelivered: '11,800', initials: 'KM' },
  { cap: '290 Cans/day', hub: 'HSR Layout', joined: '22 Mar 2024', name: 'AquaSpring Supply', phone: '+91 91103 55201', routes: 'HSR Sectors 1-7, Agara Lake Rim', sellerId: 'S-0105', status: 'active', totalDelivered: '8,900', initials: 'AS' },
  { cap: '410 Cans/day', hub: 'BTM Layout', joined: '02 Apr 2024', name: 'Himalayan Cans Co.', phone: '+91 96200 11984', routes: 'BTM 1st & 2nd Stage, Tavarekere', sellerId: 'S-0106', status: 'active', totalDelivered: '15,430', initials: 'HC' },
  { cap: '340 Cans/day', hub: 'Marathahalli', joined: '10 Apr 2024', name: 'Crystal Drop Hub', phone: '+91 98864 77210', routes: 'Outer Ring Road, Spice Garden', sellerId: 'S-0107', status: 'active', totalDelivered: '9,740', initials: 'CD' },
  { cap: '310 Cans/day', hub: 'Hebbal', joined: '20 Apr 2024', name: 'Nandi Aqua Traders', phone: '+91 97401 22934', routes: 'Hebbal Kempapura, Manyata Tech Park', sellerId: 'S-0108', status: 'active', totalDelivered: '7,600', initials: 'NA' },
  { cap: '480 Cans/day', hub: 'Electronic City', joined: '28 Apr 2024', name: 'Oasis Can Express', phone: '+91 99160 88219', routes: 'Phase 1, Neeladri Road, Velankani', sellerId: 'S-0109', status: 'active', totalDelivered: '13,400', initials: 'OE' },
  { cap: '260 Cans/day', hub: 'Malleswaram', joined: '05 May 2024', name: 'Purity Hub', phone: '+91 98801 33451', routes: 'Malleswaram, Yeshwanthpur', sellerId: 'S-0110', status: 'active', totalDelivered: '5,200', initials: 'PH' },
  { cap: '150 Cans/day', hub: 'Rajajinagar', joined: '12 May 2024', name: 'Cascade Mineral Depot', phone: '+91 97410 44521', routes: 'Rajajinagar 1st Block, Navrang', sellerId: 'S-0111', status: 'inactive', totalDelivered: '1,200', initials: 'CM' },
  { cap: '180 Cans/day', hub: 'Yelahanka', joined: '18 May 2024', name: 'Vayu Hydro Services', phone: '+91 99805 12093', routes: 'Yelahanka New Town, Attur', sellerId: 'S-0112', status: 'inactive', totalDelivered: '850', initials: 'VH' },
];

export default function Dashboard() {
  const [sellers, setSellers] = useState(INITIAL_SELLERS);
  const [searchQuery, setSearchQuery] = useState('');
  const [filter, setFilter] = useState('all');
  const [isForcedEmpty, setIsForcedEmpty] = useState(false);
  const [selectedSeller, setSelectedSeller] = useState(null);

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

      <div className="grid grid-cols-2 md:grid-cols-4 gap-space-sm">
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
            <span className="font-caption text-caption text-on-surface-variant uppercase tracking-wider font-semibold">Pending Approval</span>
            <span className="font-headline-lg text-headline-lg text-tertiary mt-0.5">2</span>
            <span className="font-caption text-caption text-on-surface-variant mt-0.5">KYC validation stage</span>
          </div>
          <div className="w-11 h-11 rounded-xl bg-tertiary-fixed/50 flex items-center justify-center text-tertiary">
            <span className="material-symbols-outlined text-[24px]">pending_actions</span>
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

      <div className="flex flex-col gap-space-md bg-surface-container-lowest p-space-md lg:p-space-lg rounded-xl border border-outline-variant/30 shadow-sm">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-space-sm pb-space-sm border-b border-outline-variant/20">
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
                className={`seller-card group relative bg-surface-container-lowest hover:bg-surface-container-lowest/90 rounded-xl border border-outline-variant/40 ${seller.status === 'active' ? 'hover:border-primary/50' : 'hover:border-tertiary/50'} transition-all duration-200 p-space-md flex flex-col justify-between aspect-square cursor-pointer shadow-xs hover:shadow-md`}
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
