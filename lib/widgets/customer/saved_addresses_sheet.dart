import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/customer_address_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_address_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class SavedAddressesSheet extends StatefulWidget {
  const SavedAddressesSheet({super.key});

  static Future<CustomerAddressModel?> show(BuildContext context) {
    return showModalBottomSheet<CustomerAddressModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SavedAddressesSheet(),
    );
  }

  @override
  State<SavedAddressesSheet> createState() => _SavedAddressesSheetState();
}

class _SavedAddressesSheetState extends State<SavedAddressesSheet> {
  bool _isAdding = false;
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  bool _setAsDefault = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final customerId = auth.phoneDigits.isNotEmpty ? auth.phoneDigits : 'CUST-9842';
      context.read<CustomerAddressProvider>().loadAddresses(customerId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveNewAddress() async {
    final title = _titleController.text.trim();
    final addressLine = _addressController.text.trim();
    if (title.isEmpty || addressLine.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final customerId = auth.phoneDigits.isNotEmpty ? auth.phoneDigits : 'CUST-9842';

    final newAddress = CustomerAddressModel(
      customerId: customerId,
      title: title,
      addressLine: addressLine,
      isDefault: _setAsDefault,
    );

    final success = await context.read<CustomerAddressProvider>().addAddress(newAddress);
    if (success && mounted) {
      setState(() {
        _isAdding = false;
        _titleController.clear();
        _addressController.clear();
        _setAsDefault = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('addressAddedSuccess', fallback: 'Address saved successfully!')),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addrProv = context.watch<CustomerAddressProvider>();
    final addresses = addrProv.addresses;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('savedAddresses'),
                      style: AppTypography.heading(fontSize: 18),
                    ),
                  ],
                ),
                if (!_isAdding)
                  TextButton.icon(
                    onPressed: () => setState(() => _isAdding = true),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      context.tr('addNewAddress', fallback: 'Add New'),
                      style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body
          Flexible(
            child: addrProv.isLoading && addresses.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _isAdding
                    ? _buildAddAddressForm(context)
                    : _buildAddressList(context, addresses, addrProv),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAddressForm(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('newAddressTitle', fallback: 'Add New Address'),
            style: AppTypography.heading(fontSize: 16),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: context.tr('addressLabelName', fallback: 'Label (e.g. Home, Office, Parents)'),
              hintText: 'Home, Office, Shop...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.label_outline, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.tr('fullAddress', fallback: 'Full Street Address'),
              hintText: 'Flat / Door No, Apartment name, Road, Area, Pune - 411058',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.home_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: _setAsDefault,
            onChanged: (val) => setState(() => _setAsDefault = val),
            title: Text(
              context.tr('setAsDefaultAddress', fallback: 'Set as default address'),
              style: AppTypography.poppins(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isAdding = false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(context.tr('cancel', fallback: 'Cancel')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveNewAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    context.tr('save', fallback: 'Save Address'),
                    style: AppTypography.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(
    BuildContext context,
    List<CustomerAddressModel> addresses,
    CustomerAddressProvider addrProv,
  ) {
    if (addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                context.tr('noAddressesSaved', fallback: 'No saved addresses yet'),
                style: AppTypography.heading(fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('addAddressHint', fallback: 'Add your home or work address for quicker bookings.'),
                style: AppTypography.subtitle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => setState(() => _isAdding = true),
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.tr('addFirstAddress', fallback: 'Add Address')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final address = addresses[index];
        final isSelected = addrProv.selectedAddress?.id == address.id;

        return Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: address.isDefault ? const Color(0xFFE8F0FE) : Colors.grey.shade100,
              child: Icon(
                address.title.toLowerCase().contains('office') || address.title.toLowerCase().contains('work')
                    ? Icons.business
                    : Icons.home_rounded,
                color: address.isDefault ? AppColors.primary : Colors.grey.shade600,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Text(
                  address.title,
                  style: AppTypography.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      context.tr('defaultTag', fallback: 'DEFAULT'),
                      style: AppTypography.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                address.addressLine,
                style: AppTypography.subtitle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF64748B)),
              onSelected: (val) async {
                if (val == 'default' && address.id != null) {
                  await addrProv.setDefault(address.id!);
                } else if (val == 'delete' && address.id != null) {
                  await addrProv.deleteAddress(address.id!);
                }
              },
              itemBuilder: (_) => [
                if (!address.isDefault)
                  PopupMenuItem(
                    value: 'default',
                    child: Text(context.tr('setAsDefault', fallback: 'Set as Default')),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    context.tr('delete', fallback: 'Delete'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            onTap: () {
              addrProv.selectAddress(address);
              Navigator.pop(context, address);
            },
          ),
        );
      },
    );
  }
}
