import 'package:get/get.dart';

import '../legal/legal_content.dart' show supportEmail, supportPhone;

/// One question and its answer.
class HelpTopic {
  const HelpTopic({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// A group of related questions.
class HelpSection {
  const HelpSection({required this.title, required this.topics});

  final String title;
  final List<HelpTopic> topics;
}

/// Help centre copy for the language the app is showing.
///
/// Long-form prose kept as content rather than as flat translation keys, for
/// the same reason the policies are: answers are written and reviewed as a
/// document. Every answer here describes something the app actually does — a
/// help page that promises a feature the binary does not have is worse than no
/// help page at all.
List<HelpSection> helpSections() =>
    Get.locale?.languageCode == 'ar' ? _sectionsAr : _sectionsEn;

const List<HelpSection> _sectionsAr = <HelpSection>[
  HelpSection(
    title: 'الحساب وتسجيل الدخول',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'كيف أنشئ حسابًا؟',
        answer:
            'أدخل رقم هاتفك في شاشة الدخول، ثم أكمل اسمك وبريدك الإلكتروني إذا '
            'كان الرقم جديدًا. سنرسل لك رمز تحقق من أربعة أرقام عبر رسالة نصية، '
            'وبإدخاله يكتمل إنشاء الحساب.',
      ),
      HelpTopic(
        question: 'لم تصلني رسالة رمز التحقق',
        answer:
            'تأكد من أن الرقم صحيح ومن وجود تغطية للشبكة، ثم انتظر انتهاء العدّاد '
            'واضغط على "إعادة الإرسال". الرمز صالح لخمس دقائق، وبعد خمس محاولات '
            'خاطئة يُلغى ويلزم طلب رمز جديد.',
      ),
      HelpTopic(
        question: 'هل يمكنني التصفح بدون حساب؟',
        answer:
            'نعم. يمكنك تصفح المنتجات والمتاجر وإضافة منتجات إلى السلة كزائر. '
            'يُطلب تسجيل الدخول عند إتمام الطلب فقط، لأن الطلب يحتاج إلى عنوان '
            'توصيل ووسيلة للتواصل معك.',
      ),
      HelpTopic(
        question: 'كيف أغيّر رقم هاتفي أو بياناتي؟',
        answer:
            'تعديل بيانات الحساب يتم عبر الدعم حاليًا. راسلنا من هذه الصفحة '
            'موضحًا البيانات التي تريد تحديثها.',
      ),
      HelpTopic(
        question: 'كيف أحذف حسابي؟',
        answer:
            'من تبويب الحساب اضغط "حذف الحساب" وأكّد الطلب. يتوقف الحساب فورًا '
            'ويتم تسجيل خروجك، ثم تُحذف بياناتك الشخصية نهائيًا بعد 30 يومًا. '
            'خلال هذه المدة يمكنك مراسلة الدعم للتراجع عن الطلب.',
      ),
    ],
  ),
  HelpSection(
    title: 'الطلبات',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'كيف أتابع حالة طلبي؟',
        answer:
            'افتح الحساب ← طلباتي، ثم اختر الطلب لعرض تفاصيله ومساره. تصلك كذلك '
            'إشعارات عند تغيّر الحالة إذا كانت الإشعارات مفعّلة.',
      ),
      HelpTopic(
        question: 'ماذا تعني حالات الطلب؟',
        answer:
            'قيد التأكيد: استلمنا الطلب وبانتظار تأكيده. قيد التجهيز: المتجر '
            'يجهّز طلبك. في الطريق: الطلب مع التوصيل. جاهز للاستلام: يمكنك '
            'استلامه من المتجر. تم التوصيل: وصل الطلب. تم الإلغاء أو تم '
            'الاسترداد: انتهى الطلب دون تسليم أو أُعيد مبلغه.',
      ),
      HelpTopic(
        question: 'لماذا أصبح طلبي أكثر من طلب؟',
        answer:
            'لأن كل طلب يخص متجرًا واحدًا. إذا كانت سلتك تضم منتجات من متاجر '
            'مختلفة فسيتم إنشاء طلب منفصل لكل متجر، ولكل طلب رسوم توصيل وحالة '
            'خاصة به.',
      ),
      HelpTopic(
        question: 'هل يمكنني إلغاء الطلب؟',
        answer:
            'يمكن إلغاء الطلب ما دام قيد التأكيد ولم يبدأ تجهيزه، من صفحة تفاصيل '
            'الطلب. بعد بدء التجهيز راسل الدعم مع رقم الطلب.',
      ),
    ],
  ),
  HelpSection(
    title: 'التوصيل والعناوين',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'كيف تُحسب رسوم التوصيل؟',
        answer:
            'تُحسب حسب منطقة العنوان الذي تختاره عند إتمام الطلب، وتظهر في ملخص '
            'الطلب قبل التأكيد. بعض المتاجر تقدّم توصيلًا مجانيًا لمناطق محددة.',
      ),
      HelpTopic(
        question: 'ظهرت لي رسالة أن المتجر لا يوصّل إلى عنواني',
        answer:
            'يحدد كل متجر المناطق التي يغطيها. جرّب اختيار عنوان آخر ضمن منطقة '
            'مغطاة، أو اطلب المنتج من متجر يغطي منطقتك.',
      ),
      HelpTopic(
        question: 'كيف أضيف عنوانًا أو أحدّد موقعي على الخريطة؟',
        answer:
            'من الحساب ← عناويني ← إضافة عنوان. يمكنك تحديد الموقع على الخريطة، '
            'وعند الضغط على زر تحديد موقعي يطلب التطبيق إذن الموقع لتوسيط '
            'الخريطة على مكانك. الإذن اختياري ويمكنك إدخال العنوان يدويًا.',
      ),
    ],
  ),
  HelpSection(
    title: 'الدفع',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'ما وسائل الدفع المتاحة؟',
        answer:
            'تظهر الوسائل المتاحة في صفحة إتمام الطلب، وتشمل الدفع عند الاستلام '
            'ووسائل الدفع الإلكتروني المفعّلة. قد تختلف الخيارات حسب المتجر '
            'وقيمة الطلب.',
      ),
      HelpTopic(
        question: 'كيف يتم الدفع عبر إدفعلي؟',
        answer:
            'أدخل رقم محفظة إدفعلي عند اختيار الوسيلة، ثم أكّد العملية بالرمز '
            'الذي يصلك برسالة نصية. الرمز يُستخدم مرة واحدة، وبعد ثلاث محاولات '
            'خاطئة تفشل العملية ويُلغى الطلب.',
      ),
      HelpTopic(
        question: 'خُصم المبلغ ولم يتأكد الطلب',
        answer:
            'لا تعد المحاولة. راسل الدعم مع رقم الطلب ووقت العملية وسنتحقق من '
            'حالة الدفع لدى مزود الخدمة.',
      ),
    ],
  ),
  HelpSection(
    title: 'الاسترجاع والمبالغ المستردة',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'كيف أطلب استرجاعًا؟',
        answer:
            'من تفاصيل الطلب بعد تسليمه اضغط "طلب استرجاع"، ثم اختر المنتجات '
            'والكمية وسبب الاسترجاع وطريقة استلام المبلغ.',
      ),
      HelpTopic(
        question: 'متى يُقبل طلب الاسترجاع؟',
        answer:
            'عند وجود تلف في المنتج، أو اختلافه عن الطلب، أو عدم مطابقته للوصف، '
            'أو وجود خطأ من المتجر. إذا كان الخطأ من العميل يتحمل تكاليف النقل '
            'والاسترجاع.',
      ),
      HelpTopic(
        question: 'أين أجد إيصال التحويل؟',
        answer:
            'بعد اعتماد التحويل يظهر الإيصال داخل تفاصيل طلب الاسترجاع، ويمكنك '
            'حفظه في معرض صور جهازك.',
      ),
    ],
  ),
  HelpSection(
    title: 'التطبيق والإشعارات',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'كيف أغيّر اللغة أو المظهر؟',
        answer:
            'من تبويب الحساب ← التفضيلات، يمكنك التبديل بين العربية والإنجليزية '
            'واختيار المظهر الفاتح أو الداكن أو اتباع إعداد الجهاز.',
      ),
      HelpTopic(
        question: 'لا تصلني إشعارات الطلبات',
        answer:
            'تأكد من تفعيل إشعارات أمازونات من إعدادات جهازك. إذا كنت قد رفضت '
            'الإذن سابقًا فعّله من إعدادات النظام، ثم افتح التطبيق مرة أخرى.',
      ),
    ],
  ),
];

const List<HelpSection> _sectionsEn = <HelpSection>[
  HelpSection(
    title: 'Account and sign-in',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'How do I create an account?',
        answer:
            'Enter your phone number on the sign-in screen, then add your name '
            'and email if the number is new. We send a four-digit verification '
            'code by SMS; entering it completes the account.',
      ),
      HelpTopic(
        question: "The verification code didn't arrive",
        answer:
            'Check that the number is right and that you have signal, then wait '
            'for the countdown to finish and tap Resend. A code is valid for '
            'five minutes, and after five wrong attempts it is destroyed and a '
            'new one must be requested.',
      ),
      HelpTopic(
        question: 'Can I browse without an account?',
        answer:
            'Yes. You can browse products and stores and add items to the cart '
            'as a guest. Signing in is required only at checkout, because an '
            'order needs a delivery address and a way to reach you.',
      ),
      HelpTopic(
        question: 'How do I change my phone number or details?',
        answer:
            'Account details are changed through support for now. Write to us '
            'from this page and say what you would like updated.',
      ),
      HelpTopic(
        question: 'How do I delete my account?',
        answer:
            'On the Account tab, tap Delete account and confirm. The account '
            'stops working immediately and you are signed out; your personal '
            'data is then permanently erased after 30 days. You can contact '
            'support inside that window to reverse the request.',
      ),
    ],
  ),
  HelpSection(
    title: 'Orders',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'How do I track my order?',
        answer:
            'Open Account → My orders and select the order to see its details '
            'and progress. You also get a notification each time the status '
            'changes, if notifications are enabled.',
      ),
      HelpTopic(
        question: 'What do the order statuses mean?',
        answer:
            'Confirming: we have the order and it is awaiting confirmation. '
            'Preparing: the store is getting it ready. On the way: it is with '
            'delivery. Ready to pick up: collect it from the store. Delivered: '
            'it arrived. Cancelled or Refunded: the order ended without '
            'delivery, or its amount was returned.',
      ),
      HelpTopic(
        question: 'Why did my order become several orders?',
        answer:
            'Because one order belongs to one store. If your cart holds items '
            'from different stores, a separate order is created for each, with '
            'its own delivery fee and its own status.',
      ),
      HelpTopic(
        question: 'Can I cancel an order?',
        answer:
            'An order can be cancelled from its details page while it is still '
            'awaiting confirmation and has not been prepared. Once preparation '
            'starts, contact support with the order number.',
      ),
    ],
  ),
  HelpSection(
    title: 'Delivery and addresses',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'How is the delivery fee calculated?',
        answer:
            'By the zone of the address you choose at checkout. It appears in '
            'the order summary before you confirm. Some stores offer free '
            'delivery to particular zones.',
      ),
      HelpTopic(
        question: 'It says the store does not deliver to my address',
        answer:
            'Each store sets the areas it covers. Try another address inside a '
            'covered area, or order the item from a store that covers yours.',
      ),
      HelpTopic(
        question: 'How do I add an address or pin it on the map?',
        answer:
            'Go to Account → My addresses → Add address. You can pin the spot '
            'on the map, and tapping the locate-me button asks for location '
            'permission so the map can centre on you. The permission is '
            'optional — you can type the address instead.',
      ),
    ],
  ),
  HelpSection(
    title: 'Payment',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'Which payment methods can I use?',
        answer:
            'The available methods are shown at checkout and include pay on '
            'delivery along with the electronic methods that are enabled. The '
            'options can differ by store and by order value.',
      ),
      HelpTopic(
        question: 'How does paying with Edfali work?',
        answer:
            'Enter your Edfali wallet number when you choose the method, then '
            'confirm with the code sent to you by SMS. The code is single-use, '
            'and after three wrong attempts the payment fails and the order is '
            'cancelled.',
      ),
      HelpTopic(
        question: 'I was charged but the order was not confirmed',
        answer:
            'Do not try again. Contact support with the order number and the '
            'time of the transaction and we will check the payment status with '
            'the provider.',
      ),
    ],
  ),
  HelpSection(
    title: 'Returns and refunds',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'How do I request a refund?',
        answer:
            'Open the order after it is delivered and tap Request refund, then '
            'choose the items and quantity, the reason, and how you want to '
            'receive the amount.',
      ),
      HelpTopic(
        question: 'When is a refund accepted?',
        answer:
            'Where the product is damaged, differs from what was ordered, does '
            'not match its description, or the store made an error. If the '
            'customer is at fault they bear the transport and return costs.',
      ),
      HelpTopic(
        question: 'Where do I find the transfer receipt?',
        answer:
            'Once the transfer is approved the receipt appears inside the '
            'refund request details, and you can save it to your photo library.',
      ),
    ],
  ),
  HelpSection(
    title: 'App and notifications',
    topics: <HelpTopic>[
      HelpTopic(
        question: 'How do I change the language or appearance?',
        answer:
            'On the Account tab under Preferences you can switch between Arabic '
            'and English and choose a light or dark appearance, or follow your '
            'device setting.',
      ),
      HelpTopic(
        question: 'I am not getting order notifications',
        answer:
            'Check that notifications for Amazonat are enabled in your device '
            'settings. If you declined the permission earlier, enable it in the '
            'system settings and open the app again.',
      ),
    ],
  ),
];

/// Address the contact row writes to.
const String helpSupportEmail = supportEmail;

/// Number the contact row dials.
const String helpSupportPhone = supportPhone;
