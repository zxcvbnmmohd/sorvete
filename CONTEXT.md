# Sorvete

A hybrid commerce platform: a marketplace where Customers browse Merchants and place Orders, **and** a SaaS toolkit that Merchants use to run their own operations (POS, KDS, staff, inventory, analytics). Verticals supported include restaurants, groceries, butcher shops, convenience, retail, and similar.

## Language

### Tenants & people

**Platform**:
The Sorvete system as a whole. Things scoped to "the platform" sit above any individual Merchant.

**Merchant**:
A business that has signed up to use Sorvete. Owns one or more Locations and a Catalog. Optionally listed on the marketplace.
_Avoid_: Vendor, seller, store-owner, business-account.

**Location**:
A physical site belonging to a Merchant. The unit at which fulfillment happens, devices are paired, and Staff operate. A Merchant with one shop still has one Location.
_Avoid_: Store, branch, outlet, site, shop.

**User**:
A platform-level identity. A single User can hold multiple roles (Customer, Staff at one or more Merchants, Driver) without being duplicated.

**Customer**:
A User acting in the buyer role on the marketplace. Customer data lives at platform level; Merchants reference Customers by id.
_Avoid_: Client, buyer, shopper, end-user, account.

**Staff**:
A User authorized to act on behalf of a specific Merchant (operate POS, manage KDS, edit Catalog, view analytics). Staff is scoped to a Merchant; one User can be Staff at multiple Merchants independently.
_Avoid_: Employee, worker, operator, member.

**Driver**:
A User acting in the courier role, delivering Orders. May be a platform-pool driver or a Merchant's in-house driver (Merchant-scoped vs. platform-scoped is an unresolved boundary — flagged below).
_Avoid_: Courier, rider, dispatcher.

### Catalog

**Product**:
A sellable thing in a Merchant's Catalog. Carries `requires_preparation` and `prep_time_estimate`. The same data shape covers a burrito, a litre of milk, a phone case, and a litre of petrol.
_Avoid_: Menu item, SKU, listing, dish, article.

**Variant**:
A purchasable size/option of a Product (e.g. "Small / Medium / Large", "12oz / 16oz"). A Product always has at least one Variant; pricing lives on the Variant.
_Avoid_: Option, size, choice.

**Modifier**:
An add-on or substitution applied to an OrderLine at order time (e.g. "extra cheese", "no onions"). Modifiers belong to a Modifier Group attached to a Product.
_Avoid_: Add-on, extra, option, customization.

**Catalog**:
The set of Products a Merchant offers, optionally scoped per Location. "Menu" is a UX label only — the schema does not have a `Menu` entity.
_Avoid_: Menu, inventory (Inventory is a separate concept — stock levels).

**Vertical**:
A Merchant's business type (`restaurant`, `grocery`, `convenience`, `retail`, `service`, …). Drives default UI labels and feature gating, never the data model.

**Fulfillment Profile**:
A Location attribute describing how Orders are handled: `kitchen_prep`, `pick_from_shelf`, `mixed`. Decides whether a KDS is attached and whether prep states appear in the Order lifecycle.

### Commerce flow

**Cart**:
A Customer's in-progress selection scoped to **one Merchant**. A Customer can hold many concurrent Carts (one per Merchant). A Cart becomes an Order on checkout.
_Avoid_: Basket, bag, order-in-progress.

**Order**:
A committed, paid (or pay-on-fulfillment) Cart, attached to one Merchant and one Location, with a lifecycle that runs through fulfillment. Lifecycle states are conditional on Product `requires_preparation` and Location `fulfillment_profile`.
_Avoid_: Purchase, transaction, ticket (a Ticket is a KDS-level concept derived from an Order).

**OrderLine**:
One Variant + chosen Modifiers + quantity within an Order. The unit at which the kitchen prepares and the bagger picks. An Order is "ready" when every OrderLine is ready.
_Avoid_: Line item, basket item.

**Ticket**:
A KDS-side representation of an Order (or the prep-bearing subset of its OrderLines). Tickets only exist for Locations whose Fulfillment Profile includes kitchen work.

### Money

**Payment Method**:
The mechanism by which an Order is paid. One of: `card_stripe`, `wallet_balance`, `cash_at_pickup`, `cash_on_delivery`, `mobile_money_evc`, `mobile_money_zaad`, `mobile_money_mpesa`, `bank_transfer_local`. Adapters implement the same `(initiate, confirm, refund, reconcile)` interface.
_Avoid_: Payment type, pay method, payment mode.

**Payment Intent**:
The platform-side record of a planned payment for an Order, with a state machine that varies by Payment Method. Not synonymous with Stripe's PaymentIntent — it is the abstract envelope that *contains* a Stripe PaymentIntent (or a cash collection record, or a mobile money request) as its method-specific payload.

**Wallet**:
A platform-hosted ledger account holding a balance in a single currency for a User in a specific role context (Customer, Merchant, Driver). Movements are append-only `LedgerEntry` pairs (double-entry). A User can have multiple Wallets across roles and currencies.
_Avoid_: Balance, account, credit, store-of-value.

**LedgerEntry**:
An immutable debit-or-credit posting against a Wallet. Always created as a balanced pair (one debit + one credit, sums to zero across the system) within a `LedgerTransaction`.

**Cash Float**:
A Driver's current cash balance, equal to cash collected from Customers minus cash remitted to the platform/Merchant minus fees absorbed. Capped per-driver by a `cash_float_cap` to limit theft/loss exposure.

**Remittance**:
The act of a Driver (or, in some flows, a Merchant) handing collected cash back to the platform or a designated drop point. Tracked as a `RemittanceEvent` with `expected_amount` vs. `actual_amount`; variance triggers Risk review.

**Settlement**:
The periodic process of reconciling a Merchant's accrued platform-cut receivable (from cash and mobile-money orders) and discharging it — either by cash drop, bank transfer, or netting against incoming payouts.

**Payout**:
Money flowing *from* the platform *to* a Merchant or Driver, as distinct from Settlement which flows the other way (toward the platform). Card and mobile-money sales generate Payouts; cash sales generate Settlements.

**Platform Cut**:
The platform's commission on an Order, computed at pricing time, expressed as a money amount in the Order's currency. Collected automatically from card/mobile-money sales (subtracted before payout) and accrued as a receivable on cash sales (collected via Settlement).

**Order Completion Code (OTP)**:
A short numeric code issued to the Customer at order placement, required to mark a `cash_on_delivery` Order as `delivered`. The Customer reads it to the Driver; the Driver enters it in the Driver app. Missing/mismatched code blocks completion and routes to Risk.

### Devices

**POS Terminal**:
A paired device running the POS app at a specific Location. Paired via short code or QR scan, not by user login. Operates in staff-attended or self-service mode. Capable of working offline.
_Avoid_: Till, register, kiosk (kiosk is a *mode* of a POS Terminal, not a distinct device).

**KDS Display**:
A paired device running the KDS app at a specific Location. Only relevant where Fulfillment Profile includes kitchen work.
_Avoid_: Kitchen screen, prep monitor, expo.

**Device Pairing**:
The act of binding a physical device (POS Terminal or KDS Display) to a Merchant Location via a short code or QR. Distinct from User authentication — a paired device may still require a Staff user to sign in for accountability.

## Flagged ambiguities

- **In-house driver vs. platform driver**: Unresolved. A Merchant can "set up in-house delivery". Does that mean (a) a Merchant employs their own Drivers who use the standard Driver app under the Merchant's tenancy, or (b) Merchants simply toggle a "we self-deliver" flag and dispatch happens off-platform? To be resolved during Fulfillment service design.
- **Customer profile at marketplace vs. Merchant scope**: A User-as-Customer exists platform-wide, but a Merchant may want its own Customer profile (loyalty, notes, order history) tied to the same User. To be resolved during Customer/CRM service design.
- **"Menu" as UI label**: Allowed in user-facing copy for restaurant Merchants. **Never** in code, schema, or API names.

## Example dialogue

> **Dev**: A Customer added five things to their cart at El Camion and three things at Whole Foods. Are those one Cart or two?
> **Owner**: Two. One Cart per Merchant — they're separate businesses, separate checkouts, separate Orders.
>
> **Dev**: Whole Foods has a deli counter and shelves. If someone orders a sandwich and a bag of chips, what happens?
> **Owner**: The whole Order goes to that Whole Foods Location. The sandwich line is `requires_preparation: true`, so it shows up on the deli's KDS as a Ticket. The chips are `requires_preparation: false`, auto-ready the moment the Order is accepted. The Order itself isn't "ready" until both lines are ready.
>
> **Dev**: So the Order has a state, and each OrderLine has a state?
> **Owner**: Yes. The Order's state is derived from its OrderLines plus the Location's Fulfillment Profile. A gas station Location has `pick_from_shelf` — none of its Products require prep, no KDS, OrderLines go straight to ready on accept.
>
> **Dev**: When a Driver opens the app and sees this Whole Foods Order, what do they see?
> **Owner**: Approximate dropoff area only, until they accept and confirm pickup. After pickup, they see the full Customer address and contact.
