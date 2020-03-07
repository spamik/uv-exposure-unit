#include <Bounce2.h>
#include <U8g2lib.h>
#include <EEPROM.h>

#define MAX_MENUITEM_LENGTH 10
#define MENUITEM_LEFT_MARGIN 20
#define DEBOUNCE_INTERVAL 5
#define REGIONS_X1 20
#define REGIONS_X2 72
#define REGIONS_Y1 28
#define REGIONS_Y2 44
#define BLINKING_INTERVAL 350
#define EEPROM_MAGIC_BYTE 0xcafe

// Pins definitons
#define PIN_KEYBOARD_1 A2
#define PIN_KEYBOARD_2 A3
#define PIN_KEYBOARD_3 A0
#define PIN_KEYBOARD_4 A1
#define PIN_UVLEDARR_1 11
#define PIN_UVLEDARR_2 10
#define PIN_UVLEDARR_3 9
#define PIN_UVLEDARR_4 6
#define PIN_BUZZER 4
#define PIN_UVSIGNAL A4
#define PIN_TAMPER A5

// types
struct TimerDecomposition {
  int mTens;
  int m;
  int sTens;
  int s;
};

// Menu definitions
#define BASE_MENU_ID 0
char * BASE_MENU[] = {
  "Timer",
  "UV manual",
  "Settings"
};
int BASE_MENU_SIZE = 3;

char timer1Str[] = "01:00 (adjust)";
char timer2Str[] = "02:00 (adjust)";
char timer3Str[] = "03:00 (adjust)";
#define TIMER_MENU_ID 1
char * TIMER_MENU[] = {
  (char *) timer1Str,
  (char *) timer2Str,
  (char *) timer3Str
};
int TIMER_MENU_SIZE = 3;

#define SETTINGS_MENU_ID 2
char * SETTINGS_MENU[] = {
  "Regions",
  "Power"
};
int SETTINGS_MENU_SIZE = 2;

#define SET_TIMER_SCREEN_ID 10
#define TIMER_SCREEN_ID 11
#define UVMANUAL_SCREEN_ID 12
#define SETTINGS_REGIONS_ID 13
#define SETTINGS_POWER_ID 14

int activeMenuItem = 0;
int activeScreen = BASE_MENU_ID;
int currentMenuSize = BASE_MENU_SIZE;

// Debouncers for keypad
Bounce dbKey1 = Bounce();
Bounce dbKey2 = Bounce();
Bounce dbKey3 = Bounce();
Bounce dbKey4 = Bounce();
Bounce dbTamper = Bounce();

// system status
bool uvlampOn = false;
int activeTimer = 0;
unsigned long timerStart = 0;


// system settings
int uvPowerPercent = 100;
int uvPower = 255; // real value from PWM, but derivated from EEPROM saved //ceil(uvPowerPercent / 100.0 * 255);
bool uvRegion1 = true;
bool uvRegion2 = true;
bool uvRegion3 = true;
bool uvRegion4 = true;
int timer1 = 60;
int timer2 = 120;
int timer3 = 180;

// editing settings
int uvPowerPercentSettings = uvPowerPercent;
bool uvRegion1Settings = uvRegion1;
bool uvRegion2Settings = uvRegion2;
bool uvRegion3Settings = uvRegion3;
bool uvRegion4Settings = uvRegion4;
int activeRegionSettings = 0;

// timer screen settings
bool blinkVisible = true;
unsigned long lastBlinkTime = 0;
int timerScreenPosition = 0;

// melodies
// when timer finishes
int MELODY_TONES_FINAL_COUNTDOWN[] = {1000, 1000, 1000, 1000};
int MELODY_DURATION_FINAL_COUNTDOWN[] = {300, 300, 300, 300};
int MELODY_PAUSES_FINAL_COUNTDOWN[] = {200, 200, 200, 0};
int MELODY_SIZE_FINAL_COUNTDOWN = 4;

// when UV light is forced to off
int MELODY_TONES_FORCEOFF[] = {250};
int MELODY_DURATION_FORCEOFF[] = {1000};
int MELODY_PAUSES_FORCEOFF[] = {0};
int MELODY_SIZE_FORCEOFF = 1;

// melody states
bool activeMelody = false;
int * melodyTones;
int * melodyDuration;
int * melodyPauses;
int melodySize = 0;
unsigned long melodyLastStart = 0;
int melodyCurrentState = 0;
int melodyPosition = 0;


U8G2_SSD1306_128X64_NONAME_1_HW_I2C u8g2(U8G2_R2);

void setup() {
  // pin setup
  pinMode(PIN_KEYBOARD_1, INPUT);
  pinMode(PIN_KEYBOARD_2, INPUT);
  pinMode(PIN_KEYBOARD_3, INPUT);
  pinMode(PIN_KEYBOARD_4, INPUT);
  pinMode(PIN_TAMPER, INPUT);
  pinMode(PIN_UVLEDARR_1, OUTPUT);
  pinMode(PIN_UVLEDARR_2, OUTPUT);
  pinMode(PIN_UVLEDARR_3, OUTPUT);
  pinMode(PIN_UVLEDARR_4, OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);
  pinMode(PIN_UVSIGNAL, OUTPUT);

  // debouncers setup
  dbKey1.attach(PIN_KEYBOARD_1);
  dbKey1.interval(DEBOUNCE_INTERVAL);
  dbKey2.attach(PIN_KEYBOARD_2);
  dbKey2.interval(DEBOUNCE_INTERVAL);
  dbKey3.attach(PIN_KEYBOARD_3);
  dbKey3.interval(DEBOUNCE_INTERVAL);
  dbKey4.attach(PIN_KEYBOARD_4);
  dbKey4.interval(DEBOUNCE_INTERVAL);
  dbTamper.attach(PIN_TAMPER);
  dbTamper.interval(DEBOUNCE_INTERVAL);

  // menu setup
  activeMenuItem = 0;
  activeScreen = BASE_MENU_ID;
  currentMenuSize = BASE_MENU_SIZE;

  // load settings
  loadEEPROMSettings();

  // reload timer menu
  updateTimerMenu();

  // display library init
  u8g2.begin();
}

void loop() {
  updateBouncers();
  if (activeMelody) {
    melodyLoop();
  }
  // menu update
  u8g2.firstPage();
  do {
    switch (activeScreen) {
      case BASE_MENU_ID:
        drawMenu(BASE_MENU, BASE_MENU_SIZE, activeMenuItem);
        break;
      case TIMER_MENU_ID:
        drawMenu(TIMER_MENU, TIMER_MENU_SIZE, activeMenuItem);
        break;
      case SETTINGS_MENU_ID:
        drawMenu(SETTINGS_MENU, SETTINGS_MENU_SIZE, activeMenuItem);
        break;
      case UVMANUAL_SCREEN_ID:
        drawUvManual();
        break;
      case SETTINGS_POWER_ID:
        drawPowerSettings();
        break;
      case SETTINGS_REGIONS_ID:
        drawRegionSettings();
        break;
      case SET_TIMER_SCREEN_ID:
        drawSetTimer();
        break;
      case TIMER_SCREEN_ID:
        drawTimer();
        break;
    }
           
  } while ( u8g2.nextPage() );
}

void melodyLoop() {
  // changing state of buzzer to play selected melody
  switch (melodyCurrentState) {
    case 0:
      // start playing new tone
      tone(PIN_BUZZER, *(melodyTones+melodyPosition));
      melodyLastStart = millis();
      melodyCurrentState = 1;
      break;
    case 1:
      // playing tone, waiting for duration to turn it off
      if (melodyLastStart + *(melodyDuration+melodyPosition) <= millis()) {
        noTone(PIN_BUZZER);
        melodyLastStart = millis();
        melodyCurrentState = 2;
      }
      break;
    case 2:
      // pause between next tone
      if (melodyLastStart + *(melodyPauses+melodyPosition) <= millis()) {
        melodyPosition++;
        melodyCurrentState = 0;
        if (melodyPosition == melodySize) {
          // end of melody
          activeMelody = false;
        }
      }
      break;
  }
}

void drawMenu(char ** menu, int menu_size, int active) {
  u8g2.setFont(u8g2_font_helvB12_tr);
  for (int i=0; i < menu_size; i++) {
    u8g2.drawStr(MENUITEM_LEFT_MARGIN, i*16+12, menu[i]);
  }
  u8g2.drawStr(0, active*16 + 10, "->");

  //u8g2.setFont(u8g2_font_logisoso16_tr);
  u8g2.drawStr(0, 64, "<     v      ^     >");
}

void drawUvManual() {
  u8g2.setFont(u8g2_font_helvB12_tr);
  u8g2.drawStr(0, 12, "Current state:");
  u8g2.setFont(u8g2_font_inb24_mr);
  if (uvlampOn) {
    u8g2.drawStr(32, 45, "On");
    u8g2.setFont(u8g2_font_helvB12_tr);
    u8g2.drawStr(0, 64, "<                Off");
  }
  else {
    u8g2.drawStr(32, 45, "Off");   
    u8g2.setFont(u8g2_font_helvB12_tr);
    u8g2.drawStr(0, 64, "<                 On");
  }
  
}

void drawPowerSettings() {
  u8g2.setFont(u8g2_font_helvB12_tr);
  u8g2.drawStr(0, 12, "Current power:");
  u8g2.setFont(u8g2_font_inb24_mr);
  char powerStr[4];
  sprintf(powerStr, "%d", uvPowerPercentSettings);
  u8g2.drawStr(32, 45, powerStr);
  u8g2.setFont(u8g2_font_helvB12_tr);
  u8g2.drawStr(0, 64, "<     -     +    Set");
}

void drawRegionSettings() {
  u8g2.setFont(u8g2_font_helvB12_tr);
  u8g2.drawStr(0, 12, "Set regions:");
  u8g2.drawStr(REGIONS_X1, REGIONS_Y1, getRegionState(uvRegion1Settings));
  u8g2.drawStr(REGIONS_X2, REGIONS_Y1, getRegionState(uvRegion2Settings));
  u8g2.drawStr(REGIONS_X1, REGIONS_Y2, getRegionState(uvRegion3Settings));
  u8g2.drawStr(REGIONS_X2, REGIONS_Y2, getRegionState(uvRegion4Settings));

  char * legendSwap;
  switch (activeRegionSettings) {
    case 0:
       u8g2.drawStr(REGIONS_X1-20, REGIONS_Y1-2, "->");
       legendSwap = getRegionState(!uvRegion1Settings);
       break;
     case 1:
       u8g2.drawStr(REGIONS_X2-20, REGIONS_Y1-2, "->");
       legendSwap = getRegionState(!uvRegion2Settings);
       break;
     case 2:
      u8g2.drawStr(REGIONS_X1-20, REGIONS_Y2-2, "->");
      legendSwap = getRegionState(!uvRegion3Settings);
      break;
     case 3:
      u8g2.drawStr(REGIONS_X2-20, REGIONS_Y2-2, "->");
      legendSwap = getRegionState(!uvRegion4Settings);
  }

  // legend
  char legend[23] = "<   ->   ";
  strcat(legend, legendSwap);
  strcat(legend, "   Set");
  u8g2.drawStr(0, 64, legend);
}

void drawTimer() {
  // draw current timer
  if (!uvlampOn) {
    // lamp is off, maybe tamper switch? go back to main menu, nothing more
    goMainMenu();
    return;
  }
  int timerLeft = activeTimer - (millis() - timerStart)/1000;
  if (timerLeft <= 0) {
    // timer is over, turn off lamp, play melody, go back to main menu
    uvlampTurnOff();
    playMelodyCountdown();
    goMainMenu();
    return;
  }
  // draw left time
  char timerStr[6];
  timerString(timerLeft, (char *) timerStr);
  u8g2.setFont(u8g2_font_inb24_mr);
  u8g2.drawStr(10, 24, (char *) timerStr);

  // legend
  u8g2.setFont(u8g2_font_helvB12_tr);
  u8g2.drawStr(0, 64, "Cancel");
}

void drawSetTimer() {
  u8g2.setFont(u8g2_font_inb24_mr);

  TimerDecomposition dt = decompositeSeconds(activeTimer);

  if (millis() - lastBlinkTime >= BLINKING_INTERVAL) {
    blinkVisible = !blinkVisible;
    lastBlinkTime = millis();
  }
  
  
  if (!(timerScreenPosition == 0 && !blinkVisible)) {    
    char mTen[1];
    sprintf(mTen, "%d", dt.mTens);
    u8g2.drawStr(10, 24, (char *) mTen);
  }

  if (!(timerScreenPosition == 1 && !blinkVisible)) {
    char m[1];
    sprintf(m, "%d", dt.m);
    u8g2.drawStr(33, 24, (char *) m);
  }

  u8g2.drawStr(56, 24, ":");

  if(!(timerScreenPosition == 2 && !blinkVisible)) {
    char sTen[1];
    sprintf(sTen, "%d", dt.sTens);
    u8g2.drawStr(79, 24, (char *) sTen);
  }

  if(!(timerScreenPosition == 3 && !blinkVisible)) {
    char s[1];
    sprintf(s, "%d", dt.s);
    u8g2.drawStr(102, 24, (char *) s);
  }
  
  u8g2.setFont(u8g2_font_helvB12_tr);
  u8g2.drawStr(20, 45, "Run");
  u8g2.drawStr(85, 45, "Back");

  switch (timerScreenPosition) {
    case 4:
      u8g2.drawStr(0, 43, "->");
      break;
    case 5:
      u8g2.drawStr(65, 43, "->");
      break;
  }

  u8g2.drawStr(0, 64, "->    -     +    Set");
}

char * getRegionState(bool region) {
  if (region) {
    return "On";
  }
  return "Off";
}

void updateBouncers() {
  dbKey1.update();
  dbKey2.update();
  dbKey3.update();
  dbKey4.update();
  dbTamper.update();

  if (dbKey1.rose()) {
    backKeyPress();
  }
  if (dbKey2.rose()) {
    downKeyPress();
  }
  if (dbKey3.rose()) {
    upKeyPress();
  }
  if (dbKey4.rose()) {
    setKeyPress();
  }
  if (dbTamper.fell()) {
    tamperOpen();
  }
}

void tamperOpen() {
  // tamper switch has opened
  if (uvlampOn) {
    // uvlamp is on and tamper failed - turn off
    uvlampTurnOff();
    playMelodyForceoff();
  }
}

void backKeyPress() {
  if (activeScreen < 10) {
    // back from menu
    menuSelection(false);
  }
  else {
    switch (activeScreen) {
      case UVMANUAL_SCREEN_ID:
        uvmanualScreenBackKey();
        break;
      case SETTINGS_POWER_ID:
      case SETTINGS_REGIONS_ID:
        goSettingsMenu();
        break;
      case SET_TIMER_SCREEN_ID:
        timerSetBackKey();
        break;
      case TIMER_SCREEN_ID:
        timerBackKey();
        break;
    }
  }
}

void downKeyPress() {
  switch (activeScreen) {
    case BASE_MENU_ID:
    case TIMER_MENU_ID:
    case SETTINGS_MENU_ID:
      activeMenuItem++;
      if (activeMenuItem == currentMenuSize) {
        activeMenuItem -= currentMenuSize;
      }
      break;
    case SETTINGS_POWER_ID:
      powerSettingsDownKey();
      break;
    case SETTINGS_REGIONS_ID:
      uvRegionsDownKey();
      break;
    case SET_TIMER_SCREEN_ID:
      timerSetDownKey();
      break;
  }
}

void upKeyPress() {
  switch (activeScreen){
    case BASE_MENU_ID:
    case TIMER_MENU_ID:
    case SETTINGS_MENU_ID:
      activeMenuItem--;
      if (activeMenuItem < 0) {
        activeMenuItem = currentMenuSize -1;
      }
      break;
    case SETTINGS_POWER_ID:
      powerSettingsUpKey();
      break;
    case SETTINGS_REGIONS_ID:
      uvRegionsUpKey();
      break;
    case SET_TIMER_SCREEN_ID:
      timerSetUpKey();
      break;
  }
}

void setKeyPress() {
  if (activeScreen < 10) {
    // menu entry
    menuSelection(true);  
  }
  else {
    switch (activeScreen) {
      case UVMANUAL_SCREEN_ID:
        uvmanualScreenSetKey();
        break;
      case SETTINGS_POWER_ID:
        powerSettingsSetKey();
        break;
      case SETTINGS_REGIONS_ID:
        uvRegionsSetKey();
        break;
      case SET_TIMER_SCREEN_ID:
        timerSetSetKey();
        break;
    }
  }
}

void menuSelection(bool setkey) {
  switch (activeScreen) {
    case BASE_MENU_ID:
      if (setkey) { // no place to go back
        switch (activeMenuItem) {
          case 0:
            // timer menu
            activeScreen = TIMER_MENU_ID;
            activeMenuItem = 0;
            currentMenuSize = TIMER_MENU_SIZE;
            break;
          case 1:
            // uv manual
            activeScreen = UVMANUAL_SCREEN_ID;
            break;
          case 2:
            // settings menu
            goSettingsMenu();
            break;
        }
      }
      break;
    case TIMER_MENU_ID:
      if (setkey) {
        // enter some item
        switch (activeMenuItem) {
          case 0:
            activeTimer = timer1;
            break;
          case 1:
            activeTimer = timer2;
            break;
          case 2: 
            activeTimer = timer3;
            break;
        }
        lastBlinkTime = millis();
        timerScreenPosition = 0;
        blinkVisible = true;
        activeScreen = SET_TIMER_SCREEN_ID;
      }
      else {
        // go back to main menu
        goMainMenu();
      }
      break;
    case SETTINGS_MENU_ID:
      if (setkey) {
        // enter some subitem
        switch (activeMenuItem) {
          case 0:
            // regions settings
            activeRegionSettings = 0;
            uvRegion1Settings = uvRegion1;
            uvRegion2Settings = uvRegion2;
            uvRegion3Settings = uvRegion3;
            uvRegion4Settings = uvRegion4;
            activeScreen = SETTINGS_REGIONS_ID;
            break;
          case 1:
            // power settings
            uvPowerPercentSettings = uvPowerPercent;
            activeScreen = SETTINGS_POWER_ID;
            break;
        }
      }
      else {
        // go back to main menu
        goMainMenu();
      }
      break;
  }
}

void goMainMenu() {
  // set base menu as active
  activeScreen = BASE_MENU_ID;
  activeMenuItem = 0;
  currentMenuSize = 3;
}

void goSettingsMenu() {
  // set settings menu as active
  activeScreen = SETTINGS_MENU_ID;
  activeMenuItem = 0;
  currentMenuSize = 2;
}

void uvmanualScreenSetKey() {
  // set key pressed on uv manual screen
  // switch the state of UV lamp
  if (uvlampOn) {
    uvlampTurnOff();
  }
  else {
    uvlampTurnOn();
  }
}

void uvmanualScreenBackKey() {
  // back key pressed on uv manual screen
  // turn off lamp and return to main menu
  uvlampTurnOff();
  goMainMenu();
}

void uvlampTurnOn() {
  // turn on UV lamp

  if (dbTamper.read() == LOW) {
    // cover not closed - play sound and return
    playMelodyForceoff();
    return;
  }
  
  // signal light
  digitalWrite(PIN_UVSIGNAL, HIGH);
  // turn on uv regions
  if (uvRegion1) {
    analogWrite(PIN_UVLEDARR_1, uvPower);
  }
  if (uvRegion2) {
    analogWrite(PIN_UVLEDARR_2, uvPower);
  }
  if (uvRegion3) {
    analogWrite(PIN_UVLEDARR_3, uvPower);
  }
  if (uvRegion4) {
    analogWrite(PIN_UVLEDARR_4, uvPower);
  }
  // rewrite state
  uvlampOn = true;
}

void uvlampTurnOff() {
  // turn off all uvlamp

  // turn off UV lamps
  analogWrite(PIN_UVLEDARR_1, 0);
  analogWrite(PIN_UVLEDARR_2, 0);
  analogWrite(PIN_UVLEDARR_3, 0);
  analogWrite(PIN_UVLEDARR_4, 0);
  // turn off signal light
  digitalWrite(PIN_UVSIGNAL, LOW);
  // rewrite state
  uvlampOn = false;  
}

void powerSettingsUpKey() {
  // increase power settings
  uvPowerPercentSettings += 10;
  if (uvPowerPercentSettings > 100) {
    uvPowerPercentSettings = 100;  
  }
}

void powerSettingsDownKey() {
  // decrease power settings
  uvPowerPercentSettings -= 10;
  if (uvPowerPercentSettings < 0) {
    uvPowerPercentSettings = 0;
  }
}

void powerSettingsSetKey() {
  // set current power settings and go back to settings menu
  uvPowerPercent = uvPowerPercentSettings;
  uvPower = ceil(uvPowerPercent / 100.0 * 255);
  saveEEPROMSettings(); // save to EEPROM
  goSettingsMenu();
}

void uvRegionsDownKey() {
  // swap regions
  activeRegionSettings = (activeRegionSettings+1) % 4;
}

void uvRegionsUpKey() {
  // change value of current region
  switch (activeRegionSettings) {
    case 0:
      uvRegion1Settings = !uvRegion1Settings;
      break;
    case 1:
      uvRegion2Settings = !uvRegion2Settings;
      break;
    case 2:
      uvRegion3Settings = !uvRegion3Settings;
      break;
    case 3:
      uvRegion4Settings = !uvRegion4Settings;
      break;
  }
}

void uvRegionsSetKey() {
  // save settings of UV regions
  uvRegion1 = uvRegion1Settings;
  uvRegion2 = uvRegion2Settings;
  uvRegion3 = uvRegion3Settings;
  uvRegion4 = uvRegion4Settings;
  saveEEPROMSettings(); // save to EEPROM
  goSettingsMenu();
}

void timerSetBackKey() {
  timerScreenPosition = (timerScreenPosition + 1) % 6;
}

void timerSetUpKey() {
  switch (timerScreenPosition) {
    case 0:
      // ten minutes
      if (activeTimer < 5400) {
        // les then 90 minutes already sets
        activeTimer += 600; // add 10 minutes
      }
      break;
    case 1:
      // minutes
      if ((activeTimer / 60) % 10 < 9) {
        // if single minutes are less then 9
        activeTimer += 60;
      }
      break;
    case 2:
      // ten seconds
      if ((activeTimer % 60) / 10 < 5) {
        // ten seconds are currently 0 - 4
        activeTimer += 10;
      }
      break;
    case 3:
      // seconds
      if (activeTimer % 60 % 10 < 9) {
        activeTimer++;
      }
      break;
  }
  
}

void timerSetDownKey() {
  switch (timerScreenPosition) {
    case 0:
      // ten minutes decrease
      if (activeTimer >= 600) {
        activeTimer -= 600; 
      }
      break;
    case 1:
      // minute decrease
      if ((activeTimer / 60) % 10 > 0) {
        activeTimer -= 60;
      }
      break;
    case 2:
      // ten seconds decrease
      if ((activeTimer % 60) / 10 > 0) {
        activeTimer -= 10;
      }
      break;
    case 3:
      // second decrease
      if ((activeTimer % 60) % 10 > 0) {
        activeTimer--;
      }
      break;
  }
}

void timerSetSetKey() {
  if (timerScreenPosition == 5) {
    // go back to timer menu
    activeScreen = TIMER_MENU_ID;
    activeMenuItem = 0;
    currentMenuSize = TIMER_MENU_SIZE;
  }
  else {
    // run timer
    uvlampTurnOn();
    if (!uvlampOn) {
      // we tried to turn on UV lamp but it's not
      // probably tamper? exit for now
      return;
    }
    switch (activeMenuItem) {
      // rewrite memorized timer
      case 0:
        timer1 = activeTimer;
        break;
      case 1:
        timer2 = activeTimer;
        break;
      case 2:
        timer3 = activeTimer;
        break;
    }
    updateTimerMenu();
    saveEEPROMSettings();
    timerStart = millis();
    activeScreen = TIMER_SCREEN_ID;
  }
}

void timerBackKey() {
  // cancel current timer
  uvlampTurnOff();
  playMelodyForceoff();
  goMainMenu();
}

TimerDecomposition decompositeSeconds(int seconds) {
  // return timer decomposition from seconds;
  TimerDecomposition result;
  int rMinutes = seconds / 60;
  int rSeconds = seconds % 60;
  result.mTens = rMinutes / 10;
  result.m = rMinutes % 10;
  result.sTens = rSeconds / 10;
  result.s = rSeconds % 10;
  return result;
}

void timerString(int timer, char * output) {
  // write timer string into char variable
  TimerDecomposition t = decompositeSeconds(timer);
  char result[5] = "";
  sprintf(output, "%d%d:%d%d", t.mTens, t.m, t.sTens, t.s);
}

void updateTimerMenu() {
  // update string in menu timer (with actual timer value)
  timerString(timer1, timer1Str);  
  timerString(timer2, timer2Str);  
  timerString(timer3, timer3Str);
  strcat(timer1Str, " (adjust)");
  strcat(timer2Str, " (adjust)");
  strcat(timer3Str, " (adjust)");
  TIMER_MENU[0] = (char *) timer1Str;
  TIMER_MENU[1] = (char *) timer2Str;
  TIMER_MENU[2] = (char *) timer3Str;
}

void playMelodyCountdown() {
  // play melody on finishing countdown
  melodyTones = MELODY_TONES_FINAL_COUNTDOWN;
  melodyDuration = MELODY_DURATION_FINAL_COUNTDOWN;
  melodyPauses = MELODY_PAUSES_FINAL_COUNTDOWN;
  melodySize = MELODY_SIZE_FINAL_COUNTDOWN;
  melodyCurrentState = 0;
  melodyPosition = 0;
  activeMelody = true;
}

void playMelodyForceoff() {
  // melody on force UV off
  melodyTones = MELODY_TONES_FORCEOFF;
  melodyDuration = MELODY_DURATION_FORCEOFF;
  melodyPauses = MELODY_PAUSES_FINAL_COUNTDOWN;
  melodySize = MELODY_SIZE_FORCEOFF;
  melodyCurrentState = 0;
  melodyPosition = 0;
  activeMelody = true;
}

void loadEEPROMSettings() {
  // load settings from EEPROM
  int address = 0;
  int magicConst;
  EEPROM.get(address, magicConst);
  if (magicConst != EEPROM_MAGIC_BYTE) {
    // unknown EEPROM, maybe wasn't ever saved. Save settings first
    saveEEPROMSettings();
  }
  address += sizeof(int);
  
  EEPROM.get(address, uvPowerPercent);
  uvPower = ceil(uvPowerPercent / 100.0 * 255);
  address += sizeof(int);

  EEPROM.get(address, uvRegion1);
  address += sizeof(bool);
  EEPROM.get(address, uvRegion2);
  address += sizeof(bool);
  EEPROM.get(address, uvRegion3);
  address += sizeof(bool);
  EEPROM.get(address, uvRegion4);
  address += sizeof(bool);

  EEPROM.get(address, timer1);
  address += sizeof(int);
  EEPROM.get(address, timer2);
  address += sizeof(int);
  EEPROM.get(address, timer3);
}

void saveEEPROMSettings() {
  // save settings to EEPROM
  int address = 0;
  int magicConst = EEPROM_MAGIC_BYTE;
  EEPROM.put(address, magicConst);
  address += sizeof(int);

  EEPROM.put(address, uvPowerPercent);
  address += sizeof(int);

  EEPROM.put(address, uvRegion1);
  address += sizeof(bool);
  EEPROM.put(address, uvRegion2);
  address += sizeof(bool);
  EEPROM.put(address, uvRegion3);
  address += sizeof(bool);
  EEPROM.put(address, uvRegion4);
  address += sizeof(bool);

  EEPROM.put(address, timer1);
  address += sizeof(int);
  EEPROM.put(address, timer2);
  address += sizeof(int);
  EEPROM.put(address, timer3);
}

