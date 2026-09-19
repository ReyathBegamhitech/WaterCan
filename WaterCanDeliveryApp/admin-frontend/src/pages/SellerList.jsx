import React, { useState, useEffect } from 'react';

export default function SellerList() {
  const [sellers, setSellers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isDeleting, setIsDeleting] = useState(false);

  // Edit Modal State
  const [isEditing, setIsEditing] = useState(false);
  const [currentSeller, setCurrentSeller] = useState(null);
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [editForm, setEditForm] = useState({
    sellerName: '',
    contactNumber: '',
    address: '',
    password: ''
  });
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    fetchSellers();
  }, []);

  const fetchSellers = async () => {
    try {
      setLoading(true);
      const res = await fetch('http://localhost:3000/api/auth/admin/sellers');
      const data = await res.json();
      if (data.success) {
        setSellers(data.sellers);
      } else {
        setError(data.message || 'Failed to load sellers');
      }
    } catch (err) {
      setError('Error connecting to backend');
    } finally {
      setLoading(false);
    }
  };

  const handleEditClick = (seller) => {
    setCurrentSeller(seller);
    setEditForm({
      sellerName: seller.organization_name,
      contactNumber: seller.phone_number,
      address: seller.location,
      password: '' // Reset for new password
    });
    setShowCurrentPassword(false);
    setIsEditing(true);
  };

  const handleCloseModal = () => {
    setIsEditing(false);
    setCurrentSeller(null);
  };

  const handleSave = async () => {
    if (!editForm.sellerName || !editForm.contactNumber || !editForm.address) {
      alert("Name, phone, and address are required.");
      return;
    }

    try {
      setIsSaving(true);
      const res = await fetch(`http://localhost:3000/api/auth/admin/seller/${currentSeller.seller_id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          sellerName: editForm.sellerName,
          contactNumber: editForm.contactNumber,
          address: editForm.address,
          password: editForm.password
        }),
      });
      const data = await res.json();
      if (data.success) {
        setIsEditing(false);
        fetchSellers(); // Refresh list
      } else {
        alert(data.message || 'Failed to update seller');
      }
    } catch (err) {
      alert('Error updating seller');
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async (sellerId) => {
    if (!window.confirm(`Are you sure you want to delete seller ${sellerId}? This action cannot be undone.`)) {
      return;
    }
    
    try {
      setIsDeleting(true);
      const res = await fetch(`http://localhost:3000/api/auth/admin/seller/${sellerId}`, {
        method: 'DELETE',
      });
      const data = await res.json();
      if (data.success) {
        fetchSellers(); // Refresh list
      } else {
        alert(data.message || 'Failed to delete seller');
      }
    } catch (err) {
      alert('Error deleting seller');
    } finally {
      setIsDeleting(false);
    }
  };

  if (loading) {
    return (
      <div className="flex h-full items-center justify-center p-8">
        <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-8">
        <div className="bg-error/10 text-error p-4 rounded-lg">
          {error}
        </div>
      </div>
    );
  }

  return (
    <div className="p-space-lg max-w-7xl mx-auto flex flex-col gap-space-lg">
      <div className="flex flex-col gap-space-xs">
        <h1 className="font-display-md text-display-md text-on-surface tracking-tight">Registered Sellers</h1>
        <p className="font-body-lg text-body-lg text-on-surface-variant">
          Manage and view all seller accounts in the network.
        </p>
      </div>

      <div className="bg-surface-container-lowest rounded-2xl border border-outline-variant/30 overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-surface-container-low border-b border-outline-variant/30 text-label-lg font-label-lg text-on-surface-variant">
                <th className="py-4 px-6 font-semibold">Seller ID</th>
                <th className="py-4 px-6 font-semibold">Organization Name</th>
                <th className="py-4 px-6 font-semibold">Contact Number</th>
                <th className="py-4 px-6 font-semibold">Location</th>
                <th className="py-4 px-6 font-semibold">Password</th>
                <th className="py-4 px-6 font-semibold text-right">Actions</th>
              </tr>
            </thead>
            <tbody>
              {sellers.length === 0 ? (
                <tr>
                  <td colSpan="6" className="py-8 text-center text-on-surface-variant">
                    No sellers found.
                  </td>
                </tr>
              ) : (
                sellers.map((seller) => (
                  <tr key={seller.seller_id} className="border-b border-outline-variant/10 hover:bg-surface-container-low/50 transition-colors">
                    <td className="py-4 px-6">
                      <span className="font-mono bg-primary/10 text-primary px-2 py-1 rounded text-sm font-semibold">
                        {seller.seller_id}
                      </span>
                    </td>
                    <td className="py-4 px-6 font-medium text-on-surface">
                      {seller.organization_name}
                    </td>
                    <td className="py-4 px-6 text-on-surface-variant">
                      {seller.phone_number}
                    </td>
                    <td className="py-4 px-6 text-on-surface-variant max-w-xs truncate" title={seller.location}>
                      {seller.location}
                    </td>
                    <td className="py-4 px-6 font-mono text-sm text-on-surface-variant/80">
                      {seller.plain_password || <span className="italic text-on-surface-variant/50">Not Set</span>}
                    </td>
                    <td className="py-4 px-6 text-right flex items-center justify-end gap-2">
                      <button
                        onClick={() => handleEditClick(seller)}
                        className="inline-flex items-center justify-center w-10 h-10 rounded-full bg-primary/10 text-primary hover:bg-primary/20 transition-colors group"
                        title="Edit Seller"
                      >
                        <span className="material-symbols-outlined text-[20px] group-hover:scale-110 transition-transform">edit</span>
                      </button>
                      <button
                        onClick={() => handleDelete(seller.seller_id)}
                        disabled={isDeleting}
                        className="inline-flex items-center justify-center w-10 h-10 rounded-full bg-error/10 text-error hover:bg-error/20 transition-colors group disabled:opacity-50"
                        title="Delete Seller"
                      >
                        <span className="material-symbols-outlined text-[20px] group-hover:scale-110 transition-transform">delete</span>
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Edit Modal */}
      {isEditing && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm p-4">
          <div className="bg-surface-container-lowest rounded-2xl shadow-xl w-full max-w-lg overflow-hidden flex flex-col max-h-[90vh]">
            <div className="flex items-center justify-between p-6 border-b border-outline-variant/20 bg-surface-container-low shrink-0">
              <h2 className="text-xl font-bold text-on-surface">Edit Seller Details</h2>
              <button onClick={handleCloseModal} className="text-on-surface-variant hover:text-on-surface">
                <span className="material-symbols-outlined">close</span>
              </button>
            </div>
            
            <div className="p-6 flex flex-col gap-4 overflow-y-auto">
              <div>
                <label className="block text-sm font-medium text-on-surface-variant mb-1">Seller ID (Cannot be changed)</label>
                <input
                  type="text"
                  disabled
                  value={currentSeller?.seller_id || ''}
                  className="w-full px-4 py-2 bg-surface-container-high border border-outline-variant/50 rounded-lg text-on-surface/50 font-mono cursor-not-allowed"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-on-surface-variant mb-1">Organization Name</label>
                <input
                  type="text"
                  value={editForm.sellerName}
                  onChange={(e) => setEditForm({ ...editForm, sellerName: e.target.value })}
                  className="w-full px-4 py-2 bg-surface-container-lowest border border-outline-variant/50 rounded-lg focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary text-on-surface"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-on-surface-variant mb-1">Contact Number</label>
                <input
                  type="text"
                  value={editForm.contactNumber}
                  onChange={(e) => setEditForm({ ...editForm, contactNumber: e.target.value })}
                  className="w-full px-4 py-2 bg-surface-container-lowest border border-outline-variant/50 rounded-lg focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary text-on-surface"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-on-surface-variant mb-1">Location / Address</label>
                <textarea
                  value={editForm.address}
                  onChange={(e) => setEditForm({ ...editForm, address: e.target.value })}
                  rows="3"
                  className="w-full px-4 py-2 bg-surface-container-lowest border border-outline-variant/50 rounded-lg focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary text-on-surface resize-none"
                ></textarea>
              </div>

              <div className="mt-2 pt-4 border-t border-outline-variant/20 flex flex-col gap-4">
                <div>
                  <label className="block text-sm font-medium text-on-surface-variant mb-1">Current Password</label>
                  <div className="relative">
                    <input
                      type={showCurrentPassword ? "text" : "password"}
                      disabled
                      value={currentSeller?.plain_password || 'No password saved'}
                      className="w-full px-4 py-2 bg-surface-container-high border border-outline-variant/50 rounded-lg text-on-surface/50 pr-12"
                    />
                    <button
                      type="button"
                      onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-on-surface-variant hover:text-on-surface transition-colors"
                    >
                      <span className="material-symbols-outlined text-[20px]">
                        {showCurrentPassword ? 'visibility_off' : 'visibility'}
                      </span>
                    </button>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-on-surface-variant mb-1">Change Password (Optional)</label>
                  <p className="text-xs text-on-surface-variant/70 mb-2">Leave blank to keep the current password.</p>
                  <input
                    type="text"
                    placeholder="Enter new password"
                    value={editForm.password}
                    onChange={(e) => setEditForm({ ...editForm, password: e.target.value })}
                    className="w-full px-4 py-2 bg-surface-container-lowest border border-outline-variant/50 rounded-lg focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary text-on-surface"
                  />
                </div>
              </div>
            </div>

            <div className="flex items-center justify-end p-6 border-t border-outline-variant/20 bg-surface-container-low gap-3 shrink-0">
              <button
                onClick={handleCloseModal}
                className="px-5 py-2 rounded-full font-medium text-on-surface-variant hover:bg-surface-container-high transition-colors"
                disabled={isSaving}
              >
                Cancel
              </button>
              <button
                onClick={handleSave}
                disabled={isSaving}
                className="px-6 py-2 rounded-full font-medium bg-primary text-on-primary hover:bg-primary/90 transition-colors flex items-center gap-2 shadow-sm disabled:opacity-70"
              >
                {isSaving && <span className="w-4 h-4 border-2 border-on-primary border-t-transparent rounded-full animate-spin"></span>}
                Save Changes
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
