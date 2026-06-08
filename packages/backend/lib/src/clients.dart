import 'package:ads_client/ads_client.dart' as ads_client;
import 'package:analytics_client/analytics_client.dart' as analytics_client;
import 'package:audit_client/audit_client.dart' as audit_client;
import 'package:catalog_client/catalog_client.dart' as catalog_client;
import 'package:config_client/config_client.dart' as config_client;
import 'package:device_client/device_client.dart' as device_client;
import 'package:disputes_client/disputes_client.dart' as disputes_client;
import 'package:fulfillment_client/fulfillment_client.dart'
    as fulfillment_client;
import 'package:geo_client/geo_client.dart' as geo_client;
import 'package:gift_cards_client/gift_cards_client.dart' as gift_cards_client;
import 'package:identity_client/identity_client.dart' as identity_client;
import 'package:inventory_client/inventory_client.dart' as inventory_client;
import 'package:kitchen_client/kitchen_client.dart' as kitchen_client;
import 'package:kyc_client/kyc_client.dart' as kyc_client;
import 'package:loyalty_client/loyalty_client.dart' as loyalty_client;
import 'package:marketing_client/marketing_client.dart' as marketing_client;
import 'package:media_client/media_client.dart' as media_client;
import 'package:merchant_client/merchant_client.dart' as merchant_client;
import 'package:notifications_client/notifications_client.dart'
    as notifications_client;
import 'package:ordering_client/ordering_client.dart' as ordering_client;
import 'package:payments_client/payments_client.dart' as payments_client;
import 'package:payouts_client/payouts_client.dart' as payouts_client;
import 'package:pricing_client/pricing_client.dart' as pricing_client;
import 'package:promotions_client/promotions_client.dart' as promotions_client;
import 'package:recommendations_client/recommendations_client.dart'
    as recommendations_client;
import 'package:reservations_client/reservations_client.dart'
    as reservations_client;
import 'package:reviews_client/reviews_client.dart' as reviews_client;
import 'package:risk_client/risk_client.dart' as risk_client;
import 'package:search_client/search_client.dart' as search_client;
import 'package:support_client/support_client.dart' as support_client;
import 'package:wallet_client/wallet_client.dart' as wallet_client;
import 'package:webhooks_client/webhooks_client.dart' as webhooks_client;
import 'config.dart';

/// Aggregator that holds an instance of every Sorvete service's typed Serverpod
/// client. One [SorveteClients.bootstrap] call wires up the whole platform —
/// base URLs come from [ServerpodConfig] (which reads `--dart-define=FLAVOR=...`).
///
/// Usage:
///   final clients = SorveteClients.bootstrap();
///   final greeting = await clients.identity.greeting.hello('world');
///
/// Auth: attach an [AppAuthKeyManager] from `packages/backend` once the user
/// signs in; every client inherits it through the shared instance.
class SorveteClients {
  const SorveteClients({
    required this.ads,
    required this.analytics,
    required this.audit,
    required this.catalog,
    required this.config,
    required this.device,
    required this.disputes,
    required this.fulfillment,
    required this.geo,
    required this.giftCards,
    required this.identity,
    required this.inventory,
    required this.kitchen,
    required this.kyc,
    required this.loyalty,
    required this.marketing,
    required this.media,
    required this.merchant,
    required this.notifications,
    required this.ordering,
    required this.payments,
    required this.payouts,
    required this.pricing,
    required this.promotions,
    required this.recommendations,
    required this.reservations,
    required this.reviews,
    required this.risk,
    required this.search,
    required this.support,
    required this.wallet,
    required this.webhooks,
  });

  final ads_client.Client ads;
  final analytics_client.Client analytics;
  final audit_client.Client audit;
  final catalog_client.Client catalog;
  final config_client.Client config;
  final device_client.Client device;
  final disputes_client.Client disputes;
  final fulfillment_client.Client fulfillment;
  final geo_client.Client geo;
  final gift_cards_client.Client giftCards;
  final identity_client.Client identity;
  final inventory_client.Client inventory;
  final kitchen_client.Client kitchen;
  final kyc_client.Client kyc;
  final loyalty_client.Client loyalty;
  final marketing_client.Client marketing;
  final media_client.Client media;
  final merchant_client.Client merchant;
  final notifications_client.Client notifications;
  final ordering_client.Client ordering;
  final payments_client.Client payments;
  final payouts_client.Client payouts;
  final pricing_client.Client pricing;
  final promotions_client.Client promotions;
  final recommendations_client.Client recommendations;
  final reservations_client.Client reservations;
  final reviews_client.Client reviews;
  final risk_client.Client risk;
  final search_client.Client search;
  final support_client.Client support;
  final wallet_client.Client wallet;
  final webhooks_client.Client webhooks;

  /// Wire up all 32 clients with default URLs from [ServerpodConfig].
  /// Override individual base URLs by passing a [urlOverrides] map keyed by
  /// service name (e.g. `{'identity': 'http://10.0.2.2:8110'}` for Android).
  factory SorveteClients.bootstrap({Map<String, String>? urlOverrides}) {
    String resolve(String svc) =>
        urlOverrides?[svc] ?? ServerpodConfig.urlFor(svc);
    return SorveteClients(
      ads: ads_client.Client(resolve('ads')),
      analytics: analytics_client.Client(resolve('analytics')),
      audit: audit_client.Client(resolve('audit')),
      catalog: catalog_client.Client(resolve('catalog')),
      config: config_client.Client(resolve('config')),
      device: device_client.Client(resolve('device')),
      disputes: disputes_client.Client(resolve('disputes')),
      fulfillment: fulfillment_client.Client(resolve('fulfillment')),
      geo: geo_client.Client(resolve('geo')),
      giftCards: gift_cards_client.Client(resolve('gift_cards')),
      identity: identity_client.Client(resolve('identity')),
      inventory: inventory_client.Client(resolve('inventory')),
      kitchen: kitchen_client.Client(resolve('kitchen')),
      kyc: kyc_client.Client(resolve('kyc')),
      loyalty: loyalty_client.Client(resolve('loyalty')),
      marketing: marketing_client.Client(resolve('marketing')),
      media: media_client.Client(resolve('media')),
      merchant: merchant_client.Client(resolve('merchant')),
      notifications: notifications_client.Client(resolve('notifications')),
      ordering: ordering_client.Client(resolve('ordering')),
      payments: payments_client.Client(resolve('payments')),
      payouts: payouts_client.Client(resolve('payouts')),
      pricing: pricing_client.Client(resolve('pricing')),
      promotions: promotions_client.Client(resolve('promotions')),
      recommendations: recommendations_client.Client(
        resolve('recommendations'),
      ),
      reservations: reservations_client.Client(resolve('reservations')),
      reviews: reviews_client.Client(resolve('reviews')),
      risk: risk_client.Client(resolve('risk')),
      search: search_client.Client(resolve('search')),
      support: support_client.Client(resolve('support')),
      wallet: wallet_client.Client(resolve('wallet')),
      webhooks: webhooks_client.Client(resolve('webhooks')),
    );
  }
}
