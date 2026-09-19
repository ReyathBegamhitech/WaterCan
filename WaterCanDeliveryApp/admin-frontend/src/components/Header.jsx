export default function Header() {
  return (
    <header className="fixed top-0 left-64 right-0 h-16 bg-surface-container-lowest/90 backdrop-blur-md border-b border-outline-variant/20 z-40 flex items-center justify-between px-gutter">
      <div className="flex items-center gap-space-md">
        <img
          alt="AquaFlow Water Delivery Admin Logo"
          className="h-8 w-auto object-contain"
          src="https://lh3.googleusercontent.com/aida/AEtjO1W9O2c-t0fJguo1QisCIOsVdSrR9zXwVNkWYkAAvd5fNUcKQK0Cri3MyKnu__aeWMGjzloTCkFI7E81-XHsDOLULG6vIS47vHwRqVRTnAc5IMCWjYA0y9RppSguoFEA8JJPOTHU7DjSeqSAMHBPSZJDlq-NLHZah9MNyvHmLZIVWBE1a0vYSI7RtW6dPRHF2DuQlK70oipspS5vU3bBqWhCvWAXeXZ1LUVBzgoWbgG5ACNIco2YmRivMp4"
        />
        <div className="h-4 w-px bg-outline-variant/50"></div>
        <span className="font-headline-sm text-headline-sm text-on-surface">AquaFlow Admin</span>
        <div className="hidden sm:flex items-center gap-space-xs px-space-sm py-0.5 rounded-full bg-surface-container text-on-surface-variant font-caption text-caption">
          <span className="material-symbols-outlined text-[14px]">water_drop</span>
          <span>Regional Logistics</span>
        </div>
      </div>
      <div className="flex items-center gap-space-lg">
        <div className="hidden md:flex items-center gap-space-xs px-space-md py-1 rounded-full bg-secondary-fixed/30 text-on-secondary-fixed-variant">
          <span className="w-2 h-2 rounded-full bg-secondary"></span>
          <span className="font-label-sm text-label-sm font-semibold">Operational</span>
        </div>
        <div className="flex items-center gap-space-sm pl-space-sm border-l border-outline-variant/30">
          <div className="text-right hidden sm:block">
            <p className="font-label-md text-[13px] font-medium text-on-surface leading-none">Super Admin</p>
          </div>
          <img
            alt="Profile"
            className="w-8 h-8 rounded-full object-cover ring-2 ring-primary-fixed"
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuCO9M9mlUQGXXfDyj9_QjWBIdxTcHH25IB3Y6WmN2lWb-DDWZpJFf06Zuyz0Y0qeCxDk-hh74iKtSesG4aGtw_BEClAXZObXB8a_-AN1NjtJo6U3cFNDs4d_qHfVVPPSSkp0--7Bn3wPXfHoDYiEib6W0G4-yXvbpflGudJKmSA_yGdwdx5W46K7SUZcgBBg6jPw37B_-ff49Z2cg8Ea7SiXnu_E7VeGFfj1pECBfepuclLz7i-vuS3"
          />
        </div>
      </div>
    </header>
  );
}
