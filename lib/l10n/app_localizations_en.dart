// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FabriSCAN+';

  @override
  String get splashTagline => 'Know your fabric. Care for it right.';

  @override
  String get splashCredit => 'A thesis project · DMMSU Mid-La Union Campus';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get onbBack => 'Back';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String get onb1Title => 'Scan any fabric';

  @override
  String get onb1Body =>
      'Point your camera at a garment. FabriSCAN+ tells you the likely fabric and what it is made of.';

  @override
  String get onb2Title => 'Get a care guide';

  @override
  String get onb2Body =>
      'Step-by-step washing, drying, ironing, stain removal and storage, with sources you can check.';

  @override
  String get onb3Title => 'Keep your history';

  @override
  String get onb3Body =>
      'Every scan is saved on your phone. No account needed. Sign up later if you want it on other phones too.';

  @override
  String onbStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get welcomeTitle => 'Start scanning';

  @override
  String get welcomeBody => 'No account needed. Your scans stay on this phone.';

  @override
  String get welcomeGuest => 'Continue as Guest';

  @override
  String get welcomeLogin => 'Log in';

  @override
  String get welcomeSignup => 'Create a free account';

  @override
  String get welcomeNote =>
      'An account only adds history on other phones. Everything else works without one.';

  @override
  String get navHome => 'Home';

  @override
  String get navBrowse => 'Browse';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get navScan => 'Scan fabric';

  @override
  String get comingAccounts =>
      'Accounts come in a later test build. Everything works as a guest.';

  @override
  String get greetMorning => 'Good morning';

  @override
  String get greetAfternoon => 'Good afternoon';

  @override
  String get greetEvening => 'Good evening';

  @override
  String get homeTitle => 'What fabric is this?';

  @override
  String get homeHelp => 'Help and photo tips';

  @override
  String get homeScanTitle => 'Scan fabric';

  @override
  String get homeScanBody => 'Point, snap, and get care steps';

  @override
  String get homeUpload => 'Upload a photo';

  @override
  String homeFabricCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fabrics',
      one: '1 fabric',
    );
    return '$_temp0';
  }

  @override
  String get homeRecent => 'Recent scans';

  @override
  String get homeRecentEmpty => 'Your scans will show up here.';

  @override
  String get homeTipLabel => 'Care tip of the day';

  @override
  String get homeTipSample =>
      'Air your barong in the shade after wearing it. Sweat left in piña turns it yellow over time.';

  @override
  String get sampleContent => 'Sample content: to be written by researchers';

  @override
  String get sampleTip => 'Sample tip';

  @override
  String get sampleDescription => 'Sample description: researchers to confirm';

  @override
  String get sampleCitations =>
      'Sample citations: researchers to add APA 7 references';

  @override
  String get browseTitle => 'Browse fabrics';

  @override
  String get browseSearchHint => 'Search fabrics, e.g. piña';

  @override
  String browseCategoryLine(String count, String description) {
    return '$count · $description';
  }

  @override
  String browseOffline(int count) {
    return 'Works without internet · $count fabrics in the catalog';
  }

  @override
  String categoryIntro(String description, String count) {
    return '$description $count.';
  }

  @override
  String alsoIn(String categories) {
    return 'Also in $categories';
  }

  @override
  String get searchHint => 'Search fabrics';

  @override
  String get searchTypeMore => 'Type at least 2 letters, e.g. \"pi\" for Piña.';

  @override
  String searchNone(String query) {
    return 'No fabric matches \"$query\".';
  }

  @override
  String get searchNoneHint => 'Check the spelling, or browse by category.';

  @override
  String fabricAlsoCalled(String names) {
    return 'Also called $names';
  }

  @override
  String get fabricMadeOf => 'What it\'s made of';

  @override
  String get fabricRecognize => 'How to recognize it';

  @override
  String get fabricCareGuide => 'Care guide';

  @override
  String get fabricOpenCare => 'Open care guide';

  @override
  String get fiberNatural => 'natural';

  @override
  String get fiberSynthetic => 'synthetic';

  @override
  String get fiberBlend => 'blend';

  @override
  String get fiberHintTitle => 'Check the garment label to confirm fiber.';

  @override
  String fiberHintBody(String fabric, String fibers) {
    return '$fabric can be made of $fibers. A photo can\'t always tell them apart.';
  }

  @override
  String get fiberOr => 'or';

  @override
  String get careTitle => 'Care guide';

  @override
  String get careEyebrow => 'CARE GUIDE';

  @override
  String get careDisclaimer =>
      'This is general guidance. Always follow the garment\'s care label if it differs.';

  @override
  String careDelicateNote(String fiber) {
    return 'Steps below are safe for the most delicate version ($fiber). Check the garment label to confirm fiber.';
  }

  @override
  String get careWashing => 'Washing';

  @override
  String get careDrying => 'Drying';

  @override
  String get careIroning => 'Ironing';

  @override
  String get careStain => 'Stain removal';

  @override
  String get careStainShort => 'Stains';

  @override
  String get careStorage => 'Storage';

  @override
  String careSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get carePickStain => 'Pick a stain type';

  @override
  String get careStainGroup => 'Stain type';

  @override
  String get careTestFirst =>
      'On delicate or heritage fabric, test first on a hidden seam. If unsure, take it to a trusted dry cleaner.';

  @override
  String get careNoIron => 'No iron';

  @override
  String careIronDots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dots',
      one: '1 dot',
    );
    return '$_temp0';
  }

  @override
  String careIronLabel(String setting) {
    return 'Iron setting: $setting';
  }

  @override
  String careSources(int count) {
    return 'Sources ($count)';
  }

  @override
  String get careAllSources => 'All sources';

  @override
  String careSourcesFor(String section) {
    return 'Sources · $section';
  }

  @override
  String get careEcoTitle => 'Garment life extended';

  @override
  String get careEcoBody =>
      'Caring for clothes the right way keeps them wearable for longer and out of landfills. (SDG 12)';

  @override
  String get careSectionsNav => 'Care sections';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmptyTitle => 'No scans yet';

  @override
  String get historyEmptyBody =>
      'Scan a fabric and it will be saved here, so you can find its care guide again.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileGuest => 'Guest';

  @override
  String get profileGuestScans => 'Scans are saved on this phone';

  @override
  String get profileGuestBody =>
      'Create a free account to keep your history on any phone. Optional.';

  @override
  String get profileSignup => 'Sign up';

  @override
  String get profileLogin => 'Log in';

  @override
  String get profileAppearance => 'APPEARANCE';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get profileHelpInfo => 'HELP & INFO';

  @override
  String get profileHelp => 'Help & photo tips';

  @override
  String get profileAbout => 'About & privacy';

  @override
  String get profileSurvey => 'Take the survey';

  @override
  String get profileSurveySub => 'Help the researchers · opens in your browser';

  @override
  String profileFooter(String version) {
    return 'FabriSCAN+ $version · Free, no ads, no in-app purchases';
  }

  @override
  String get helpTitle => 'Help & photo tips';

  @override
  String get helpGoodScan => 'For a good scan';

  @override
  String get tipLight => 'Use good natural light';

  @override
  String get tipFlash => 'Avoid flash glare';

  @override
  String get tipFill => 'Fill the frame with flat fabric';

  @override
  String get tipDistance => 'Hold the phone 10–15 cm away';

  @override
  String get tipFocus => 'Keep the photo in focus';

  @override
  String get tipLayer => 'Use a single layer of fabric';

  @override
  String get helpScanTitle => 'How to scan a fabric';

  @override
  String get helpScan1 => 'On Home, tap Scan fabric.';

  @override
  String get helpScan2 =>
      'Hold the phone 10–15 cm from a flat part of the garment.';

  @override
  String get helpScan3 =>
      'Line up the fabric inside the frame and tap the round button.';

  @override
  String get helpScan4 => 'Tap Use photo, or Retake if it is blurry.';

  @override
  String get helpScan5 => 'Read the result, then tap View care guide.';

  @override
  String get helpBrowseTitle => 'How to browse without scanning';

  @override
  String get helpBrowse1 => 'Tap Browse in the bottom bar.';

  @override
  String get helpBrowse2 => 'Pick a category, such as Barong.';

  @override
  String get helpBrowse3 =>
      'Pick a fabric to see what it is made of and how to care for it.';

  @override
  String get helpHistoryTitle => 'How to use History';

  @override
  String get helpHistory1 => 'Tap History in the bottom bar.';

  @override
  String get helpHistory2 =>
      'Tap a scan to open its result and care guide again.';

  @override
  String get helpHistory3 => 'Tap the bin icon to delete a scan.';

  @override
  String get helpManual => 'These steps match the FabriSCAN+ user\'s manual.';

  @override
  String get aboutTitle => 'About & privacy';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutStudy => 'THE STUDY';

  @override
  String get aboutStudyTitle =>
      'FabriSCAN+: Development of Textile Care Through Smart Mobile Application for Fabric Identification and Garment Maintenance';

  @override
  String get aboutUniversity =>
      'BS Textile and Fashion Technology · College of Technology · Don Mariano Marcos Memorial State University, Mid-La Union Campus, San Fernando, La Union · 2026';

  @override
  String get aboutResearchers => 'Researchers: 8 student researchers.';

  @override
  String get aboutResearchersSample => 'Researcher names: to be supplied';

  @override
  String get aboutSdgTitle => 'SDG 12 · Responsible consumption';

  @override
  String get aboutSdgBody =>
      'Knowing your fabric helps you care for it right, so garments last longer and less clothing ends up as waste.';

  @override
  String get aboutPrivacy => 'Your privacy';

  @override
  String get privacyGuest =>
      'Guests: your photos and history never leave this phone.';

  @override
  String get privacyPhoto =>
      'Full photos are used once to find a match, then discarded. Only a small thumbnail is kept.';

  @override
  String get privacyAccount =>
      'With an account, your email and scan history (thumbnails only) are stored so you can sync. Nothing else.';

  @override
  String get privacyNoAds => 'No ads, no tracking, no location.';

  @override
  String get privacyDelete =>
      'You can clear your history or delete your account anytime in Profile.';

  @override
  String get privacyLaw =>
      'In line with the Data Privacy Act of 2012 (RA 10173).';

  @override
  String get aboutCareInfo => 'Care information';

  @override
  String get aboutCareInfoBody =>
      'Care guides are written and checked by the researchers, with sources for every section. They are general guidance. Always follow the garment\'s care label if it differs.';

  @override
  String get aboutApp => 'App';

  @override
  String get aboutScanner => 'Fabric scanner';

  @override
  String get aboutScannerNone => 'Not installed yet';

  @override
  String get aboutContent => 'Fabric content';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get errorLoading =>
      'Couldn\'t load the fabric list. Please restart the app.';

  @override
  String get notFound => 'This fabric isn\'t in the catalog.';

  @override
  String get permTitle => 'Allow camera access';

  @override
  String get permBody =>
      'FabriSCAN+ uses the camera only to take a photo of your fabric. The photo stays on your phone.';

  @override
  String get permAllow => 'Allow camera';

  @override
  String get permUpload => 'Upload a photo instead';

  @override
  String get permDeniedTitle => 'Camera is turned off';

  @override
  String get permDeniedBody =>
      'To scan with the camera, turn it on in your phone\'s Settings: Apps → FabriSCAN+ → Permissions → Camera.';

  @override
  String get permOpenSettings => 'Open Settings';

  @override
  String get camClose => 'Close camera';

  @override
  String get camShutter => 'Take photo';

  @override
  String get camGallery => 'Choose from gallery';

  @override
  String get camTips => 'Photo tips';

  @override
  String get camTip1 => 'Fill the frame with fabric';

  @override
  String get camTip2 => 'Move closer · 10–15 cm';

  @override
  String get camTip3 => 'Avoid flash glare';

  @override
  String get camTip4 => 'Hold steady';

  @override
  String get camError =>
      'The camera couldn\'t start. You can upload a photo instead.';

  @override
  String get reviewTitle => 'Check your photo';

  @override
  String get reviewHint => 'Is the fabric sharp and filling the frame?';

  @override
  String get reviewRetake => 'Retake';

  @override
  String get reviewUse => 'Use photo';

  @override
  String get photoUnreadable => 'Couldn\'t open this photo. Try another.';

  @override
  String get analyzingTitle => 'Looking at the weave…';

  @override
  String get analyzing1 => 'Checking texture and sheen';

  @override
  String analyzing2(int count) {
    return 'Comparing with $count fabrics';
  }

  @override
  String get analyzing3 => 'Almost done';

  @override
  String get analyzingError => 'Something went wrong while checking the photo.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get resultTitle => 'Result';

  @override
  String get yourPhoto => 'Your photo';

  @override
  String get scannedNow => 'Scanned just now';

  @override
  String get confHigh => 'High match';

  @override
  String get confPossible => 'Possible match';

  @override
  String get confNotSure => 'Not sure';

  @override
  String get checkOnGarment => 'Check these on your garment';

  @override
  String get viewCareGuide => 'View care guide';

  @override
  String get notRight => 'Not right? See other possible matches';

  @override
  String get savedLikely =>
      'Saved to History · This is a likely match, not a lab test.';

  @override
  String get otherMatchesTitle => 'Other possible matches';

  @override
  String otherMatchesBody(String fabric) {
    return 'If $fabric doesn\'t look right, compare these. Tap one to see its care guide.';
  }

  @override
  String savedAs(String fabric) {
    return 'Saved $fabric to History';
  }

  @override
  String get couldBeTitle => 'This could be…';

  @override
  String get couldBeBody =>
      'These fabrics look alike. Compare the details with your garment and pick the one that matches.';

  @override
  String get couldBeTip =>
      'Tip: hold the garment up to the light and compare how see-through and stiff it is.';

  @override
  String optionN(int n) {
    return 'Option $n';
  }

  @override
  String get thisOne => 'This one · View care guide';

  @override
  String get noneOfThese => 'None of these?';

  @override
  String get browse => 'Browse';

  @override
  String get pickedSaved => 'The fabric you pick is saved to History.';

  @override
  String get cantTitle => 'We couldn\'t identify this fabric';

  @override
  String get cantBody =>
      'The photo may be blurry or too dark, or it may not be a fabric FabriSCAN+ knows yet.';

  @override
  String get cantTips => 'Try again with these tips';

  @override
  String get retakePhoto => 'Retake photo';

  @override
  String get browseFabrics => 'Browse fabrics';

  @override
  String scopeNote(String categories) {
    return 'FabriSCAN+ covers modern dress fabrics in $categories.';
  }

  @override
  String get nothingSaved => 'Nothing was saved to History.';

  @override
  String get historyOnPhone => 'On this phone';

  @override
  String get historyFooter => 'Newest first · Tap a scan to see its care guide';

  @override
  String historyDelete(String fabric) {
    return 'Delete $fabric scan';
  }

  @override
  String get deleteTitle => 'Delete this scan?';

  @override
  String deleteBody(String fabric, String when) {
    return '$fabric from $when will be removed from History. This can\'t be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleted => 'Scan deleted';

  @override
  String get savedScan => 'Saved scan';

  @override
  String get sourceCamera => 'Camera';

  @override
  String get sourceGallery => 'Gallery';

  @override
  String aboutFabric(String fabric) {
    return 'About $fabric';
  }

  @override
  String today(String time) {
    return 'Today, $time';
  }

  @override
  String yesterday(String time) {
    return 'Yesterday, $time';
  }

  @override
  String get todayShort => 'Today';

  @override
  String get yesterdayShort => 'Yesterday';

  @override
  String get seeAll => 'See all';

  @override
  String get profileData => 'DATA';

  @override
  String get clearAll => 'Clear all history';

  @override
  String get clearAllTitle => 'Clear all history?';

  @override
  String clearAllBody(int count) {
    return 'All $count saved scans and their photos will be removed from this phone. This can\'t be undone.';
  }

  @override
  String get clearAllYes => 'Clear all';

  @override
  String get cleared => 'History cleared';

  @override
  String profileScanCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scans saved on this phone',
      one: '1 scan saved on this phone',
      zero: 'No scans saved yet',
    );
    return '$_temp0';
  }

  @override
  String get testScannerTitle => 'TEST BUILD · SCANNER';

  @override
  String get testScannerBody =>
      'There is no trained scanner yet. Choose which result the test scanner gives, to try every screen.';

  @override
  String get testCycle => 'Cycle';

  @override
  String get testA => 'A';

  @override
  String get testB => 'B';

  @override
  String get testC => 'C';

  @override
  String get testScannerBanner =>
      'Test scanner: results are examples, not a real identification.';
}
