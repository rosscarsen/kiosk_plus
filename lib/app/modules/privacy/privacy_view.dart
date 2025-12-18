import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';

import '../../translations/locale_keys.dart';
import 'privacy_controller.dart';

class PrivacyView extends GetView<PrivacyController> {
  const PrivacyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.privacy.tr), centerTitle: true),
      body: SafeArea(
        child: Markdown(
          selectable: true,
          data: '''
# 隱私政策及網站使用條款  

Privacy Policy and Website Terms of Use

## 法律聲明

「外賣 POS 點餐系統」(下稱「外賣 POS」)是由 PERICLES Technology Ltd. 開發。「外賣 POS」旨在為閣下/餐廳提供外賣點餐服務，幫助閣下完成所揀選餐廳的餐品及或送餐服務之訂購。

在此 PERICLES 提醒你: 在使用「外賣 POS」
各項服務前，請閣下務必仔細閱讀並透徹理解本用戶協議。

如果閣下使用「外賣 POS 點餐系統」 (包括但不限于手機應用程式、網站、終端)的服務,閣下的使用行為將被視為接受及同意本協議全部內容。如閣下不同意以下條款，請立即停止使用外賣 POS 點餐系統。

## 服務條款

1. 定義
   - “閣下”是指訪問「外賣 POS 點餐系統」和從「外賣 POS 點餐系統」訂購任何産品或服務的人;
   - “我們”是指「PERICLES」;
   - “餐品”是指餐廳提供給我們列出及可供訂購之産品;
   - “送餐服務”是指閣下通過我們要求餐廳的服務;
   - “餐廳”是指壹個第三者,準備及交付餐品和或送餐服務給閣下。

2. 我們並不負起控制交易所涉及的餐品和/或送餐服務的質量、安全或合法性，商貿信息的真實性或準確性，以及交易方履行其在貿易協議項下的各項義務的能力。例如:貨款的收付、發票的收發、餐品的配送、餐品送達的及時性和準確性、餐品最新種類及價格的發佈、客戶信息的準確性等。我們提醒閣下應該通過自己的謹慎判斷確定餐廳的餐品、送餐服務及相關信息的準確性。

3. 閣下從我們下的訂單是受到餐廳之供應，交付能力和餐廳接受與否的決定。訂單達成與否，最終以餐廳為準。我們將不承擔任何因遲延交貨而造成給你的損失及責任。

4. 如果閣下決定取消閣下的訂單,閣下必須立即通知相關的餐廳。不論參與餐廳接受你的取消訂單與否，請直接與相關的餐廳聯絡。

5. 如閣下以線上付款方式支付,你所付的金額會直接由相關的餐廳帳戶直接收取，本公司不涉及第三方支付交易。

6. 閣下通過「外賣 POS 點餐系統」向餐廳點餐/訂購餐品的訂單或送餐服務，由此産生的相應權利義務均由各餐廳自行負責，PERICLES 並不承擔任何及所有對餐品和/或送餐服務之供應的責任，如用戶在服務使用過程中産生糾紛，請直接與該餐廳進行溝通。

## 免責聲明

1. 「外賣 POS 點餐系統」內容是相關餐廳自行提供，僅以提供資訊為目的，不具有法律約束力。本公司已盡最大努力保證信息的準確性和及時更新,但仍不能保證信息的絕對準確無誤。

2. 我們不承擔因閣下接入或使用「外賣 POS 點餐系統」而産生的間接的、附帶的、後繼的或特殊的損失,包括但不限于因被植入病毒、木馬而影響您的計算機設備或依賴從「外賣 POS 點餐系統」獲得的信息等而遭受的損失。

3. 凡由於使用或無法使用「外賣 POS 點餐系統」或任何執行失敗、錯誤、遺漏、中斷、刪除、缺陷、操作或傳送的延誤、計算機病毒、通信線路失靈、線上通信的攔截、軟件或硬體問題(包括但不限于丢失數據或相容性問題)、偷竊、網站的破壞或改變所引起的,無論是因使用「外賣 POS 點餐系統」或向網站上載或從網站下載或出版數據、文字、圖像或其他內容或資料而直接或間接造成的違約、侵權行爲、疏忽或任何其他訴因所引起的任何種類損害或傷害(包括但不限于意外損害、間接損害、利潤的損失、或者因失去數據或業務被中斷所造成的損害)，且無論我們是否已被告知此種損害的可能性， 我們概不負任何責任。

## 隱私聲明

我們非常重視您的隱私權，因此我們將致力保護個人資料私隱及承諾遵守個人資料。在閣下使用「外賣 POS 點餐系統」獲取外賣/堂食點餐訂餐服務、或參與推廣活動之時,閣下會被要求向我們提供個人資料，當中包括但不限於姓名、電話號碼、電郵地址及/或送餐地址(下稱「個人資料」)。

1. 個人資料使用閣下的個人資料可能被 相關餐廳用於以下主要目的:
   - 確保閣下享受到餐廳外賣餐品和/或送餐服務;
   - 相關餐廳會根據閣下提供資訊/過往訂單記錄,從而提供合適的推廣活動/更優質服務;
   - 相關餐廳提供推廣産品、服務及聯營活動資訊。

2. 閣下的權利
   - 閣下有權要求查閱及更改由相關餐廳持有的個人資料，及要求相關餐廳停止再使用你個人資料作促銷用途。
   - 如對以上私隱及條款資料有疑問，請電郵至  <privacy@pericles.net>
   - 如拒收相關餐廳優惠及資訊通知，請在相關餐廳的會員中心頁面，選擇不接受優惠及推廣訊息欄。

## Legal Declaration

The 'Delivery POS Ordering System' (hereinafter referred to as' Delivery POS') is developed by PERICLES Technology Ltd. The 'Delivery POS' aims to provide you/the restaurant with a takeout ordering service, helping you complete the ordering of food and/or delivery services for the selected restaurant.

Here, PERICLES reminds you that you are using the 'Delivery POS'
Before providing various services, please carefully read and fully understand this user agreement.

If you use the "Delivery POS Ordering System" (including but not limited to mobile applications, websites, terminals), your use will be deemed to accept and agree to the entire content of this agreement. If you do not agree to the following terms, please immediately stop using the delivery POS ordering system.

### Service Terms

1. Definition
    - You "refers to the person who accesses the" Delivery POS Ordering System "and orders any products or services from the" Delivery POS Ordering System ";
    - We "refer to" PERICLES ";
    - 'Meal products' refer to the products listed and available for ordering by the restaurant;
    - 'Meal delivery service' refers to the service you request from the restaurant through us;
    - A "restaurant" refers to a third party who prepares and delivers food and/or delivery services to you.

2. We are not responsible for controlling the quality, safety, or legality of the food products and/or delivery services involved in the exchange, the authenticity or accuracy of trade information, and the ability of trading parties to fulfill their obligations under trade agreements. For example, payment and receipt of goods, receipt and delivery of invoices, delivery of food products, timeliness and accuracy of food delivery, release of the latest types and prices of food products, accuracy of customer information, etc. We remind you to use your own careful judgment to determine the accuracy of the restaurant's food, delivery services, and related information.

3. The order you place from us is determined by the restaurant's supply, delivery capacity, and acceptance. The final decision on whether the order is fulfilled or not is based on the restaurant. We will not bear any losses or responsibilities caused to you due to delayed delivery.

4. If you decide to cancel your order, you must immediately notify the relevant restaurant. Regardless of whether the participating restaurant accepts your cancellation order or not, please contact the relevant restaurant directly.

5. If you make payment online, the amount you pay will be directly collected from the relevant restaurant account, and our company does not involve third-party payment transactions.

6. You are responsible for ordering/ordering food orders or delivery services from the restaurant through the "Delivery POS Ordering System". The corresponding rights and obligations arising from this are the responsibility of each restaurant. PERICLES does not assume any and all responsibilities for the supply of food products and/or delivery services. If users have any disputes during the service use process, please directly communicate with the restaurant.

## Disclaimers

1. The content of the 'Delivery POS Ordering System' is provided by the relevant restaurant itself, solely for the purpose of providing information and not legally binding. Our company has made every effort to ensure the accuracy and timely updates of information, but we cannot guarantee the absolute accuracy of the information.

2. We do not assume any indirect, incidental, consequential, or special losses arising from your access to or use of the 'Delivery POS Dining System', including but not limited to losses incurred due to the implantation of viruses, Trojans that affect your computer equipment or reliance on information obtained from the 'Delivery POS Dining System'.

3. Any failure, error, omission, interruption, deletion, defect, delay in operation or transmission, computer virus, communication line failure, interception of online communication, software or hardware issues (including but not limited to data loss or compatibility issues), theft, website damage or changes caused by the use or inability to use the "Delivery POS Dining System", Any kind of damage or injury (including but not limited to accidental damage, indirect damage, loss of profits, or loss of data or interruption of business) caused directly or indirectly by breach of contract, infringement, negligence, or any other cause of action, whether caused by the use of the "takeout POS ordering system" or the uploading, downloading, or publishing of data, text, images, or other content or data to or from the website

We are not responsible for any damage caused, regardless of whether we have been informed of the possibility of such damage.

### Privacy Statement

We attach great importance to your privacy rights, so we will strive to protect the privacy of personal data and promise to comply with personal data. When you use the "Delivery POS Ordering System" to obtain delivery/on-site ordering services or participate in promotional activities, you will be required to provide us with personal information, including but not limited to name, phone number, email address, and/or delivery address (hereinafter referred to as "personal information").

1. Personal data usage
   Your personal information may be used by relevant restaurants for the following main purposes:
    - Ensure that you enjoy restaurant takeout and/or delivery services;
    - The relevant restaurants will provide appropriate promotional activities/higher quality services based on your     provided information/past order records;
    - Related restaurants provide promotional products, services, and joint venture activity information.

2. Your Rights
    - You have the right to request access to and modification of personal data held by relevant restaurants, and to request that relevant restaurants stop using your personal data for promotional purposes.
    - If you have any questions about the above privacy and terms data, please email to <privacy@pericles.net>
    - If you refuse to accept discounts and information notifications from relevant restaurants, please choose not to accept discounts and promotional information on the member center page of the relevant restaurant.

        ''',
        ),
      ),
    );
  }
}
