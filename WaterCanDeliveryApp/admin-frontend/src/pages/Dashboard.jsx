import { useState, useMemo, useEffect } from 'react';
import { Link } from 'react-router-dom';
import CountUp from '../components/CountUp';

export default function Dashboard() {
  const [sellers, setSellers] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [filter, setFilter] = useState('all');
  const [isForcedEmpty, setIsForcedEmpty] = useState(false);
  const [selectedSeller, setSelectedSeller] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  // Income by Date State
  const [incomeDate, setIncomeDate] = useState(new Date().toISOString().split('T')[0]);
  const [codIncome, setCodIncome] = useState(0);
  const [upiIncome, setUpiIncome] = useState(0);
  const [isIncomeLoading, setIsIncomeLoading] = useState(false);

  // Customer Details Modal State
  const [isCustomerModalOpen, setIsCustomerModalOpen] = useState(false);
  const [customerList, setCustomerList] = useState([]);
  const [isCustomersLoading, setIsCustomersLoading] = useState(false);

  const fetchCustomers = (sellerId) => {
    setIsCustomerModalOpen(true);
    setIsCustomersLoading(true);
    fetch(`${import.meta.env.VITE_API_URL}/auth/admin/sellers/${sellerId}/customers`)
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          setCustomerList(data.customers);
        }
      })
      .catch(err => console.error("Failed to fetch customers:", err))
      .finally(() => setIsCustomersLoading(false));
  };

  // Fetch Income Data
  useEffect(() => {
    if (!selectedSeller) return;
    setIsIncomeLoading(true);
    fetch(`${import.meta.env.VITE_API_URL}/auth/admin/sellers/${selectedSeller.sellerId}/income?date=${incomeDate}`)
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          setCodIncome(data.codIncome);
          setUpiIncome(data.upiIncome);
        }
      })
      .catch(err => console.error("Failed to fetch seller income:", err))
      .finally(() => setIsIncomeLoading(false));
  }, [selectedSeller, incomeDate]);

  useEffect(() => {
    fetch(`${import.meta.env.VITE_API_URL}/auth/admin/sellers`)
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
              overallOrders: s.overall_orders || '0',
              ordersInProcess: s.orders_in_process || '0',
              monthlyOrders: s.monthly_orders || '0',
              deliveredToday: s.delivered_today || '0',
              cancelledOrders: s.cancelled_orders || '0',
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
          <div className="flex items-center gap-3 pb-1">
            <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-primary to-[#005cbb] text-white flex items-center justify-center shadow-md">
              <span className="material-symbols-outlined text-[26px]">space_dashboard</span>
            </div>
            <h1 className="text-3xl font-extrabold tracking-tight text-on-surface">Dashboard</h1>
            <span className="ml-2 px-3 py-1 rounded-full bg-secondary-fixed/40 text-on-secondary-fixed-variant font-label-sm text-label-sm font-semibold flex items-center gap-1.5 shadow-sm">
              <span className="w-2 h-2 rounded-full bg-secondary animate-pulse"></span> Live Fleet
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

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-space-sm">
        <div className="p-space-lg rounded-2xl bg-blue-50 border border-blue-100 flex flex-col relative overflow-hidden shadow-sm">
          <span className="font-caption text-caption text-blue-600 uppercase tracking-wider font-bold z-10">Total Sellers</span>
          <span className="font-headline-lg text-headline-lg text-blue-950 mt-1 z-10">{sellers.length}</span>
          <span className="font-label-sm text-label-sm text-blue-700 flex items-center gap-1 mt-1 z-10">
            <span className="material-symbols-outlined text-[16px]">trending_up</span> +3 this month
          </span>
          <span className="material-symbols-outlined absolute -bottom-4 -right-4 text-[80px] text-blue-500/10 z-0 select-none pointer-events-none">storefront</span>
        </div>

        <div className="p-space-lg rounded-2xl bg-emerald-50 border border-emerald-100 flex flex-col relative overflow-hidden shadow-sm">
          <span className="font-caption text-caption text-emerald-600 uppercase tracking-wider font-bold z-10">Active Now</span>
          <span className="font-headline-lg text-headline-lg text-emerald-950 mt-1 z-10">{sellers.filter(s => s.status === 'active').length}</span>
          <span className="font-label-sm text-label-sm text-emerald-700 mt-1 z-10">
            {sellers.length > 0 ? Math.round((sellers.filter(s => s.status === 'active').length / sellers.length) * 100) : 0}% operational
          </span>
          <span className="material-symbols-outlined absolute -bottom-4 -right-4 text-[80px] text-emerald-500/10 z-0 select-none pointer-events-none">verified</span>
        </div>

        <div className="p-space-lg rounded-2xl bg-amber-50 border border-amber-100 flex flex-col relative overflow-hidden shadow-sm">
          <span className="font-caption text-caption text-amber-700 uppercase tracking-wider font-bold z-10">Orders in Progress</span>
          <span className="font-headline-lg text-headline-lg text-amber-950 mt-1 z-10">
            {sellers.reduce((sum, s) => sum + parseInt(s.ordersInProcess || 0), 0)}
          </span>
          <span className="font-label-sm text-label-sm text-amber-700 mt-1 z-10">Across all active sellers</span>
          <span className="material-symbols-outlined absolute -bottom-4 -right-4 text-[80px] text-amber-500/10 z-0 select-none pointer-events-none">local_shipping</span>
        </div>

        <div className="p-space-lg rounded-2xl bg-purple-50 border border-purple-100 flex flex-col relative overflow-hidden shadow-sm">
          <span className="font-caption text-caption text-purple-600 uppercase tracking-wider font-bold z-10">Delivered Today</span>
          <span className="font-headline-lg text-headline-lg text-purple-950 mt-1 z-10">
            {sellers.reduce((sum, s) => sum + parseInt(s.deliveredToday || 0), 0)}
          </span>
          <span className="font-label-sm text-label-sm text-purple-700 mt-1 z-10">Successfully completed</span>
          <span className="material-symbols-outlined absolute -bottom-4 -right-4 text-[80px] text-purple-500/10 z-0 select-none pointer-events-none">task_alt</span>
        </div>
      </div>

      <div className="flex flex-col gap-space-md">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-space-sm pb-space-sm">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined text-primary text-[28px]">storefront</span>
              <h2 className="text-2xl font-bold tracking-tight text-on-surface">Registered Sellers</h2>
            </div>
            <span className="px-3 py-1 rounded-full bg-surface-container-high text-on-surface-variant font-caption text-caption font-semibold shadow-sm border border-outline-variant/30">
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
        <hr className="border-t-2 border-outline-variant/70 shadow-sm w-full mb-space-md -mt-2" />

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
                <div className="p-space-md rounded-xl bg-blue-50 border border-blue-100 flex flex-col relative overflow-hidden shadow-sm">
                  <span className="font-caption text-caption text-blue-600 font-semibold z-10">Overall Orders</span>
                  <span className="font-headline-sm text-headline-sm font-bold text-blue-900 mt-1 z-10"><CountUp value={selectedSeller.overallOrders} /></span>
                  <span className="material-symbols-outlined absolute -bottom-2 -right-2 text-[64px] text-blue-500/10 z-0 select-none pointer-events-none">shopping_cart</span>
                </div>
                
                <div className="p-space-md rounded-xl bg-amber-50 border border-amber-100 flex flex-col relative overflow-hidden shadow-sm">
                  <span className="font-caption text-caption text-amber-700 font-semibold z-10">Orders in Process</span>
                  <span className="font-headline-sm text-headline-sm font-bold text-amber-900 mt-1 z-10"><CountUp value={selectedSeller.ordersInProcess} /></span>
                  <span className="material-symbols-outlined absolute -bottom-2 -right-2 text-[64px] text-amber-500/10 z-0 select-none pointer-events-none">local_shipping</span>
                </div>
                
                <div className="p-space-md rounded-xl bg-emerald-50 border border-emerald-100 flex flex-col relative overflow-hidden shadow-sm">
                  <span className="font-caption text-caption text-emerald-700 font-semibold z-10">Monthly Orders</span>
                  <span className="font-headline-sm text-headline-sm font-bold text-emerald-900 mt-1 z-10"><CountUp value={selectedSeller.monthlyOrders} /></span>
                  <span className="material-symbols-outlined absolute -bottom-2 -right-2 text-[64px] text-emerald-500/10 z-0 select-none pointer-events-none">calendar_month</span>
                </div>

                <div className="p-space-md rounded-xl bg-rose-50 border border-rose-100 flex flex-col relative overflow-hidden shadow-sm">
                  <span className="font-caption text-caption text-rose-700 font-semibold z-10">Cancelled Orders</span>
                  <span className="font-headline-sm text-headline-sm font-bold text-rose-900 mt-1 z-10"><CountUp value={selectedSeller.cancelledOrders} /></span>
                  <span className="material-symbols-outlined absolute -bottom-2 -right-2 text-[64px] text-rose-500/10 z-0 select-none pointer-events-none">cancel</span>
                </div>
              </div>

              <div className="flex flex-col gap-space-sm">
                <div className="flex items-center justify-between">
                  <span className="font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant font-bold">Income by Date</span>
                  <span className="font-caption text-caption text-[#e87a3f] font-bold bg-[#fed7aa]/30 px-2 py-0.5 rounded-full shrink-0">Track Revenue</span>
                </div>
                
                <div className="w-full relative">
                  <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[18px] text-[#e87a3f]">calendar_today</span>
                  <input 
                    type="date"
                    value={incomeDate}
                    onChange={(e) => setIncomeDate(e.target.value)}
                    className="w-full pl-9 pr-3 py-2.5 bg-surface-container-lowest rounded-xl border border-[#fed7aa] text-on-surface font-label-md text-label-md focus:outline-none focus:border-[#f97316] transition-colors shadow-sm"
                  />
                </div>

                <div className="grid grid-cols-2 gap-space-sm">
                  <div className="p-space-md rounded-xl bg-[#fff7ed] border border-[#ffedd5] flex flex-col justify-between relative overflow-hidden shadow-sm h-[90px]">
                    <div className="flex items-center justify-between z-10 w-full">
                      <div className="w-7 h-7 rounded-lg bg-[#fdba74] flex items-center justify-center text-[#9a3412]">
                        <span className="material-symbols-outlined text-[16px]">payments</span>
                      </div>
                      <span className="font-caption text-[10px] text-[#9a3412] font-bold bg-[#ffedd5] px-1.5 py-0.5 rounded">COD</span>
                    </div>
                    <span className="font-headline-md text-headline-md font-bold text-on-surface z-10 flex items-center gap-0.5 tracking-tight">
                      <span className="material-symbols-outlined text-[20px] font-bold">currency_rupee</span>
                      {isIncomeLoading ? '...' : <CountUp value={codIncome} />}
                    </span>
                  </div>

                  <div className="p-space-md rounded-xl bg-[#eff6ff] border border-[#dbeafe] flex flex-col justify-between relative overflow-hidden shadow-sm h-[90px]">
                    <div className="flex items-center justify-between z-10 w-full">
                      <div className="w-7 h-7 rounded-lg bg-[#93c5fd] flex items-center justify-center text-[#1e40af]">
                        <span className="material-symbols-outlined text-[16px]">qr_code_2</span>
                      </div>
                      <span className="font-caption text-[10px] text-[#1e40af] font-bold bg-[#dbeafe] px-1.5 py-0.5 rounded">UPI</span>
                    </div>
                    <span className="font-headline-md text-headline-md font-bold text-on-surface z-10 flex items-center gap-0.5 tracking-tight">
                      <span className="material-symbols-outlined text-[20px] font-bold">currency_rupee</span>
                      {isIncomeLoading ? '...' : <CountUp value={upiIncome} />}
                    </span>
                  </div>
                </div>
              </div>

              <div className="flex flex-col gap-space-md">
                <span className="font-label-sm text-label-sm uppercase tracking-wider text-on-surface-variant font-bold">Operational Info</span>
                <div className="flex flex-col gap-space-sm divide-y divide-outline-variant/20">
                  <div className="pt-2 first:pt-0 flex items-start justify-between gap-4">
                    <span className="font-body-md text-body-md text-on-surface-variant flex items-start gap-2 shrink-0">
                      <span className="material-symbols-outlined text-[18px] text-tertiary mt-0.5">call</span> Phone Contact
                    </span>
                    <span className="font-label-md text-label-md text-on-surface font-mono text-right break-words">{selectedSeller.phone}</span>
                  </div>

                  <div className="pt-3 flex items-start justify-between gap-4">
                    <span className="font-body-md text-body-md text-on-surface-variant flex items-start gap-2 shrink-0">
                      <span className="material-symbols-outlined text-[18px] text-tertiary mt-0.5">warehouse</span> Distribution Hub
                    </span>
                    <span className="font-label-md text-label-md text-on-surface text-right break-words">{selectedSeller.hub}</span>
                  </div>

                  <div className="pt-3 flex items-start justify-between gap-4">
                    <span className="font-body-md text-body-md text-on-surface-variant flex items-start gap-2 shrink-0">
                      <span className="material-symbols-outlined text-[18px] text-tertiary mt-0.5">calendar_today</span> Registered Since
                    </span>
                    <span className="font-label-md text-label-md text-on-surface text-right shrink-0">{selectedSeller.joined}</span>
                  </div>
                </div>
              </div>




            </div>

            <div className="p-space-lg border-t border-outline-variant/20 bg-surface-container-low flex flex-col gap-space-sm">
              <div className="flex items-center gap-space-sm">
                <button
                  className="flex-1 py-2.5 px-4 rounded-xl border border-outline-variant/50 hover:bg-surface-container text-on-surface font-label-md text-label-md transition-colors"
                  onClick={() => toggleSellerStatus(selectedSeller.sellerId)}
                >
                  {selectedSeller.status === 'active' ? 'Deactivate Seller' : 'Activate Seller'}
                </button>
                <Link 
                  to="/sellers"
                  state={{ search: selectedSeller.sellerId, openEdit: true }}
                  className="flex-1 py-2.5 px-4 rounded-xl bg-primary text-on-primary font-label-md text-label-md text-center hover:bg-primary-container transition-colors shadow-sm"
                >
                  Edit Vendor
                </Link>
              </div>
              <button
                className="w-full py-2.5 px-4 rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white font-label-md text-label-md transition-colors shadow-sm flex items-center justify-center gap-2 font-bold"
                onClick={() => fetchCustomers(selectedSeller.sellerId)}
              >
                <span className="material-symbols-outlined text-[18px]">group</span>
                Show Customer Details
              </button>
            </div>
          </>
        )}
      </aside>

      {/* CUSTOMER DETAILS MODAL */}
      {isCustomerModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 backdrop-blur-md bg-black/40">
          <div className="bg-surface rounded-2xl shadow-xl w-full max-w-4xl max-h-[85vh] flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
            <div className="p-space-lg border-b border-outline-variant/20 flex items-center justify-between bg-surface-container-low shrink-0">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-secondary-fixed/30 text-secondary flex items-center justify-center">
                  <span className="material-symbols-outlined text-[20px]">group</span>
                </div>
                <div>
                  <h3 className="font-headline-sm text-headline-sm text-on-surface">Customer Details</h3>
                  <p className="font-caption text-caption text-on-surface-variant">Customers for {selectedSeller?.name}</p>
                </div>
              </div>
              <button
                className="w-8 h-8 rounded-lg hover:bg-surface-container-high flex items-center justify-center text-on-surface-variant transition-colors"
                onClick={() => setIsCustomerModalOpen(false)}
              >
                <span className="material-symbols-outlined text-[20px]">close</span>
              </button>
            </div>
            
            <div className="flex-1 overflow-y-auto p-space-lg bg-surface">
              {isCustomersLoading ? (
                <div className="flex items-center justify-center h-40">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
                </div>
              ) : customerList.length === 0 ? (
                <div className="flex flex-col items-center justify-center h-40 text-on-surface-variant">
                  <span className="material-symbols-outlined text-[48px] mb-2 opacity-50">person_off</span>
                  <p>No customers found for this seller yet.</p>
                </div>
              ) : (
                <div className="w-full border border-outline-variant/30 rounded-xl overflow-hidden">
                  <table className="w-full text-left border-collapse">
                    <thead className="bg-surface-container-lowest">
                      <tr>
                        <th className="p-4 font-label-md text-label-md text-on-surface-variant uppercase tracking-wider border-b border-outline-variant/30">Name</th>
                        <th className="p-4 font-label-md text-label-md text-on-surface-variant uppercase tracking-wider border-b border-outline-variant/30">Phone</th>
                        <th className="p-4 font-label-md text-label-md text-on-surface-variant uppercase tracking-wider border-b border-outline-variant/30">Address</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-outline-variant/20">
                      {customerList.map((customer, idx) => (
                        <tr key={idx} className="hover:bg-surface-container-lowest/50 transition-colors">
                          <td className="p-4 font-body-md text-body-md text-on-surface">{customer.name || 'Unknown'}</td>
                          <td className="p-4 font-label-md text-label-md text-on-surface font-mono">{customer.phone}</td>
                          <td className="p-4 font-body-sm text-body-sm text-on-surface-variant max-w-[300px] break-words">{customer.address || 'N/A'}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
