import 'legal_content_ar.dart' show supportEmail, supportPhone;
import 'legal_document.dart';

/// English mirror of `legal_content_ar.dart`. Clause order and numbering match
/// the Arabic so the two can be diffed against each other when either changes.
const String legalLastUpdatedEn = 'September 2026';

const LegalDocument privacyPolicyEn = LegalDocument(
  title: 'Privacy Policy',
  lastUpdated: legalLastUpdatedEn,
  intro:
      'Amazonat Libya is committed to protecting the privacy of the people who '
      'use it, and to handling personal data responsibly and securely under the '
      'applicable laws and regulations. This policy explains what the Amazonat '
      'app collects, how that data is used and protected, and what rights you '
      'have over it. It forms part of the terms of using the platform.',
  sections: <LegalSection>[
    LegalSection(
      title: '1. Who this policy covers',
      paragraphs: <String>[
        'It applies to everyone who uses the Amazonat Libya app to shop, '
            'whether as a registered customer or as a visitor browsing without '
            'an account.',
      ],
    ),
    LegalSection(
      title: '2. What we collect',
      paragraphs: <String>[
        'You can browse products and stores without an account. When you create '
            'an account or place an order, we may collect:',
      ],
      bullets: <String>[
        'Account data: your name, phone number, and email address if you '
            'provide one.',
        'Delivery addresses: the address, its label and contact phone, and map '
            'coordinates if you choose to pin the location.',
        'Order data: the items ordered, amounts, payment method, order status, '
            'and any refund requests.',
        'Payment data: payments are completed by licensed payment providers. '
            'The app does not store your full card details.',
        'Technical data: device type, operating system, app version, push '
            'notification identifier, and usage logs that help us improve '
            'performance and security.',
      ],
    ),
    LegalSection(
      title: '3. Device permissions',
      paragraphs: <String>[
        'The app asks for a permission only at the moment it is needed, and you '
            'can refuse or withdraw it later from your device settings without '
            'the app ceasing to work:',
      ],
      bullets: <String>[
        'Location: requested only when you tap the locate-me button on the '
            'address map, and used to centre the map on where you are. We do '
            'not track your location in the background.',
        'Notifications: used to tell you about order status and updates to your '
            'account.',
        'Photos: the save permission is used only to download a refund transfer '
            'receipt to your photo library. The app does not read your photos.',
      ],
    ),
    LegalSection(
      title: '4. How we use data',
      bullets: <String>[
        'Creating and managing your account and verifying you by one-time code.',
        'Placing and processing orders, and arranging payment and delivery.',
        'Contacting you about your orders and providing support.',
        'Handling complaints and refund requests.',
        'Improving the platform and preventing fraud and unlawful use.',
      ],
    ),
    LegalSection(
      title: '5. Sharing data',
      paragraphs: <String>[
        'The platform does not sell user data or share it for unauthorised '
            'commercial purposes. Some data may be shared where necessary with:',
      ],
      bullets: <String>[
        'The selling store and delivery companies: your name, phone number and '
            'delivery address, for the sole purpose of fulfilling the order.',
        'Payment providers: only as far as needed to complete and verify the '
            'payment.',
        'Official authorities: where there is a legal request or obligation.',
      ],
    ),
    LegalSection(
      title: '6. Protecting data',
      paragraphs: <String>[
        'We take appropriate measures to protect data against unauthorised '
            'access, unlawful use and loss, including encrypting the connection '
            'to our servers, restricting access rights, and monitoring unusual '
            'activity. No electronic system can be guaranteed absolutely secure, '
            'given the nature of the internet and the technical risks involved.',
      ],
    ),
    LegalSection(
      title: '7. Your responsibility for your data',
      bullets: <String>[
        'Provide accurate information and update it when it changes.',
        'Keep your phone number and verification code confidential, and never '
            'share them.',
        'Do not share your account with others.',
      ],
    ),
    LegalSection(
      title: '8. Retention',
      paragraphs: <String>[
        'We keep your data for as long as needed to provide the service, keep '
            'financial and commercial records, protect the rights of the '
            'platform and its users, and meet legal requirements. Order and '
            'payment records are kept as financial documents even after an '
            'account is closed, with the details that identify you removed.',
      ],
    ),
    LegalSection(
      title: '9. Your rights and deleting your account',
      paragraphs: <String>[
        'You can ask for your account to be deleted at any time from inside the '
            'app: Account → Delete account. Confirming deactivates the account '
            'immediately and signs you out, and your personal data is then '
            'permanently erased after thirty (30) days. During that window you '
            'can contact support to reverse the request.',
      ],
      bullets: <String>[
        'Know what data is held about you, so far as the law allows.',
        'Ask for your data to be updated, or anything incorrect corrected.',
        'Delete your account and personal data as described above.',
        'Stop marketing messages, while still receiving the order '
            'notifications the service depends on.',
      ],
    ),
    LegalSection(
      title: '10. Messages and notifications',
      paragraphs: <String>[
        'The platform may send order notifications, service updates, and offers '
            'relating to the platform. You can turn off marketing notifications '
            'from your device settings; verification messages and order '
            'notifications remain part of the service.',
      ],
    ),
    LegalSection(
      title: "11. Children's privacy",
      paragraphs: <String>[
        'The app is not directed at children, and an account should not be '
            'created by anyone below the legal age to enter a contract. If an '
            'account is found to belong to a child, the platform will close it '
            'and delete its data.',
      ],
    ),
    LegalSection(
      title: '12. Changes to this policy',
      paragraphs: <String>[
        'The platform may amend this policy as services develop or as technical '
            'or legal requirements change. Updates will be announced through the '
            'appropriate channels inside the app.',
      ],
    ),
    LegalSection(
      title: '13. Contact',
      paragraphs: <String>[
        'For privacy questions or data deletion requests, write to '
            '$supportEmail or call $supportPhone.',
      ],
    ),
  ],
);

const LegalDocument termsOfServiceEn = LegalDocument(
  title: 'Terms & Conditions',
  lastUpdated: legalLastUpdatedEn,
  intro:
      'These terms govern your use of the Amazonat Libya app. By using the app '
      'or creating an account, you confirm that you have read and accepted '
      'these terms and the Privacy Policy.',
  sections: <LegalSection>[
    LegalSection(
      title: '1. The role of the platform',
      paragraphs: <String>[
        'Amazonat Libya is a marketplace connecting stores with customers. '
            'Products are listed and sold by registered stores, and those stores '
            'are responsible for the quality of the product and for its '
            'manufacture, packaging, storage, shelf life, and conformity with '
            'the published description. The platform organises the process, '
            'handles complaints, and determines responsibility on the available '
            'evidence.',
      ],
    ),
    LegalSection(
      title: '2. Accounts and registration',
      bullets: <String>[
        'You may browse without an account; an account is required to place and '
            'track orders.',
        'You sign in with your phone number and a one-time code sent to you. '
            'You are responsible for keeping that code confidential and for '
            'everything done through your account.',
        'You must provide accurate information and keep it up to date.',
        'The platform may suspend any account that breaches these terms or is '
            'used for fraud.',
      ],
    ),
    LegalSection(
      title: '3. Products and prices',
      bullets: <String>[
        'Prices are shown in Libyan dinar and may change, or stock may run out, '
            'before an order is completed.',
        'Stores must ensure the product matches the published images and '
            'description.',
        'The platform may remove any product that breaks the law, infringes the '
            'rights of others, or is unsafe, without the store\'s prior consent.',
      ],
    ),
    LegalSection(
      title: '4. Orders and fulfilment',
      bullets: <String>[
        'An order takes effect once it is confirmed in the app and a payment '
            'method is chosen.',
        'A single order cannot span more than one store; a separate order is '
            'created for each store.',
        'The store must prepare the order within the specified time, having '
            'checked the product, the quantity and the packaging.',
        'An order may be cancelled if the product is unavailable, the store '
            'cannot fulfil it, the order details are wrong, or for another '
            'legitimate reason accepted by the platform.',
      ],
    ),
    LegalSection(
      title: '5. Shipping and delivery',
      bullets: <String>[
        'The customer pays the delivery cost unless stated otherwise.',
        'Delivery fees are calculated by zone once a delivery address is '
            'chosen, and some stores may not cover every area.',
        'Each party bears the transport costs arising from its own error.',
      ],
    ),
    LegalSection(
      title: '6. Returns and exchanges',
      paragraphs: <String>[
        'A return is accepted where the product is damaged, differs from what '
            'was ordered, does not match its description, or where the store '
            'made an error.',
      ],
      bullets: <String>[
        'Where the store is at fault it bears the cost of the return, which may '
            'be deducted from its balance.',
        'Where the customer is at fault they bear the transport and return '
            'costs.',
        'Refunds are paid by the method approved on the platform, within the '
            'time needed to process the request.',
      ],
    ),
    LegalSection(
      title: '7. Complaints',
      paragraphs: <String>[
        'A complaint must include the order number, a description of the '
            'problem, and any available evidence. The platform team reviews the '
            'complaint, requests documents, contacts the parties, and determines '
            'responsibility on the evidence. Its decision is the basis for the '
            'operational steps taken on the platform.',
      ],
    ),
    LegalSection(
      title: '8. Acceptable use',
      bullets: <String>[
        'Do not use the app for any unlawful purpose or to harm stores or other '
            'users.',
        'Do not attempt to breach or disrupt the app, or to reach data that is '
            'not yours.',
        'Do not place fake orders, post misleading reviews, or pressure stores '
            'to change ratings. The platform may remove any review that '
            'breaches this.',
      ],
    ),
    LegalSection(
      title: '9. Content and intellectual property',
      paragraphs: <String>[
        'Product images and data remain the property of the stores, and the '
            'platform may use them to display products, market the platform, and '
            'run its advertising campaigns. App content may not be republished '
            'for commercial purposes without permission.',
      ],
    ),
    LegalSection(
      title: '10. Limits of liability',
      paragraphs: <String>[
        'The platform is not liable for damage arising from a defect in the '
            'manufacture or preparation of a product, for service interruptions '
            'caused by technical circumstances beyond its control, or for a '
            'user\'s failure to protect their own account. Its responsibility '
            'is limited to organising the process and handling complaints under '
            'these terms.',
      ],
    ),
    LegalSection(
      title: '11. Suspending and deleting your account',
      paragraphs: <String>[
        'You can delete your account at any time from inside the app: Account → '
            'Delete account. The account stops working immediately and your '
            'personal data is erased after thirty (30) days; order and payment '
            'records are kept as financial documents with identifying details '
            'removed. Deleting an account does not affect obligations that arose '
            'before the deletion.',
      ],
    ),
    LegalSection(
      title: '12. Changes to these terms',
      paragraphs: <String>[
        'The platform may update these terms as its services develop, and will '
            'announce changes through the approved channels inside the app. '
            'Continuing to use the app after an update means accepting the new '
            'version.',
      ],
    ),
    LegalSection(
      title: '13. Governing law and contact',
      paragraphs: <String>[
        'These terms are governed by the laws and regulations in force in '
            'Libya. For questions or complaints, write to $supportEmail '
            'or call $supportPhone.',
      ],
    ),
  ],
);
