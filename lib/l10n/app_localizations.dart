import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'FabriSCAN+'**
  String get appTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Know your fabric. Care for it right.'**
  String get splashTagline;

  /// No description provided for @splashCredit.
  ///
  /// In en, this message translates to:
  /// **'A thesis project · DMMSU Mid-La Union Campus'**
  String get splashCredit;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onbBack;

  /// No description provided for @onbGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbGetStarted;

  /// No description provided for @onb1Title.
  ///
  /// In en, this message translates to:
  /// **'Scan any fabric'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a garment. FabriSCAN+ tells you the likely fabric and what it is made of.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In en, this message translates to:
  /// **'Get a care guide'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step washing, drying, ironing, stain removal and storage, with sources you can check.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In en, this message translates to:
  /// **'Keep your history'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In en, this message translates to:
  /// **'Every scan is saved on your phone. No account needed. Sign up later if you want it on other phones too.'**
  String get onb3Body;

  /// No description provided for @onbStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onbStep(int current, int total);

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Start scanning'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'No account needed. Your scans stay on this phone.'**
  String get welcomeBody;

  /// No description provided for @welcomeGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get welcomeGuest;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get welcomeLogin;

  /// No description provided for @welcomeSignup.
  ///
  /// In en, this message translates to:
  /// **'Create a free account'**
  String get welcomeSignup;

  /// No description provided for @welcomeNote.
  ///
  /// In en, this message translates to:
  /// **'An account only adds history on other phones. Everything else works without one.'**
  String get welcomeNote;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get navBrowse;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan fabric'**
  String get navScan;

  /// No description provided for @comingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts come in a later test build. Everything works as a guest.'**
  String get comingAccounts;

  /// No description provided for @greetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetMorning;

  /// No description provided for @greetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetAfternoon;

  /// No description provided for @greetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetEvening;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'What fabric is this?'**
  String get homeTitle;

  /// No description provided for @homeHelp.
  ///
  /// In en, this message translates to:
  /// **'Help and photo tips'**
  String get homeHelp;

  /// No description provided for @homeScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan fabric'**
  String get homeScanTitle;

  /// No description provided for @homeScanBody.
  ///
  /// In en, this message translates to:
  /// **'Point, snap, and get care steps'**
  String get homeScanBody;

  /// No description provided for @homeUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo'**
  String get homeUpload;

  /// No description provided for @homeFabricCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 fabric} other{{count} fabrics}}'**
  String homeFabricCount(int count);

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent scans'**
  String get homeRecent;

  /// No description provided for @homeRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your scans will show up here.'**
  String get homeRecentEmpty;

  /// No description provided for @homeTipLabel.
  ///
  /// In en, this message translates to:
  /// **'Care tip of the day'**
  String get homeTipLabel;

  /// No description provided for @homeTipSample.
  ///
  /// In en, this message translates to:
  /// **'Air your barong in the shade after wearing it. Sweat left in piña turns it yellow over time.'**
  String get homeTipSample;

  /// No description provided for @sampleContent.
  ///
  /// In en, this message translates to:
  /// **'Sample content: to be written by researchers'**
  String get sampleContent;

  /// No description provided for @sampleTip.
  ///
  /// In en, this message translates to:
  /// **'Sample tip'**
  String get sampleTip;

  /// No description provided for @sampleDescription.
  ///
  /// In en, this message translates to:
  /// **'Sample description: researchers to confirm'**
  String get sampleDescription;

  /// No description provided for @sampleCitations.
  ///
  /// In en, this message translates to:
  /// **'Sample citations: researchers to add APA 7 references'**
  String get sampleCitations;

  /// No description provided for @browseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse fabrics'**
  String get browseTitle;

  /// No description provided for @browseSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fabrics, e.g. piña'**
  String get browseSearchHint;

  /// No description provided for @browseCategoryLine.
  ///
  /// In en, this message translates to:
  /// **'{count} · {description}'**
  String browseCategoryLine(String count, String description);

  /// No description provided for @browseOffline.
  ///
  /// In en, this message translates to:
  /// **'Works without internet · {count} fabrics in the catalog'**
  String browseOffline(int count);

  /// No description provided for @categoryIntro.
  ///
  /// In en, this message translates to:
  /// **'{description} {count}.'**
  String categoryIntro(String description, String count);

  /// No description provided for @alsoIn.
  ///
  /// In en, this message translates to:
  /// **'Also in {categories}'**
  String alsoIn(String categories);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search fabrics'**
  String get searchHint;

  /// No description provided for @searchTypeMore.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 letters, e.g. \"pi\" for Piña.'**
  String get searchTypeMore;

  /// No description provided for @searchNone.
  ///
  /// In en, this message translates to:
  /// **'No fabric matches \"{query}\".'**
  String searchNone(String query);

  /// No description provided for @searchNoneHint.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling, or browse by category.'**
  String get searchNoneHint;

  /// No description provided for @fabricAlsoCalled.
  ///
  /// In en, this message translates to:
  /// **'Also called {names}'**
  String fabricAlsoCalled(String names);

  /// No description provided for @fabricMadeOf.
  ///
  /// In en, this message translates to:
  /// **'What it\'s made of'**
  String get fabricMadeOf;

  /// No description provided for @fabricRecognize.
  ///
  /// In en, this message translates to:
  /// **'How to recognize it'**
  String get fabricRecognize;

  /// No description provided for @fabricCareGuide.
  ///
  /// In en, this message translates to:
  /// **'Care guide'**
  String get fabricCareGuide;

  /// No description provided for @fabricOpenCare.
  ///
  /// In en, this message translates to:
  /// **'Open care guide'**
  String get fabricOpenCare;

  /// No description provided for @fiberNatural.
  ///
  /// In en, this message translates to:
  /// **'natural'**
  String get fiberNatural;

  /// No description provided for @fiberSynthetic.
  ///
  /// In en, this message translates to:
  /// **'synthetic'**
  String get fiberSynthetic;

  /// No description provided for @fiberBlend.
  ///
  /// In en, this message translates to:
  /// **'blend'**
  String get fiberBlend;

  /// No description provided for @fiberHintTitle.
  ///
  /// In en, this message translates to:
  /// **'Check the garment label to confirm fiber.'**
  String get fiberHintTitle;

  /// No description provided for @fiberHintBody.
  ///
  /// In en, this message translates to:
  /// **'{fabric} can be made of {fibers}. A photo can\'t always tell them apart.'**
  String fiberHintBody(String fabric, String fibers);

  /// No description provided for @fiberOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get fiberOr;

  /// No description provided for @careTitle.
  ///
  /// In en, this message translates to:
  /// **'Care guide'**
  String get careTitle;

  /// No description provided for @careEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CARE GUIDE'**
  String get careEyebrow;

  /// No description provided for @careDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is general guidance. Always follow the garment\'s care label if it differs.'**
  String get careDisclaimer;

  /// No description provided for @careDelicateNote.
  ///
  /// In en, this message translates to:
  /// **'Steps below are safe for the most delicate version ({fiber}). Check the garment label to confirm fiber.'**
  String careDelicateNote(String fiber);

  /// No description provided for @careWashing.
  ///
  /// In en, this message translates to:
  /// **'Washing'**
  String get careWashing;

  /// No description provided for @careDrying.
  ///
  /// In en, this message translates to:
  /// **'Drying'**
  String get careDrying;

  /// No description provided for @careIroning.
  ///
  /// In en, this message translates to:
  /// **'Ironing'**
  String get careIroning;

  /// No description provided for @careStain.
  ///
  /// In en, this message translates to:
  /// **'Stain removal'**
  String get careStain;

  /// No description provided for @careStainShort.
  ///
  /// In en, this message translates to:
  /// **'Stains'**
  String get careStainShort;

  /// No description provided for @careStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get careStorage;

  /// No description provided for @careSteps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String careSteps(int count);

  /// No description provided for @carePickStain.
  ///
  /// In en, this message translates to:
  /// **'Pick a stain type'**
  String get carePickStain;

  /// No description provided for @careStainGroup.
  ///
  /// In en, this message translates to:
  /// **'Stain type'**
  String get careStainGroup;

  /// No description provided for @careTestFirst.
  ///
  /// In en, this message translates to:
  /// **'On delicate or heritage fabric, test first on a hidden seam. If unsure, take it to a trusted dry cleaner.'**
  String get careTestFirst;

  /// No description provided for @careNoIron.
  ///
  /// In en, this message translates to:
  /// **'No iron'**
  String get careNoIron;

  /// No description provided for @careIronDots.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dot} other{{count} dots}}'**
  String careIronDots(int count);

  /// No description provided for @careIronLabel.
  ///
  /// In en, this message translates to:
  /// **'Iron setting: {setting}'**
  String careIronLabel(String setting);

  /// No description provided for @careSources.
  ///
  /// In en, this message translates to:
  /// **'Sources ({count})'**
  String careSources(int count);

  /// No description provided for @careAllSources.
  ///
  /// In en, this message translates to:
  /// **'All sources'**
  String get careAllSources;

  /// No description provided for @careSourcesFor.
  ///
  /// In en, this message translates to:
  /// **'Sources · {section}'**
  String careSourcesFor(String section);

  /// No description provided for @careEcoTitle.
  ///
  /// In en, this message translates to:
  /// **'Garment life extended'**
  String get careEcoTitle;

  /// No description provided for @careEcoBody.
  ///
  /// In en, this message translates to:
  /// **'Caring for clothes the right way keeps them wearable for longer and out of landfills. (SDG 12)'**
  String get careEcoBody;

  /// No description provided for @careSectionsNav.
  ///
  /// In en, this message translates to:
  /// **'Care sections'**
  String get careSectionsNav;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Scan a fabric and it will be saved here, so you can find its care guide again.'**
  String get historyEmptyBody;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @profileGuestScans.
  ///
  /// In en, this message translates to:
  /// **'Scans are saved on this phone'**
  String get profileGuestScans;

  /// No description provided for @profileGuestBody.
  ///
  /// In en, this message translates to:
  /// **'Create a free account to keep your history on any phone. Optional.'**
  String get profileGuestBody;

  /// No description provided for @profileSignup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get profileSignup;

  /// No description provided for @profileLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get profileLogin;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get profileAppearance;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @profileHelpInfo.
  ///
  /// In en, this message translates to:
  /// **'HELP & INFO'**
  String get profileHelpInfo;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & photo tips'**
  String get profileHelp;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About & privacy'**
  String get profileAbout;

  /// No description provided for @profileSurvey.
  ///
  /// In en, this message translates to:
  /// **'Take the survey'**
  String get profileSurvey;

  /// No description provided for @profileSurveySub.
  ///
  /// In en, this message translates to:
  /// **'Help the researchers · opens in your browser'**
  String get profileSurveySub;

  /// No description provided for @profileFooter.
  ///
  /// In en, this message translates to:
  /// **'FabriSCAN+ {version} · Free, no ads, no in-app purchases'**
  String profileFooter(String version);

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & photo tips'**
  String get helpTitle;

  /// No description provided for @helpGoodScan.
  ///
  /// In en, this message translates to:
  /// **'For a good scan'**
  String get helpGoodScan;

  /// No description provided for @tipLight.
  ///
  /// In en, this message translates to:
  /// **'Use good natural light'**
  String get tipLight;

  /// No description provided for @tipFlash.
  ///
  /// In en, this message translates to:
  /// **'Avoid flash glare'**
  String get tipFlash;

  /// No description provided for @tipFill.
  ///
  /// In en, this message translates to:
  /// **'Fill the frame with flat fabric'**
  String get tipFill;

  /// No description provided for @tipDistance.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone 10–15 cm away'**
  String get tipDistance;

  /// No description provided for @tipFocus.
  ///
  /// In en, this message translates to:
  /// **'Keep the photo in focus'**
  String get tipFocus;

  /// No description provided for @tipLayer.
  ///
  /// In en, this message translates to:
  /// **'Use a single layer of fabric'**
  String get tipLayer;

  /// No description provided for @helpScanTitle.
  ///
  /// In en, this message translates to:
  /// **'How to scan a fabric'**
  String get helpScanTitle;

  /// No description provided for @helpScan1.
  ///
  /// In en, this message translates to:
  /// **'On Home, tap Scan fabric.'**
  String get helpScan1;

  /// No description provided for @helpScan2.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone 10–15 cm from a flat part of the garment.'**
  String get helpScan2;

  /// No description provided for @helpScan3.
  ///
  /// In en, this message translates to:
  /// **'Line up the fabric inside the frame and tap the round button.'**
  String get helpScan3;

  /// No description provided for @helpScan4.
  ///
  /// In en, this message translates to:
  /// **'Tap Use photo, or Retake if it is blurry.'**
  String get helpScan4;

  /// No description provided for @helpScan5.
  ///
  /// In en, this message translates to:
  /// **'Read the result, then tap View care guide.'**
  String get helpScan5;

  /// No description provided for @helpBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'How to browse without scanning'**
  String get helpBrowseTitle;

  /// No description provided for @helpBrowse1.
  ///
  /// In en, this message translates to:
  /// **'Tap Browse in the bottom bar.'**
  String get helpBrowse1;

  /// No description provided for @helpBrowse2.
  ///
  /// In en, this message translates to:
  /// **'Pick a category, such as Barong.'**
  String get helpBrowse2;

  /// No description provided for @helpBrowse3.
  ///
  /// In en, this message translates to:
  /// **'Pick a fabric to see what it is made of and how to care for it.'**
  String get helpBrowse3;

  /// No description provided for @helpHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use History'**
  String get helpHistoryTitle;

  /// No description provided for @helpHistory1.
  ///
  /// In en, this message translates to:
  /// **'Tap History in the bottom bar.'**
  String get helpHistory1;

  /// No description provided for @helpHistory2.
  ///
  /// In en, this message translates to:
  /// **'Tap a scan to open its result and care guide again.'**
  String get helpHistory2;

  /// No description provided for @helpHistory3.
  ///
  /// In en, this message translates to:
  /// **'Tap the bin icon to delete a scan.'**
  String get helpHistory3;

  /// No description provided for @helpManual.
  ///
  /// In en, this message translates to:
  /// **'These steps match the FabriSCAN+ user\'s manual.'**
  String get helpManual;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About & privacy'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutStudy.
  ///
  /// In en, this message translates to:
  /// **'THE STUDY'**
  String get aboutStudy;

  /// No description provided for @aboutStudyTitle.
  ///
  /// In en, this message translates to:
  /// **'FabriSCAN+: Development of Textile Care Through Smart Mobile Application for Fabric Identification and Garment Maintenance'**
  String get aboutStudyTitle;

  /// No description provided for @aboutUniversity.
  ///
  /// In en, this message translates to:
  /// **'BS Textile and Fashion Technology · College of Technology · Don Mariano Marcos Memorial State University, Mid-La Union Campus, San Fernando, La Union · 2026'**
  String get aboutUniversity;

  /// No description provided for @aboutResearchers.
  ///
  /// In en, this message translates to:
  /// **'Researchers: 8 student researchers.'**
  String get aboutResearchers;

  /// No description provided for @aboutResearchersSample.
  ///
  /// In en, this message translates to:
  /// **'Researcher names: to be supplied'**
  String get aboutResearchersSample;

  /// No description provided for @aboutSdgTitle.
  ///
  /// In en, this message translates to:
  /// **'SDG 12 · Responsible consumption'**
  String get aboutSdgTitle;

  /// No description provided for @aboutSdgBody.
  ///
  /// In en, this message translates to:
  /// **'Knowing your fabric helps you care for it right, so garments last longer and less clothing ends up as waste.'**
  String get aboutSdgBody;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get aboutPrivacy;

  /// No description provided for @privacyGuest.
  ///
  /// In en, this message translates to:
  /// **'Guests: your photos and history never leave this phone.'**
  String get privacyGuest;

  /// No description provided for @privacyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Full photos are used once to find a match, then discarded. Only a small thumbnail is kept.'**
  String get privacyPhoto;

  /// No description provided for @privacyAccount.
  ///
  /// In en, this message translates to:
  /// **'With an account, your email and scan history (thumbnails only) are stored so you can sync. Nothing else.'**
  String get privacyAccount;

  /// No description provided for @privacyNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads, no tracking, no location.'**
  String get privacyNoAds;

  /// No description provided for @privacyDelete.
  ///
  /// In en, this message translates to:
  /// **'You can clear your history or delete your account anytime in Profile.'**
  String get privacyDelete;

  /// No description provided for @privacyLaw.
  ///
  /// In en, this message translates to:
  /// **'In line with the Data Privacy Act of 2012 (RA 10173).'**
  String get privacyLaw;

  /// No description provided for @aboutCareInfo.
  ///
  /// In en, this message translates to:
  /// **'Care information'**
  String get aboutCareInfo;

  /// No description provided for @aboutCareInfoBody.
  ///
  /// In en, this message translates to:
  /// **'Care guides are written and checked by the researchers, with sources for every section. They are general guidance. Always follow the garment\'s care label if it differs.'**
  String get aboutCareInfoBody;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get aboutApp;

  /// No description provided for @aboutScanner.
  ///
  /// In en, this message translates to:
  /// **'Fabric scanner'**
  String get aboutScanner;

  /// No description provided for @aboutScannerNone.
  ///
  /// In en, this message translates to:
  /// **'Not installed yet'**
  String get aboutScannerNone;

  /// No description provided for @aboutContent.
  ///
  /// In en, this message translates to:
  /// **'Fabric content'**
  String get aboutContent;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the fabric list. Please restart the app.'**
  String get errorLoading;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'This fabric isn\'t in the catalog.'**
  String get notFound;

  /// No description provided for @permTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access'**
  String get permTitle;

  /// No description provided for @permBody.
  ///
  /// In en, this message translates to:
  /// **'FabriSCAN+ uses the camera only to take a photo of your fabric. The photo stays on your phone.'**
  String get permBody;

  /// No description provided for @permAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow camera'**
  String get permAllow;

  /// No description provided for @permUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo instead'**
  String get permUpload;

  /// No description provided for @permDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera is turned off'**
  String get permDeniedTitle;

  /// No description provided for @permDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'To scan with the camera, turn it on in your phone\'s Settings: Apps → FabriSCAN+ → Permissions → Camera.'**
  String get permDeniedBody;

  /// No description provided for @permOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permOpenSettings;

  /// No description provided for @camClose.
  ///
  /// In en, this message translates to:
  /// **'Close camera'**
  String get camClose;

  /// No description provided for @camShutter.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get camShutter;

  /// No description provided for @camGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get camGallery;

  /// No description provided for @camTips.
  ///
  /// In en, this message translates to:
  /// **'Photo tips'**
  String get camTips;

  /// No description provided for @camTip1.
  ///
  /// In en, this message translates to:
  /// **'Fill the frame with fabric'**
  String get camTip1;

  /// No description provided for @camTip2.
  ///
  /// In en, this message translates to:
  /// **'Move closer · 10–15 cm'**
  String get camTip2;

  /// No description provided for @camTip3.
  ///
  /// In en, this message translates to:
  /// **'Avoid flash glare'**
  String get camTip3;

  /// No description provided for @camTip4.
  ///
  /// In en, this message translates to:
  /// **'Hold steady'**
  String get camTip4;

  /// No description provided for @camError.
  ///
  /// In en, this message translates to:
  /// **'The camera couldn\'t start. You can upload a photo instead.'**
  String get camError;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your photo'**
  String get reviewTitle;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Is the fabric sharp and filling the frame?'**
  String get reviewHint;

  /// No description provided for @reviewRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get reviewRetake;

  /// No description provided for @reviewUse.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get reviewUse;

  /// No description provided for @photoUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open this photo. Try another.'**
  String get photoUnreadable;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Looking at the weave…'**
  String get analyzingTitle;

  /// No description provided for @analyzing1.
  ///
  /// In en, this message translates to:
  /// **'Checking texture and sheen'**
  String get analyzing1;

  /// No description provided for @analyzing2.
  ///
  /// In en, this message translates to:
  /// **'Comparing with {count} fabrics'**
  String analyzing2(int count);

  /// No description provided for @analyzing3.
  ///
  /// In en, this message translates to:
  /// **'Almost done'**
  String get analyzing3;

  /// No description provided for @analyzingError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while checking the photo.'**
  String get analyzingError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultTitle;

  /// No description provided for @yourPhoto.
  ///
  /// In en, this message translates to:
  /// **'Your photo'**
  String get yourPhoto;

  /// No description provided for @scannedNow.
  ///
  /// In en, this message translates to:
  /// **'Scanned just now'**
  String get scannedNow;

  /// No description provided for @confHigh.
  ///
  /// In en, this message translates to:
  /// **'High match'**
  String get confHigh;

  /// No description provided for @confPossible.
  ///
  /// In en, this message translates to:
  /// **'Possible match'**
  String get confPossible;

  /// No description provided for @confNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get confNotSure;

  /// No description provided for @checkOnGarment.
  ///
  /// In en, this message translates to:
  /// **'Check these on your garment'**
  String get checkOnGarment;

  /// No description provided for @viewCareGuide.
  ///
  /// In en, this message translates to:
  /// **'View care guide'**
  String get viewCareGuide;

  /// No description provided for @notRight.
  ///
  /// In en, this message translates to:
  /// **'Not right? See other possible matches'**
  String get notRight;

  /// No description provided for @savedLikely.
  ///
  /// In en, this message translates to:
  /// **'Saved to History · This is a likely match, not a lab test.'**
  String get savedLikely;

  /// No description provided for @otherMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Other possible matches'**
  String get otherMatchesTitle;

  /// No description provided for @otherMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'If {fabric} doesn\'t look right, compare these. Tap one to see its care guide.'**
  String otherMatchesBody(String fabric);

  /// No description provided for @savedAs.
  ///
  /// In en, this message translates to:
  /// **'Saved {fabric} to History'**
  String savedAs(String fabric);

  /// No description provided for @couldBeTitle.
  ///
  /// In en, this message translates to:
  /// **'This could be…'**
  String get couldBeTitle;

  /// No description provided for @couldBeBody.
  ///
  /// In en, this message translates to:
  /// **'These fabrics look alike. Compare the details with your garment and pick the one that matches.'**
  String get couldBeBody;

  /// No description provided for @couldBeTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: hold the garment up to the light and compare how see-through and stiff it is.'**
  String get couldBeTip;

  /// No description provided for @optionN.
  ///
  /// In en, this message translates to:
  /// **'Option {n}'**
  String optionN(int n);

  /// No description provided for @thisOne.
  ///
  /// In en, this message translates to:
  /// **'This one · View care guide'**
  String get thisOne;

  /// No description provided for @noneOfThese.
  ///
  /// In en, this message translates to:
  /// **'None of these?'**
  String get noneOfThese;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @pickedSaved.
  ///
  /// In en, this message translates to:
  /// **'The fabric you pick is saved to History.'**
  String get pickedSaved;

  /// No description provided for @cantTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t identify this fabric'**
  String get cantTitle;

  /// No description provided for @cantBody.
  ///
  /// In en, this message translates to:
  /// **'The photo may be blurry or too dark, or it may not be a fabric FabriSCAN+ knows yet.'**
  String get cantBody;

  /// No description provided for @cantTips.
  ///
  /// In en, this message translates to:
  /// **'Try again with these tips'**
  String get cantTips;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get retakePhoto;

  /// No description provided for @browseFabrics.
  ///
  /// In en, this message translates to:
  /// **'Browse fabrics'**
  String get browseFabrics;

  /// No description provided for @scopeNote.
  ///
  /// In en, this message translates to:
  /// **'FabriSCAN+ covers modern dress fabrics in {categories}.'**
  String scopeNote(String categories);

  /// No description provided for @nothingSaved.
  ///
  /// In en, this message translates to:
  /// **'Nothing was saved to History.'**
  String get nothingSaved;

  /// No description provided for @historyOnPhone.
  ///
  /// In en, this message translates to:
  /// **'On this phone'**
  String get historyOnPhone;

  /// No description provided for @historyFooter.
  ///
  /// In en, this message translates to:
  /// **'Newest first · Tap a scan to see its care guide'**
  String get historyFooter;

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {fabric} scan'**
  String historyDelete(String fabric);

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this scan?'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In en, this message translates to:
  /// **'{fabric} from {when} will be removed from History. This can\'t be undone.'**
  String deleteBody(String fabric, String when);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Scan deleted'**
  String get deleted;

  /// No description provided for @savedScan.
  ///
  /// In en, this message translates to:
  /// **'Saved scan'**
  String get savedScan;

  /// No description provided for @sourceCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get sourceCamera;

  /// No description provided for @sourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get sourceGallery;

  /// No description provided for @aboutFabric.
  ///
  /// In en, this message translates to:
  /// **'About {fabric}'**
  String aboutFabric(String fabric);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String today(String time);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String yesterday(String time);

  /// No description provided for @todayShort.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayShort;

  /// No description provided for @yesterdayShort.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayShort;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @profileData.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get profileData;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all history'**
  String get clearAll;

  /// No description provided for @clearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all history?'**
  String get clearAllTitle;

  /// No description provided for @clearAllBody.
  ///
  /// In en, this message translates to:
  /// **'All {count} saved scans and their photos will be removed from this phone. This can\'t be undone.'**
  String clearAllBody(int count);

  /// No description provided for @clearAllYes.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllYes;

  /// No description provided for @cleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get cleared;

  /// No description provided for @profileScanCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No scans saved yet} =1{1 scan saved on this phone} other{{count} scans saved on this phone}}'**
  String profileScanCount(int count);

  /// No description provided for @testScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'TEST BUILD · SCANNER'**
  String get testScannerTitle;

  /// No description provided for @testScannerBody.
  ///
  /// In en, this message translates to:
  /// **'There is no trained scanner yet. Choose which result the test scanner gives, to try every screen.'**
  String get testScannerBody;

  /// No description provided for @testCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get testCycle;

  /// No description provided for @testA.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get testA;

  /// No description provided for @testB.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get testB;

  /// No description provided for @testC.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get testC;

  /// No description provided for @testScannerBanner.
  ///
  /// In en, this message translates to:
  /// **'Test scanner: results are examples, not a real identification.'**
  String get testScannerBanner;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
