import { useState } from 'react';
import { Link } from 'react-router-dom';

export default function CreateSeller() {
    const [formData, setFormData] = useState({
        sellerName: '',
        sellerId: '',
        contactNumber: '',
        whatsappNumber: '',
        email: '',
        password: '',
        confirmPassword: '',
        doorNo: '',
        street: '',
        area: '',
        city: '',
        pincode: ''
    });

    const [errors, setErrors] = useState({});
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirmPassword, setShowConfirmPassword] = useState(false);
    const [syncWhatsapp, setSyncWhatsapp] = useState(false);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [showSuccess, setShowSuccess] = useState(false);
    const [globalError, setGlobalError] = useState(false);

    const calculateStrength = (pwd) => {
        let score = 0;
        if (pwd.length > 7) score++;
        if (/[A-Z]/.test(pwd)) score++;
        if (/[0-9]/.test(pwd)) score++;
        if (/[^A-Za-z0-9]/.test(pwd)) score++;
        return score;
    };

    const strengthScore = calculateStrength(formData.password);

    const strengthText =
        strengthScore === 0 ? (formData.password ? 'Very Weak' : 'Enter password') :
            strengthScore === 1 ? 'Weak' :
                strengthScore === 2 ? 'Fair' :
                    strengthScore === 3 ? 'Good' : 'Strong';

    const strengthColorClass =
        strengthScore === 0 ? 'bg-surface-container' :
            strengthScore === 1 ? 'bg-error' :
                strengthScore === 2 ? 'bg-tertiary' :
                    strengthScore === 3 ? 'bg-primary' : 'bg-secondary';

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => {
            const newData = { ...prev, [name]: value };
            if (name === 'contactNumber' && syncWhatsapp) {
                newData.whatsappNumber = value;
            }
            return newData;
        });
        // Clear specific error
        if (errors[name]) {
            setErrors(prev => ({ ...prev, [name]: null }));
        }
    };

    const handleSyncWhatsapp = (e) => {
        setSyncWhatsapp(e.target.checked);
        if (e.target.checked) {
            setFormData(prev => ({ ...prev, whatsappNumber: prev.contactNumber }));
            setErrors(prev => ({ ...prev, whatsappNumber: null }));
        }
    };

    const validate = () => {
        const newErrors = {};
        if (!formData.sellerName.trim()) newErrors.sellerName = 'This field is required.';
        if (!formData.sellerId.trim()) newErrors.sellerId = 'This field is required.';
        if (!/^\d{10}$/.test(formData.contactNumber)) newErrors.contactNumber = 'Please enter a valid contact number (10 digits).';
        if (!/^\d{10}$/.test(formData.whatsappNumber)) newErrors.whatsappNumber = 'Please enter a valid WhatsApp number (10 digits).';
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) newErrors.email = 'Please enter a valid email address.';
        if (formData.password.length < 8) newErrors.password = 'Password must be at least 8 characters.';
        if (formData.password !== formData.confirmPassword) newErrors.confirmPassword = 'Passwords do not match.';
        if (!formData.doorNo.trim()) newErrors.doorNo = 'Door No is required.';
        if (!formData.street.trim()) newErrors.street = 'Street is required.';
        if (!formData.area.trim()) newErrors.area = 'Area is required.';
        if (!formData.city.trim()) newErrors.city = 'City is required.';
        if (!/^\d{6}$/.test(formData.pincode)) newErrors.pincode = 'Valid 6-digit Pincode is required.';
        return newErrors;
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        const newErrors = validate();
        if (Object.keys(newErrors).length > 0) {
            setErrors(newErrors);
            setGlobalError(true);
            return;
        }

        setGlobalError(false);
        setIsSubmitting(true);

        const combinedAddress = `${formData.doorNo.trim()}, ${formData.street.trim()}, ${formData.area.trim()}, ${formData.city.trim()} - ${formData.pincode.trim()}`;

        // Call backend API
        fetch(`${import.meta.env.VITE_API_URL}/auth/admin/seller`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                sellerName: formData.sellerName,
                sellerId: formData.sellerId,
                contactNumber: formData.contactNumber,
                address: combinedAddress,
                password: formData.password
            })
        })
        .then(async (res) => {
            const data = await res.json();
            if (!res.ok) {
                throw new Error(data.message || 'Failed to create seller');
            }
            setIsSubmitting(false);
            setShowSuccess(true);
        })
        .catch((error) => {
            setIsSubmitting(false);
            setGlobalError(true);
            setErrors({
                sellerId: error.message.includes('ID') ? error.message : null,
                contactNumber: error.message.includes('contact') ? error.message : null,
            });
            console.error('Submission error:', error);
        });
    };

    const prefill = () => {
        setFormData({
            sellerName: 'AquaFlow Demo Agency',
            sellerId: `S-${Math.floor(1000 + Math.random() * 9000)}`,
            contactNumber: '9876543210',
            whatsappNumber: '9876543210',
            email: 'demo@aquaflow.com',
            password: 'Password@123',
            confirmPassword: 'Password@123',
            doorNo: '123',
            street: 'Main Road',
            area: 'Indiranagar',
            city: 'Bangalore',
            pincode: '560038'
        });
        setSyncWhatsapp(true);
        setErrors({});
        setGlobalError(false);
    };

    const generateId = () => {
        setFormData(prev => ({
            ...prev,
            sellerId: `S-${Math.floor(1000 + Math.random() * 9000)}`
        }));
        setErrors(prev => ({ ...prev, sellerId: null }));
    };

    const simulateError = () => {
        setGlobalError(true);
        setErrors({
            sellerId: 'This ID is already registered.',
            email: 'Email already exists.'
        });
    };

    if (showSuccess) {
        return (
            <div className="w-full max-w-5xl mx-auto flex flex-col gap-space-lg pb-space-xl">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-space-sm">
                    <div className="flex flex-col gap-1">
                        <nav aria-label="Breadcrumb" className="flex items-center gap-space-xs font-caption text-caption text-on-surface-variant mb-1">
                            <Link to="/" className="hover:text-primary transition-colors flex items-center gap-1">
                                <span className="material-symbols-outlined text-[15px]">grid_view</span>
                                <span>Dashboard</span>
                            </Link>
                            <span className="text-outline-variant">/</span>
                            <span className="text-on-surface font-semibold">Create Seller</span>
                        </nav>
                    </div>
                </div>
                <div className="flex flex-col gap-space-lg">
                    <div className="bg-surface-container-lowest rounded-xl shadow-sm p-space-xl flex flex-col items-center text-center">
                        <div className="w-16 h-16 rounded-full bg-secondary-fixed/50 text-secondary flex items-center justify-center mb-space-md shadow-sm">
                            <span className="material-symbols-outlined text-[36px]" style={{ fontVariationSettings: '"FILL" 1' }}>check_circle</span>
                        </div>
                        <h2 className="font-headline-lg text-headline-lg text-on-surface mb-space-xs">Seller Created Successfully</h2>
                        <p className="font-body-md text-body-md text-on-surface-variant max-w-lg mb-space-lg">
                            The water delivery agency has been registered to the AquaFlow network and login credentials have been dispatched via automated SMS and Email.
                        </p>
                        <div className="w-full max-w-xl bg-surface-container-low rounded-xl p-space-lg text-left mb-space-xl flex flex-col gap-space-md">
                            <div className="flex items-center justify-between pb-space-sm border-b border-outline-variant/20">
                                <span className="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider">Registration Receipt</span>
                                <span className="px-space-xs py-0.5 rounded-full bg-secondary-fixed text-on-secondary-fixed-variant font-label-sm text-label-sm flex items-center gap-1">
                                    <span className="w-1.5 h-1.5 rounded-full bg-secondary"></span> Active &amp; Verified
                                </span>
                            </div>
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-space-md mt-2">
                                <div className="flex flex-col">
                                    <span className="font-caption text-caption text-on-surface-variant">Seller Entity Name</span>
                                    <span className="font-headline-sm text-headline-sm text-on-surface">{formData.sellerName}</span>
                                </div>
                                <div className="flex flex-col">
                                    <span className="font-caption text-caption text-on-surface-variant">Unique Network ID</span>
                                    <span className="font-headline-sm text-headline-sm text-primary font-mono">{formData.sellerId}</span>
                                </div>
                                <div className="flex flex-col">
                                    <span className="font-caption text-caption text-on-surface-variant">Primary Dispatch Phone</span>
                                    <span className="font-body-lg text-body-lg text-on-surface font-medium">+91 {formData.contactNumber}</span>
                                </div>
                                <div className="flex flex-col">
                                    <span className="font-caption text-caption text-on-surface-variant">Dispatch WhatsApp</span>
                                    <span className="font-body-lg text-body-lg text-on-surface font-medium">+91 {formData.whatsappNumber}</span>
                                </div>
                                <div className="flex flex-col sm:col-span-2">
                                    <span className="font-caption text-caption text-on-surface-variant">Registered Hub Location</span>
                                    <span className="font-body-md text-body-md text-on-surface">{formData.address}</span>
                                </div>
                            </div>
                        </div>
                        <div className="flex flex-wrap items-center justify-center gap-space-md w-full max-w-md">
                            <Link to="/" className="w-full sm:w-auto flex-1 inline-flex items-center justify-center gap-space-xs px-space-lg py-2.5 rounded-full bg-primary text-on-primary hover:bg-primary-container transition-all shadow-sm font-label-md text-label-md">
                                <span className="material-symbols-outlined text-[18px]">dashboard</span>
                                <span>Go to Dashboard</span>
                            </Link>
                            <button
                                onClick={() => {
                                    setFormData({ sellerName: '', sellerId: '', contactNumber: '', whatsappNumber: '', email: '', password: '', confirmPassword: '', address: '' });
                                    setShowSuccess(false);
                                    setSyncWhatsapp(false);
                                }}
                                className="w-full sm:w-auto inline-flex items-center justify-center gap-space-xs px-space-lg py-2.5 rounded-full bg-surface-container hover:bg-surface-container-high text-on-surface transition-all font-label-md text-label-md"
                                type="button"
                            >
                                <span className="material-symbols-outlined text-[18px]">person_add</span>
                                <span>Register Another Seller</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="w-full max-w-5xl mx-auto flex flex-col gap-space-lg pb-space-xl">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-space-sm">
                <div className="flex flex-col gap-1">
                    <nav aria-label="Breadcrumb" className="flex items-center gap-space-xs font-caption text-caption text-on-surface-variant mb-1">
                        <Link to="/" className="hover:text-primary transition-colors flex items-center gap-1">
                            <span className="material-symbols-outlined text-[15px]">grid_view</span>
                            <span>Dashboard</span>
                        </Link>
                        <span className="text-outline-variant">/</span>
                        <span className="text-on-surface font-semibold">Create Seller</span>
                    </nav>
                    <div className="flex items-center gap-space-sm">
                        <h1 className="font-headline-lg text-headline-lg text-on-surface tracking-tight">Create Seller</h1>
                        <span className="inline-flex items-center gap-1 px-space-sm py-0.5 rounded-full bg-secondary-fixed/40 text-on-secondary-fixed-variant font-label-sm text-label-sm">
                            <span className="material-symbols-outlined text-[13px] text-secondary">verified</span> New Onboarding
                        </span>
                    </div>
                    <p className="font-body-md text-body-md text-on-surface-variant">Register a new water can delivery agency or distributor to the AquaFlow network.</p>
                </div>
            </div>

            {globalError && (
                <div className="transition-all duration-300">
                    <div className="p-space-md rounded-xl bg-error-container text-on-error-container flex items-start gap-space-sm shadow-sm">
                        <span className="material-symbols-outlined text-error text-[22px] shrink-0 mt-0.5">error</span>
                        <div className="flex-1 flex flex-col gap-0.5">
                            <p className="font-headline-sm text-headline-sm font-semibold">Unable to create seller</p>
                            <p className="font-body-md text-body-md text-on-error-container/90">Please check the highlighted information below, resolve all errors, and try again.</p>
                        </div>
                        <button onClick={() => setGlobalError(false)} className="text-on-error-container/70 hover:text-on-error-container p-1 rounded-full" type="button">
                            <span className="material-symbols-outlined text-[18px]">close</span>
                        </button>
                    </div>
                </div>
            )}

            <div className="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden transition-all">
                <div className="p-space-lg bg-surface-container-low flex flex-col md:flex-row md:items-center justify-between gap-space-sm">
                    <div className="flex items-center gap-space-md">
                        <div className="w-10 h-10 rounded-full bg-primary-fixed text-primary flex items-center justify-center shadow-xs">
                            <span className="material-symbols-outlined text-[20px]">badge</span>
                        </div>
                        <div className="flex flex-col">
                            <h2 className="font-headline-md text-headline-md text-on-surface">Seller Information &amp; Credentials</h2>
                            <p className="font-caption text-caption text-on-surface-variant">Fill in agency verification details and setup administrator sign-in access</p>
                        </div>
                    </div>
                </div>
                <form className="p-space-lg md:p-space-xl flex flex-col gap-space-lg" onSubmit={handleSubmit} noValidate>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-x-space-xl gap-y-space-lg">
                        <div className="flex flex-col gap-space-lg">
                            <div className="flex items-center gap-2 pb-1 text-primary">
                                <span className="material-symbols-outlined text-[18px]">domain</span>
                                <span className="font-label-md text-label-md tracking-wider uppercase font-semibold">Business Identity</span>
                            </div>

                            <div className="flex flex-col gap-1.5">
                                <label className="font-label-md text-label-md text-on-surface font-semibold flex items-center justify-between" htmlFor="sellerName">
                                    <span>Seller Name <span className="text-error">*</span></span>
                                    <span className="font-caption text-caption text-on-surface-variant font-normal">Agency name</span>
                                </label>
                                <div className="relative">
                                    <input
                                        className={`w-full h-11 px-3.5 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.sellerName ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`}
                                        id="sellerName" name="sellerName" placeholder="Enter seller name (e.g. Ganga Pure Waters)" type="text"
                                        value={formData.sellerName} onChange={handleChange}
                                    />
                                </div>
                                {!errors.sellerName && <span className="font-caption text-caption text-on-surface-variant">Business or agency legal name registered with AquaFlow</span>}
                                {errors.sellerName && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.sellerName}</span>}
                            </div>

                            <div className="flex flex-col gap-1.5">
                                <div className="flex items-center justify-between">
                                    <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="sellerId">
                                        Seller ID <span className="text-error">*</span>
                                    </label>
                                </div>
                                <div className="relative flex items-center">
                                    <input
                                        className={`w-full h-11 pl-3.5 pr-24 uppercase font-mono rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.sellerId ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`}
                                        id="sellerId" name="sellerId" placeholder="Enter unique seller ID (e.g. S-1042)" type="text"
                                        value={formData.sellerId} onChange={handleChange}
                                    />
                                    <button onClick={generateId} className="absolute right-2 top-1/2 -translate-y-1/2 px-2 py-1 rounded bg-surface-container hover:bg-surface-container-high text-primary font-caption text-caption font-semibold transition-colors" type="button">
                                        Generate
                                    </button>
                                </div>
                                {!errors.sellerId && <span className="font-caption text-caption text-on-surface-variant">Real-time uniqueness check (Prefix 'S-' recommended)</span>}
                                {errors.sellerId && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.sellerId}</span>}
                            </div>

                            <div className="flex flex-col gap-1.5">
                                <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="contactNumber">
                                    Contact Number <span className="text-error">*</span>
                                </label>
                                <div className="relative flex items-center">
                                    <div className="absolute left-0 top-0 bottom-0 px-3 bg-surface-container flex items-center gap-1.5 rounded-l-lg pointer-events-none text-on-surface-variant font-label-md text-label-md">
                                        <span>+91</span>
                                    </div>
                                    <input
                                        className={`w-full h-11 pl-16 pr-3.5 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.contactNumber ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`}
                                        id="contactNumber" maxLength="10" name="contactNumber" placeholder="98765 43210" type="tel"
                                        value={formData.contactNumber} onChange={handleChange}
                                    />
                                </div>
                                {errors.contactNumber && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.contactNumber}</span>}
                            </div>

                            <div className="flex flex-col gap-1.5">
                                <div className="flex items-center justify-between flex-wrap gap-1">
                                    <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="whatsappNumber">
                                        WhatsApp Number <span className="text-error">*</span>
                                    </label>
                                    <label className="flex items-center gap-1.5 cursor-pointer text-on-surface-variant hover:text-on-surface select-none">
                                        <input
                                            className="w-4 h-4 rounded text-primary focus:ring-0 accent-primary cursor-pointer"
                                            type="checkbox"
                                            checked={syncWhatsapp}
                                            onChange={handleSyncWhatsapp}
                                        />
                                        <span className="font-caption text-caption font-medium">Same as Contact Number</span>
                                    </label>
                                </div>
                                <div className="relative flex items-center">
                                    <div className="absolute left-0 top-0 bottom-0 px-3 bg-surface-container flex items-center gap-1.5 rounded-l-lg pointer-events-none text-on-surface-variant font-label-md text-label-md">
                                        <span className="material-symbols-outlined text-[16px] text-secondary">chat</span>
                                        <span>+91</span>
                                    </div>
                                    <input
                                        className={`w-full h-11 pl-20 pr-3.5 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.whatsappNumber ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`}
                                        id="whatsappNumber" maxLength="10" name="whatsappNumber" placeholder="98765 43210" type="tel"
                                        value={formData.whatsappNumber} onChange={handleChange} readOnly={syncWhatsapp}
                                    />
                                </div>
                                {errors.whatsappNumber && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.whatsappNumber}</span>}
                            </div>
                        </div>

                        <div className="flex flex-col gap-space-lg">
                            <div className="flex items-center gap-2 pb-1 text-primary">
                                <span className="material-symbols-outlined text-[18px]">lock</span>
                                <span className="font-label-md text-label-md tracking-wider uppercase font-semibold">Access Credentials</span>
                            </div>

                            <div className="flex flex-col gap-1.5">
                                <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="email">
                                    Email Address <span className="text-error">*</span>
                                </label>
                                <div className="relative">
                                    <input
                                        className={`w-full h-11 px-3.5 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.email ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`}
                                        id="email" name="email" placeholder="contact@gangapurewaters.com" type="email"
                                        value={formData.email} onChange={handleChange}
                                    />
                                </div>
                                {errors.email && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.email}</span>}
                            </div>

                            <div className="flex flex-col gap-1.5">
                                <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="password">
                                    Password <span className="text-error">*</span>
                                </label>
                                <div className="relative">
                                    <input
                                        className={`w-full h-11 pl-3.5 pr-11 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.password ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`}
                                        id="password" name="password" placeholder="Create strong portal password" type={showPassword ? "text" : "password"}
                                        value={formData.password} onChange={handleChange}
                                    />
                                    <button onClick={() => setShowPassword(!showPassword)} className="absolute right-2.5 top-1/2 -translate-y-1/2 text-on-surface-variant hover:text-on-surface p-1" type="button">
                                        <span className="material-symbols-outlined text-[20px]">{showPassword ? 'visibility_off' : 'visibility'}</span>
                                    </button>
                                </div>

                                <div className="flex flex-col gap-1 mt-1">
                                    <div className="flex items-center gap-1.5 w-full">
                                        <div className={`h-1.5 flex-1 rounded-full transition-colors duration-300 ${strengthScore > 0 ? strengthColorClass : 'bg-surface-container'}`}></div>
                                        <div className={`h-1.5 flex-1 rounded-full transition-colors duration-300 ${strengthScore > 1 ? strengthColorClass : 'bg-surface-container'}`}></div>
                                        <div className={`h-1.5 flex-1 rounded-full transition-colors duration-300 ${strengthScore > 2 ? strengthColorClass : 'bg-surface-container'}`}></div>
                                        <div className={`h-1.5 flex-1 rounded-full transition-colors duration-300 ${strengthScore > 3 ? strengthColorClass : 'bg-surface-container'}`}></div>
                                    </div>
                                    <div className="flex items-center justify-between font-caption text-caption text-on-surface-variant">
                                        <span>Password strength:</span>
                                        <span className={`font-medium ${strengthScore > 0 ? 'text-primary' : 'text-outline'}`}>{strengthText}</span>
                                    </div>
                                </div>
                                {errors.password && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.password}</span>}
                            </div>

                            <div className="flex flex-col gap-1.5">
                                <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="confirmPassword">
                                    Confirm Password <span className="text-error">*</span>
                                </label>
                                <div className="relative">
                                    <input
                                        className={`w-full h-11 pl-3.5 pr-11 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.confirmPassword ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`}
                                        id="confirmPassword" name="confirmPassword" placeholder="Re-enter password" type={showConfirmPassword ? "text" : "password"}
                                        value={formData.confirmPassword} onChange={handleChange}
                                    />
                                    <button onClick={() => setShowConfirmPassword(!showConfirmPassword)} className="absolute right-2.5 top-1/2 -translate-y-1/2 text-on-surface-variant hover:text-on-surface p-1" type="button">
                                        <span className="material-symbols-outlined text-[20px]">{showConfirmPassword ? 'visibility_off' : 'visibility'}</span>
                                    </button>
                                </div>
                                {errors.confirmPassword && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.confirmPassword}</span>}
                            </div>
                        </div>

                        <div className="md:col-span-2">
                            <div className="flex items-center gap-2 pb-3 text-primary">
                                <span className="material-symbols-outlined text-[18px]">location_on</span>
                                <span className="font-label-md text-label-md tracking-wider uppercase font-semibold">Logistics Territory &amp; Hub</span>
                            </div>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-x-space-lg gap-y-space-md">
                                <div className="flex flex-col gap-1.5">
                                    <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="doorNo">Door / Building No <span className="text-error">*</span></label>
                                    <input className={`w-full h-11 px-3.5 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.doorNo ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`} id="doorNo" name="doorNo" placeholder="No 12/A" type="text" value={formData.doorNo} onChange={handleChange} />
                                    {errors.doorNo && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.doorNo}</span>}
                                </div>
                                <div className="flex flex-col gap-1.5">
                                    <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="street">Street Name <span className="text-error">*</span></label>
                                    <input className={`w-full h-11 px-3.5 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.street ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`} id="street" name="street" placeholder="Main Street" type="text" value={formData.street} onChange={handleChange} />
                                    {errors.street && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.street}</span>}
                                </div>
                                <div className="flex flex-col gap-1.5">
                                    <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="area">Area / Locality <span className="text-error">*</span></label>
                                    <input className={`w-full h-11 px-3.5 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.area ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`} id="area" name="area" placeholder="Downtown" type="text" value={formData.area} onChange={handleChange} />
                                    {errors.area && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.area}</span>}
                                </div>
                                <div className="flex flex-col gap-1.5">
                                    <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="city">City <span className="text-error">*</span></label>
                                    <input className={`w-full h-11 px-3.5 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.city ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`} id="city" name="city" placeholder="Chennai" type="text" value={formData.city} onChange={handleChange} />
                                    {errors.city && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.city}</span>}
                                </div>
                                <div className="flex flex-col gap-1.5 md:col-span-2 lg:col-span-1">
                                    <label className="font-label-md text-label-md text-on-surface font-semibold" htmlFor="pincode">Pincode <span className="text-error">*</span></label>
                                    <input className={`w-full h-11 px-3.5 rounded-lg bg-surface-container-low hover:bg-surface-container text-on-surface placeholder:text-outline/70 font-body-md text-body-md focus:bg-surface-container-lowest focus:outline-none focus:shadow-[0_0_0_2px_rgba(0,97,148,0.35)] transition-all ${errors.pincode ? 'border border-error shadow-[0_0_0_1px_rgba(186,26,26,1)]' : ''}`} id="pincode" name="pincode" placeholder="600001" maxLength="6" type="text" value={formData.pincode} onChange={handleChange} />
                                    {errors.pincode && <span className="font-caption text-caption text-error flex items-center gap-1 mt-0.5"><span className="material-symbols-outlined text-[14px]">error</span>{errors.pincode}</span>}
                                </div>
                            </div>
                        </div>
                    </div>

                    <div className="mt-space-md pt-space-lg flex flex-col sm:flex-row items-center justify-between gap-space-md bg-surface-container-lowest">
                        <div className="flex items-center gap-space-md w-full sm:w-auto">
                            <Link to="/" className="font-label-md text-label-md text-on-surface-variant hover:text-on-surface transition-colors py-2 px-1">
                                Cancel
                            </Link>
                            <button onClick={() => { setFormData({ sellerName: '', sellerId: '', contactNumber: '', whatsappNumber: '', email: '', password: '', confirmPassword: '', doorNo: '', street: '', area: '', city: '', pincode: '' }); setErrors({}); setGlobalError(false); setSyncWhatsapp(false); }} className="px-space-md py-2.5 rounded-full bg-surface-container hover:bg-surface-container-high text-on-surface font-label-md text-label-md transition-all flex items-center gap-1.5" type="button">
                                <span className="material-symbols-outlined text-[18px]">restart_alt</span>
                                <span>Reset Form</span>
                            </button>
                        </div>
                        <div className="w-full sm:w-auto flex items-center justify-end">
                            <button disabled={isSubmitting} className="w-full sm:w-auto min-w-[190px] px-space-xl py-3 rounded-full bg-primary hover:bg-primary-container text-on-primary font-headline-sm text-headline-sm transition-all shadow-md hover:shadow-lg flex items-center justify-center gap-space-xs disabled:opacity-70 disabled:cursor-not-allowed cursor-pointer" type="submit">
                                {isSubmitting ? (
                                    <span className="animate-spin h-5 w-5 border-2 border-on-primary border-t-transparent rounded-full"></span>
                                ) : (
                                    <span className="material-symbols-outlined text-[20px]">person_add</span>
                                )}
                                <span>{isSubmitting ? 'Processing...' : 'Create Seller'}</span>
                            </button>
                        </div>
                    </div>
                </form>
            </div>

        </div>
    );
}
