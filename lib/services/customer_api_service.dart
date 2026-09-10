import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/customer_address_model.dart';
import '../models/customer_dashboard_data.dart';
import '../models/notification_model.dart';
import 'api_config.dart';

class CustomerApiService {
  final http.Client _client;

  CustomerApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches all bookings for a customer
  Future<List<BookingItem>> fetchCustomerBookings(String customerId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/bookings/customer/$customerId');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.map((item) => BookingItem.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        debugPrint('[CustomerApiService] fetchCustomerBookings HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error fetching customer bookings: $e\n$stack');
    }
    return [];
  }

  /// Cancels an existing booking
  Future<BookingItem?> cancelBooking(String bookingId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId/cancel');
      final res = await _client.post(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return BookingItem.fromJson(data);
      } else {
        debugPrint('[CustomerApiService] cancelBooking HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error cancelling booking: $e\n$stack');
    }
    return null;
  }

  /// Fetches real-time tracking data for a booking
  Future<Map<String, dynamic>?> fetchBookingTracking(String bookingId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/bookings/$bookingId/track');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      } else {
        debugPrint('[CustomerApiService] fetchBookingTracking HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error tracking booking: $e\n$stack');
    }
    return null;
  }

  /// Fetches saved addresses for a customer
  Future<List<CustomerAddressModel>> fetchSavedAddresses(String customerId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/addresses?customer_id=$customerId');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.map((a) => CustomerAddressModel.fromJson(a as Map<String, dynamic>)).toList();
      } else {
        debugPrint('[CustomerApiService] fetchSavedAddresses HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error fetching saved addresses: $e\n$stack');
    }
    return [];
  }

  /// Creates a new saved address
  Future<CustomerAddressModel?> createSavedAddress(CustomerAddressModel address) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/addresses');
      final res = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(address.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 201 || res.statusCode == 200) {
        return CustomerAddressModel.fromJson(json.decode(res.body));
      } else {
        debugPrint('[CustomerApiService] createSavedAddress HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error creating saved address: $e\n$stack');
    }
    return null;
  }

  /// Sets an address as the default
  Future<bool> setDefaultAddress(int addressId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/addresses/$addressId/default');
      final res = await _client.put(url).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error setting default address: $e\n$stack');
      return false;
    }
  }

  /// Deletes a saved address
  Future<bool> deleteSavedAddress(int addressId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/addresses/$addressId');
      final res = await _client.delete(url).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error deleting saved address: $e\n$stack');
      return false;
    }
  }

  /// Fetches notifications feed for a customer
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/notifications?user_id=$userId');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.map((n) => NotificationModel.fromJson(n as Map<String, dynamic>)).toList();
      } else {
        debugPrint('[CustomerApiService] fetchNotifications HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error fetching notifications: $e\n$stack');
    }
    return [];
  }

  /// Marks a specific notification as read
  Future<bool> markNotificationRead(int notificationId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/read');
      final res = await _client.post(url).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error marking notification read: $e\n$stack');
      return false;
    }
  }

  /// Marks all notifications as read for a user
  Future<bool> markAllNotificationsRead(String userId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/notifications/read-all?user_id=$userId');
      final res = await _client.post(url).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error marking all notifications read: $e\n$stack');
      return false;
    }
  }

  /// Fetches the live services catalog
  Future<List<PopularServiceItem>> fetchServicesCatalog() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/services/catalog');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.map((item) => PopularServiceItem.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        debugPrint('[CustomerApiService] fetchServicesCatalog HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error fetching services catalog: $e\n$stack');
    }
    return PopularServiceItem.defaults;
  }

  /// Fetches reviews for a worker
  Future<List<Map<String, dynamic>>> fetchWorkerReviews(int workerId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/ratings/worker/$workerId');
      final res = await _client.get(url).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        return list.cast<Map<String, dynamic>>();
      } else {
        debugPrint('[CustomerApiService] fetchWorkerReviews HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error fetching worker reviews: $e\n$stack');
    }
    return [];
  }

  /// Submits rating and review for a completed service
  Future<Map<String, dynamic>?> submitRating({
    required String bookingId,
    required int workerId,
    required double rating,
    String? reviewText,
    List<String>? tags,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/ratings/submit');
      final res = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'booking_id': bookingId,
              'worker_id': workerId,
              'rating': rating,
              'review_text': reviewText ?? '',
              'tags': tags ?? [],
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      } else {
        debugPrint('[CustomerApiService] submitRating HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error submitting rating: $e\n$stack');
    }
    return null;
  }

  /// Multimodal/Text AI problem parsing
  Future<Map<String, dynamic>?> parseProblem({
    required String text,
    String? languageCode,
    bool mediaAttached = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/ai/parse-problem');
      final res = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'problem_text': text,
              'language_code': languageCode ?? 'en',
              'media_attached': mediaAttached,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      } else {
        debugPrint('[CustomerApiService] parseProblem HTTP ${res.statusCode}: ${res.body}');
      }
    } catch (e, stack) {
      debugPrint('[CustomerApiService] Error parsing AI problem: $e\n$stack');
    }
    return null;
  }
}
