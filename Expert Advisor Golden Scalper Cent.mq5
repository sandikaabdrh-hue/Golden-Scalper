//+------------------------------------------------------------------+
//|       HELLO ME NAME IS DEVELOPER EXPERT ADVISOR INDONESIA        |
//|            WELCOME TO THE WORD AI EGINERING EXPERT               |
//|               Developer From TG:@daillytrader                    |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#property description "SAYA ADALAH EXPERT ADVISOR YANG HANDAL DALAM KONDISI APAPUN"
#property description "IKUTI RULLES YANG DI BERIKAN ADMIN DAN SETINGAN DEFAULT JAM START 09:00-15:00-17:00 WIB/GMT+7"
#property description "UNTUK BROKER 2 DIGIT GUNAKAN FORMAT 10pts SAMAN DENGAN 1 PISP"
#property description "UNTUK BROKER 3 DIGIT GUNAKAN FORMAT 100pts SAMAN DENGAN 1 PIPS"
#property version   "5.00"

//--- Komentar Order Tersembunyi (Hidden Comment - Tidak tampil di Input)
#define HIDDEN_ORDER_COMMENT "GOLDEN SCALPER@DAILLYTRADE24HOURS"

//--- Enums untuk Dropdown Menu
enum ENUM_LOT_MODE {
    LOT_LINEAR = 0,        // Pengadaan Custome
    LOT_MULTIPLIER = 1     // Pengadaan Perkalian
};

enum ENUM_TP_MODE {
    TP_POINTS = 0,         // Take Profit (Points)
    TP_USD = 1             // Take Profit (USD)
};

enum ENUM_TARGET_MODE {
    TARGET_PERCENT = 0,    // Persentase Dari Balance (%)
    TARGET_FIXED_USD = 1   // Nominal Angka Fix ($)
};

enum ENUM_ACTION_MODE {
    ACTION_STOP_TOMORROW = 0, // Selesaikan Cycle, Lanjut Besok
    ACTION_REMOVE_EA = 1,     // Selesaikan Cycle, Keluarkan EA
    ACTION_PAUSE_MINUTES = 2  // Selesaikan Cycle, Jeda X Menit lalu Lanjut
};

//--- Enums untuk Aksi Saat Lisensi Berakhir
enum ENUM_LICENSE_ACTION {
    LICENSE_ACTION_FINISH_CYCLE_STOP = 0,   // Selesaikan cycle lalu close semua posisi & hentikan EA
    LICENSE_ACTION_FINISH_CYCLE_REMOVE = 1, // Selesaikan cycle lalu close semua posisi & keluarkan EA
    LICENSE_ACTION_CLOSE_STOP = 2,          // Close semua posisi saat ini & hentikan EA
    LICENSE_ACTION_CLOSE_REMOVE = 3         // Close semua posisi saat ini & keluarkan EA dari chart
};

//--- Enums untuk Dynamic Target Profit (Mode)
enum ENUM_DYNAMIC_TP_MODE {
    DTP_MODE_NONE = 0,     // Tidak Tidak Ada Perubahan Target 
    DTP_MODE_LAYER  = 1,   // Ubah Target Saat Layer Keberapa
    DTP_MODE_LOT    = 2    // Ubah Target Saat Lot Keberapa
};

//--- Enums untuk Nilai Target Dinamis (USD atau Points)
enum ENUM_DYNAMIC_TP_VALUE_MODE {
    DTP_VALUE_USD = 0,     // Target Dinamis dalam ($)
    DTP_VALUE_POINTS = 1   // Target Dinamis dalam Points
};

//--- Enums untuk Delay Entry
enum ENUM_DELAY_MODE {
    DELAY_MODE_NONE = 0,        // Tidak ada jeda
    DELAY_MODE_PER_LAYER = 1,   // Jeda antar layer
    DELAY_MODE_AFTER_CLOSE = 2, // Jeda setelah close posisi
    DELAY_MODE_BY_COUNT = 3     // Jeda berdasarkan jumlah cadhel
};

//--- Enums untuk Drawdown Mode & Aksi Drawdown
enum ENUM_DD_MODE {
    DD_MODE_USD = 0,       // Berdasarkan Nilai ($)
    DD_MODE_PERCENT = 1    // Berdasarkan Persentase Equity (%)
};

enum ENUM_DD_ACTION {
    DD_ACTION_CLOSE_STOP = 0,     // Close all & Hentikan EA
    DD_ACTION_CLOSE_REMOVE = 1,   // Close all, Hentikan & Keluarkan EA dari Chart
    DD_ACTION_CLOSE_PAUSE = 2     // Close all, Jeda beberapa menit lalu entry ulang
};

//--- Enums untuk Filter News Berdasarkan Mode
enum ENUM_NEWS_MODE {
    NEWS_MODE_LOW    = 0, // Low, Medium, & High Impact disaring
    NEWS_MODE_MEDIUM = 1, // Medium & High Impact disaring
    NEWS_MODE_HIGH   = 2  // Hanya High Impact saja yang disaring
};

//--- Enums untuk Aksi Saat News
enum ENUM_NEWS_ACTION {
    NEWS_ACTION_CYCLE_STOP = 0,      // Selesaikan cycle lalu hentikan EA
    NEWS_ACTION_CLOSE_STOP = 1,      // Close semua posisi lalu hentikan EA
    NEWS_ACTION_CYCLE_REMOVE = 2,    // Selesaikan cycle lalu hentikan & keluarkan EA dari chart
    NEWS_ACTION_CLOSE_REMOVE = 3,    // Close semua posisi lalu hentikan & keluarkan EA dari chart
    NEWS_ACTION_PAUSE_ENTRY = 4      // Biarkan posisi terbuka, hentikan entry sampai waktu tertentu baru lanjut
};

//--- Input Parameters
input group "===== KONFIGURASI UTAMA ====="
input double   InpInitialLot       = 0.01;      // Lot awal 
input ENUM_LOT_MODE InpLotMode   = LOT_MULTIPLIER;  // Mode Pengadaan
input double   InpLotMultiplier    = 1.5;       // Pengadaan Perkalian
input double   InpLotStep          = 0.01;      // Lot Custom
input int      InpLayerStep        = 1;         // Layer Custom

// KONFIGURASI LAYER
input group "===== KONFIGURASI LAYER ====="
input int      InpGridDistance     = 200;         // Jarak Antar Layer
input ENUM_TP_MODE InpTPMode         = TP_POINTS; // Mode Take Profit
input int      InpTakeProfitPoints   = 300;       // Target TP Berdasarkan Nilai Tetap Point
input double   InpTakeProfitUSD      = 5.0;       // Target Tp Bedasarkan Nilai Tetap ($)
input bool     UseMaxLot           = true;      // Active Batas Maximal Lot
input double   InpMaxLot           = 1.0;         // Maximal Jumlah Lot Per Arah
input bool     UseMaxLayers        = true;      // Active Batas Maximal Layer 
input int      InpMaxLayersPerDirection = 50;    // Maximal Layer Per Arah


// KONFIGURASI TARGET DINAMIS 1
input group "===== KONFIGURASI TARGET DINAMIS 1 ====="
input bool     UseDynamicTP1       = true;      // Active Target Dinamis 
input ENUM_DYNAMIC_TP_MODE InpDynamicTPMode1 = DTP_MODE_LAYER;   // Mode Perubahan Target Dinamis 
input ENUM_DYNAMIC_TP_VALUE_MODE InpDynamicTPValueMode1 = DTP_VALUE_USD; // Mode Nilai Target Dinamis 
input double   InpDynamicTPUSD1    = 5.0;       // Target Dinamis ($)
input int      InpDynamicTPPoints1 = 300;       // Target Dinamis (Points)
input int      InpLayersToChangeTP1 = 5;        // Custom Layer 
input double   InpLotToChangeTP1   = 0.5;       // Custome Lot 

// KONFIGURASI TARGET DINAMIS 2 (TAMBAHAN BARU)
input group "===== KONFIGURASI TARGET DINAMIS 2 ====="
input bool     UseDynamicTP2       = false;     // Active Target Dinamis
input ENUM_DYNAMIC_TP_MODE InpDynamicTPMode2 = DTP_MODE_LOT;     // Mode Perubahan Target Dinamis 
input ENUM_DYNAMIC_TP_VALUE_MODE InpDynamicTPValueMode2 = DTP_VALUE_USD; // Mode Nilai Target Dinamis
input double   InpDynamicTPUSD2    = 10.0;      // Target Dinamis ($)
input int      InpDynamicTPPoints2 = 600;       // Target Dinamis (Points)
input int      InpLayersToChangeTP2 = 10;       // Custom Layer 
input double   InpLotToChangeTP2   = 1.0;       // Custome Lot 

// KONFIGURASI TARGET HARIAN
input group "===== KONFIGURASI TARGET HARIAN ====="
input ENUM_TARGET_MODE InpTargetMode = TARGET_FIXED_USD; // Mode Target Harian
input bool     UseDailyProfit      = false;     // Active Profit
input double   DailyProfitValue    = 50.0;      // Nilai Target Harian Profit
input bool     UseDailyLoss        = false;     // Active Lose 
input double   DailyLossValue      = 50.0;      // Nilai Target Harian Lose

// KONFIRASI AKSI TAREGET HARIAN
input group "===== AKSI TARGET HARIAN ====="
input ENUM_ACTION_MODE InpTargetAction = ACTION_STOP_TOMORROW; // Active Aksi Target Dailly
input int      InpPauseMinutes     = 30;        // Jeda (Menit)

// KONFIGURASI WAKTU JAM TRADING
input group "===== KONFIGURASI WAKTU (WIB / GMT+7) ====="
input bool     UseTimeFilter       = true;      // Active Jam Trading GMT+7
input int      InpStartHour        = 9;         // Jam Mulai GMT+7/WIB
input int      InpStartMinute      = 0;         // Menit Mulai GMT+7/WIB
input int      InpEndHour          = 17;        // Jam Selesai GMT+7/WIB
input int      InpEndMinute        = 30;        // Menit Selesai GMT+7/WIB

// KONFIGURASI AKSI SAAT JAM TRADING SELESAI
input group "==== AKSI JAM TRADING ====="
input ENUM_ACTION_MODE InpTimeEndAction = ACTION_STOP_TOMORROW; // Mode Aksi Jam Trading
input int      InpTimePauseMinutes = 30;        // Jeda Waktu (Menit)

// KONFIGURASI CUT LOSE BATASAN JAM TRADING 
input group "==== CUT LOSE JAM TRADING ====="
input bool     UseTimeOutCutLoss   = true;      // Active Cut Lose 
input double   TimeOutCutLossUSD   = 10.0;      // Batas Floating ($)


// KONFIGURASI DELAY ENTRY
input group "===== KONFIGURASI DELAY ENTRY ====="
input ENUM_DELAY_MODE InpDelayMode = DELAY_MODE_NONE; // Mode Delay Entry
input int      InpDelayMilliseconds = 1200;     // Jeda Dalam Waktu Milidetik
input int      InpDelayByCount = 5;             // Jeda Berdasarkan Jumlah Cadhel

// KONFIGURASI MAX DRAWDOWN
input group "===== KONFIGURASI MAX DRAWDOWN ====="
input bool     UseMaxDrawdown      = false;     // Active Max Drawdown Protection
input ENUM_DD_MODE InpDDMode       = DD_MODE_USD; // Mode Drawdown (USD / Persen Equity)
input double   InpDDValue          = 50.0;     // Nilai Batas Drawdown ($ atau %)
input ENUM_DD_ACTION InpDDAction   = DD_ACTION_CLOSE_STOP; // Aksi Saat Drawdown Tercapai
input int      InpDDPauseMinutes   = 30;        // Jeda Waktu (Menit) 

// KONFIGURASI FILTER NEWS (KALENDER MT5)
input group "===== KONFIGURASI FILTER NEWS (MT5) ====="
input bool     UseNewsFilter       = false;     // Active News 
input bool     UseNewsPairOnly     = true;      // Active Pair Yang Di Gunakan 
input ENUM_NEWS_MODE InpNewsMode   = NEWS_MODE_HIGH; // Mode Level Impact Berita
input int      InpNewsMinutesBefore = 60;       // Jeda Sebelum Berita (Menit)
input int      InpNewsMinutesAfter  = 60;       // Jeda Sesudah Berita (Menit)
input ENUM_NEWS_ACTION InpNewsAction = NEWS_ACTION_PAUSE_ENTRY; // Aksi Saat News Terdeteksi

// KONFIGURASI LICENSI ACCOUNT 
input group "===== LISENSI EA ====="
input string   InpLicenseKey       = "";         // Masukan Code Locensi
input bool     InpLicenseCheckEnabled = true;    // Aktifkan Pengecekan Lisensi
input ENUM_LICENSE_ACTION InpLicenseAction = LICENSE_ACTION_CLOSE_STOP; // Pilihan Aksi Saat Lisensi Expire

// TITUR TAMBAHAN CUSTOME
input group "===== PENGATURAN LAINNYA ====="
input ulong    InpMagicNumber      = 88888;      // Number Series
input ulong    InpSlippage         = 3;          // Slippage Dalam Points

// KONFIGURASI INTEGRASI WEB PANEL (VERCEL)
input group "===== INTEGRASI WEB PANEL (VERCEL) ====="
input bool     InpWebEnabled       = true;       // Aktifkan Integrasi Web Panel
input string   InpWebBaseUrl       = "https://NAMA-PROJECT-ANDA.vercel.app"; // URL Domain Vercel (tanpa slash di akhir)
input string   InpWebToken         = "GANTI_DENGAN_TOKEN_RAHASIA";           // Token Rahasia (harus sama dgn EA_SHARED_TOKEN di Vercel)
input int      InpWebIntervalSec   = 3;          // Interval Kirim Update (detik)

// KONFIGURASI PANEL INFO DI CHART
input group "===== PANEL INFO - POSISI & UKURAN ====="
input bool     InpShowPanel        = true;      // Tampilkan Panel Info
input int      InpPanelX           = 10;        // Posisi Panel X
input int      InpPanelY           = 20;        // Posisi Panel Y
input int      InpPanelWidth       = 420;       // Lebar Panel
input int      InpPanelRowHeight   = 15;        // Tinggi Per Baris
input int      InpPanelHeaderHeight = 20;       // Tinggi Header Bar
input int      InpPanelFontSize    = 8;         // Ukuran Font (Isi)
input int      InpPanelTitleFontSize = 8;      // Ukuran Font (Judul Header)
input string   InpPanelFont        = "Consolas"; // Nama Font

//--- Warna Panel
color  InpColorBackground  = C'20,22,26';
color  InpColorHeaderBG    = C'30,90,160';
color  InpColorBorder      = C'70,130,200';
color  InpColorTitleText   = clrWhite;
color  InpColorSectionText = C'120,180,255';
color  InpColorLabelText   = C'170,178,190';
color  InpColorValueText   = clrWhite;
color  InpColorProfit      = C'60,200,110';
color  InpColorLoss        = C'230,80,80';
color  InpColorWarning     = C'230,180,60';
color  InpColorDivider     = C'60,66,76';

//--- Global Variables
CTrade         trade;
CPositionInfo  m_position;
datetime       lastActionTime = 0; 
int            currentDay = -1;

bool           isTradingStoppedForDay = false; 
datetime       pauseEndTime = 0;        
datetime       startTrackingTime = 0;   

datetime       timePauseEndTime = 0;
bool           timeActionTriggered = false;
bool           overrideTimeFilter = false;

bool           nextEntryAllowed = true;
datetime       nextEntryTime = 0;

bool           isDrawdownTriggered = false;
datetime       ddPauseEndTime = 0;

bool           g_isNewsTime = false;
bool           g_newsTriggeredByAction = false;
string         g_activeNewsName = "";

bool           g_licenseValid   = false;
datetime       g_licenseExpiry  = 0;
string         g_licenseMessage = "Belum diperiksa";

//--- Variabel Integrasi Web Panel
bool           g_botRunning     = true;   // dikontrol tombol Start/Stop di web
string         g_lastLogText    = "";
string         g_lastLogType    = "info";

//+------------------------------------------------------------------+
//| WEB INTEGRATION: Kirim snapshot data ke Vercel & ambil perintah  |
//+------------------------------------------------------------------+
string BuildStateJson()
{
    double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double floating = GetFloatingPnL();
    double achievedToday = GetDailyPnL() - floating;

    double buyLots = 0, sellLots = 0;
    int buyLayers = CountPositions(POSITION_TYPE_BUY);
    int sellLayers = CountPositions(POSITION_TYPE_SELL);
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(m_position.SelectByIndex(i)) {
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber) {
                if(m_position.PositionType() == POSITION_TYPE_BUY) buyLots += m_position.Volume();
                else if(m_position.PositionType() == POSITION_TYPE_SELL) sellLots += m_position.Volume();
            }
        }
    }

    double actualProfitTarget = (InpTargetMode == TARGET_PERCENT) ? balance * (DailyProfitValue / 100.0) : DailyProfitValue;
    double actualLossTarget   = (InpTargetMode == TARGET_PERCENT) ? balance * (DailyLossValue / 100.0) : DailyLossValue;

    string statusText;
    if(!g_botRunning) statusText = "STOPPED - Bot dihentikan dari web panel";
    else if(isTradingStoppedForDay) statusText = "STOPPED - Target harian tercapai";
    else if(isDrawdownTriggered) statusText = "STOPPED - Max drawdown tercapai";
    else statusText = "RUNNING - Grid aktif pada " + _Symbol;

    string licenseStatus = "UNKNOWN";
    if(!InpLicenseCheckEnabled) licenseStatus = "VALID";
    else licenseStatus = g_licenseValid ? "VALID" : "INVALID";

    string json = "{";
    json += "\"equity\":" + DoubleToString(equity, 2) + ",";
    json += "\"balance\":" + DoubleToString(balance, 2) + ",";
    json += "\"floating\":" + DoubleToString(floating, 2) + ",";
    json += "\"achievedToday\":" + DoubleToString(achievedToday, 2) + ",";
    json += "\"buyLayers\":" + IntegerToString(buyLayers) + ",";
    json += "\"sellLayers\":" + IntegerToString(sellLayers) + ",";
    json += "\"buyLots\":" + DoubleToString(buyLots, 2) + ",";
    json += "\"sellLots\":" + DoubleToString(sellLots, 2) + ",";
    json += "\"running\":" + (g_botRunning ? "true" : "false") + ",";
    json += "\"symbol\":\"" + _Symbol + "\",";
    json += "\"magicNumber\":" + IntegerToString((int)InpMagicNumber) + ",";
    json += "\"dailyTargetProfit\":" + DoubleToString(actualProfitTarget, 2) + ",";
    json += "\"dailyTargetLoss\":" + DoubleToString(actualLossTarget, 2) + ",";
    json += "\"statusText\":\"" + statusText + "\",";
    json += "\"licenseStatus\":\"" + licenseStatus + "\",";
    json += "\"startHour\":" + IntegerToString(InpStartHour) + ",";
    json += "\"startMinute\":" + IntegerToString(InpStartMinute) + ",";
    json += "\"endHour\":" + IntegerToString(InpEndHour) + ",";
    json += "\"endMinute\":" + IntegerToString(InpEndMinute) + ",";
    json += "\"accountLogin\":\"" + IntegerToString((int)AccountInfoInteger(ACCOUNT_LOGIN)) + "\",";
    json += "\"accountServer\":\"" + AccountInfoString(ACCOUNT_SERVER) + "\",";
    json += "\"licenseKeyHash\":\"" + LicenseKeyHash(InpLicenseKey) + "\"";

    if(g_lastLogText != "") {
        json += ",\"logText\":\"" + g_lastLogText + "\",\"logType\":\"" + g_lastLogType + "\"";
    }

    json += "}";
    return json;
}

void QueueWebLog(string text, string logType)
{
    g_lastLogText = text;
    g_lastLogType = logType;
}

// Ekstraksi nilai string sederhana dari JSON balasan server, contoh: "command":"START"
string ExtractJsonString(string json, string key)
{
    string searchKey = "\"" + key + "\":\"";
    int start = StringFind(json, searchKey);
    if(start < 0) return "";
    start += StringLen(searchKey);
    int end = StringFind(json, "\"", start);
    if(end < 0) return "";
    return StringSubstr(json, start, end - start);
}

void ExecuteWebCommand(string command)
{
    if(command == "" || command == "NONE") return;

    if(command == "START") {
        if(!g_botRunning) {
            g_botRunning = true;
            QueueWebLog("Bot dijalankan dari web panel", "profit");
        }
    }
    else if(command == "STOP") {
        if(g_botRunning) {
            g_botRunning = false;
            QueueWebLog("Bot dihentikan dari web panel", "warn");
        }
    }
    else if(command == "CLOSEALL") {
        CloseAllPositions();
        QueueWebLog("Semua posisi ditutup dari web panel", "loss");
    }
    else if(command == "RESET") {
        isTradingStoppedForDay = false;
        isDrawdownTriggered = false;
        g_newsTriggeredByAction = false;
        pauseEndTime = 0;
        ddPauseEndTime = 0;
        timePauseEndTime = 0;
        overrideTimeFilter = false;
        timeActionTriggered = false;
        startTrackingTime = TimeCurrent();
        QueueWebLog("Target harian direset dari web panel", "profit");
    }
}

// Kirim snapshot ke /api/ea-update (POST), sekaligus terima perintah tertunda di respons.
// Lalu polling /api/ea-command (GET) sebagai jalur cadangan bila EA sempat offline.
void SyncWithWebPanel()
{
    if(!InpWebEnabled) return;
    if(StringLen(InpWebBaseUrl) == 0) return;

    string headers = "Content-Type: application/json\r\nX-EA-Token: " + InpWebToken + "\r\n";
    string url = InpWebBaseUrl + "/api/ea-update";
    string payload = BuildStateJson();

    char postData[];
    StringToCharArray(payload, postData, 0, StringLen(payload));
    char result[];
    string resultHeaders;

    ResetLastError();
    int res = WebRequest("POST", url, headers, 5000, postData, result, resultHeaders);

    if(res == -1) {
        int err = GetLastError();
        if(err == 4060) {
            Print("WebRequest gagal (4060): tambahkan '", InpWebBaseUrl, "' ke Tools > Options > Expert Advisors > Allow WebRequest for listed URL");
        } else {
            Print("WebRequest ke ea-update gagal, error: ", err);
        }
        return;
    }

    // reset log yang sudah terkirim supaya tidak dikirim ulang
    g_lastLogText = "";

    string responseStr = CharArrayToString(result);
    string command = ExtractJsonString(responseStr, "command");
    if(command != "" && command != "null") {
        ExecuteWebCommand(command);
    }
}

//+------------------------------------------------------------------+
//| LISENSI: Checksum sederhana berbasis kode + tanggal + magic      |
//+------------------------------------------------------------------+
int LicenseChecksum(string block1, string block2, string block3, string accountStr, string dateStr)
{
    string raw = block1 + block2 + block3 + accountStr + dateStr + IntegerToString(InpMagicNumber);
    int sum = 0;
    for (int i = 0; i < StringLen(raw); i++)
    {
        sum = (sum * 31 + StringGetCharacter(raw, i)) % 9973;
    }
    return sum % 1000;
}

//+------------------------------------------------------------------+
//| LOGIN WEB: Hash kode lisensi (HARUS identik dgn simpleHash() di  |
//| lib/redis.js sisi server) — dikirim ke web sbg pengganti         |
//| password plaintext, supaya kode lisensi asli tidak bocor.        |
//+------------------------------------------------------------------+
string LicenseKeyHash(string key)
{
    string upperKey = key;
    StringToUpper(upperKey);
    long hash = 0;
    for (int i = 0; i < StringLen(upperKey); i++)
    {
        hash = (hash * 31 + StringGetCharacter(upperKey, i)) % 999999937;
    }
    return IntegerToString((int)hash);
}

//+------------------------------------------------------------------+
//| LISENSI: Validasi format & isi kode lisensi yang dimasukkan user |
//+------------------------------------------------------------------+
bool ValidateLicense(string key, datetime &expiryOut, string &msgOut)
{
    expiryOut = 0;
    msgOut = "";

    if (StringLen(key) == 0)
    {
        msgOut = "Hubungi TG:daiilytrader";
        return false;
    }

    string parts[];
    int n = StringSplit(key, '-', parts);
    if (n != 6)
    {
        msgOut = "Format kode tidak valid";
        return false;
    }

    string block1     = parts[0];
    string block2     = parts[1];
    string block3     = parts[2];
    string accountStr = parts[3];
    string dateStr    = parts[4];
    string chkStr      = parts[5];

    if (StringLen(block1) != 4 || StringLen(block2) != 4 || StringLen(block3) != 4)
    {
        msgOut = "Format blok kode tidak valid";
        return false;
    }
    if (StringLen(accountStr) == 0 || StringLen(accountStr) > 15)
    {
        msgOut = "Format nomor akun tidak valid";
        return false;
    }
    if (StringLen(dateStr) != 8)
    {
        msgOut = "Format tanggal expire tidak valid";
        return false;
    }
    if (StringLen(chkStr) != 3)
    {
        msgOut = "Format checksum tidak valid";
        return false;
    }

    int yyyy = (int)StringToInteger(StringSubstr(dateStr, 0, 4));
    int mm   = (int)StringToInteger(StringSubstr(dateStr, 4, 2));
    int dd   = (int)StringToInteger(StringSubstr(dateStr, 6, 2));
    if (yyyy < 2020 || yyyy > 2100 || mm < 1 || mm > 12 || dd < 1 || dd > 31)
    {
        msgOut = "Tanggal expire tidak valid";
        return false;
    }

    int expectedChk = LicenseChecksum(block1, block2, block3, accountStr, dateStr);
    int actualChk   = (int)StringToInteger(chkStr);
    if (expectedChk != actualChk)
    {
        msgOut = "Checksum tidak cocok - kode invalid atau diubah";
        return false;
    }

    long boundAccount   = StringToInteger(accountStr);
    long currentAccount = AccountInfoInteger(ACCOUNT_LOGIN);
    if (boundAccount != currentAccount)
    {
        msgOut = "Lisensi ini terdaftar untuk akun #" + accountStr + ", bukan akun ini (#" + IntegerToString((int)currentAccount) + ")";
        return false;
    }

    MqlDateTime dtExp;
    dtExp.year = yyyy; dtExp.mon = mm; dtExp.day = dd;
    dtExp.hour = 23; dtExp.min = 59; dtExp.sec = 59;
    datetime expiry = StructToTime(dtExp);
    expiryOut = expiry;

    if (TimeCurrent() > expiry)
    {
        msgOut = "Lisensi sudah EXPIRED";
        return false;
    }

    msgOut = "Lisensi valid";
    return true;
}

//--- Panel Info Professional
string panelPrefix   = "PI_";
string panelBG        = "PI_BG";
string panelHeaderBG  = "PI_HEADER_BG";
string panelTitle     = "PI_TITLE";
string panelFooterLn  = "PI_FOOTLINE";
string btnCloseAll    = "PI_BTN_CLOSEALL";
string btnResetTarget = "PI_BTN_RESETTARGET";

int    PANEL_WIDTH   = 420;   
int    PANEL_HEIGHT  = 232;   
int    BUTTON_HEIGHT = 24;    

void CreateButton(string name, int x, int y, int w, int h, string text, color bg, color border, color txtClr, int fontSize, string font)
{
    ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
    ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, txtClr);
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
    ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, border);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
    ObjectSetString(0, name, OBJPROP_FONT, font + " Bold");
    ObjectSetInteger(0, name, OBJPROP_STATE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

void CreateRect(string name, int x, int y, int w, int h, color bg, color border, int borderWidth = 1)
{
    ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
    ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
    ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, name, OBJPROP_COLOR, border);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, borderWidth);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void CreateLabelText(string name, int x, int y, string text, color clr, int fontSize = 9, string font = "Consolas", bool bold = false)
{
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
    ObjectSetString(0, name, OBJPROP_FONT, bold ? font + " Bold" : font);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

void CreateDivider(string name, int x, int y, int w)
{
    CreateRect(name, x, y, w, 1, InpColorDivider, InpColorDivider, 0);
}

void DeletePanelObjects()
{
    ObjectsDeleteAll(0, panelPrefix);
}

void CreatePanelInfo()
{
    DeletePanelObjects();
    if (!InpShowPanel) return;

    int x0 = InpPanelX;
    int y0 = InpPanelY;
    PANEL_WIDTH = InpPanelWidth;
    int rowH    = InpPanelRowHeight;
    int fontSz  = InpPanelFontSize;
    string fnt  = InpPanelFont;

    CreateRect(panelBG, x0, y0, PANEL_WIDTH, PANEL_HEIGHT, InpColorBackground, InpColorBorder, 1);

    int headerH = InpPanelHeaderHeight;
    CreateRect(panelHeaderBG, x0, y0, PANEL_WIDTH, headerH, InpColorHeaderBG, InpColorHeaderBG, 0);
    CreateLabelText(panelTitle, x0 + 12, y0 + (headerH - InpPanelTitleFontSize - 4) / 2 + 2, "GOLDEN CENT SCALPER PRO", InpColorTitleText, InpPanelTitleFontSize, fnt, true);

    int col1X = x0 + 14;
    int y = y0 + headerH + 10;

    // --- Section 0: Lisensi ---
    CreateLabelText(panelPrefix + "sec0", col1X, y, "LISENSI", InpColorSectionText, fontSz, fnt, true);
    y += rowH;
    CreateDivider(panelPrefix + "div0", x0 + 12, y - 4, PANEL_WIDTH - 24);

    CreatePanelRow(col1X, y, "Status Lisensi", "licStatus", "MEMERIKSA...");
    y += rowH;
    CreatePanelRow(col1X, y, "Expired Pada", "licExpiry", "-");
    y += rowH + 8;

    // --- Section 1: Konfigurasi ---
    CreateLabelText(panelPrefix + "sec1", col1X, y, "KONFIGURASI", InpColorSectionText, fontSz, fnt, true);
    y += rowH;
    CreateDivider(panelPrefix + "div1", x0 + 12, y - 4, PANEL_WIDTH - 24);

    CreatePanelRow(col1X, y, "Symbol", "symbolName", _Symbol);
    y += rowH;
    CreatePanelRow(col1X, y, "Tipe Akun", "accountType", "DEMO");
    y += rowH;
    CreatePanelRow(col1X, y, "Lot Awal", "lotInitial", "0.01");
    y += rowH;
    CreatePanelRow(col1X, y, "Mode Pengadaan", "lotMode", "PERKALIAN");
    y += rowH;
    CreatePanelRow(col1X, y, "Lot Perkalian", "lotMultiplier", "1.50");
    y += rowH;
    CreatePanelRow(col1X, y, "Jarak Antar Layer", "gridDist", "200 pts");
    y += rowH;
    CreatePanelRow(col1X, y, "Maxsimal Lot", "maxLot", UseMaxLot ? DoubleToString(InpMaxLot, 2) : "OFF");
    y += rowH + 8;

    // --- Section 2: Akun & Target ---
    CreateLabelText(panelPrefix + "sec2", col1X, y, "AKUN & TARGET", InpColorSectionText, fontSz, fnt, true);
    y += rowH;
    CreateDivider(panelPrefix + "div2", x0 + 12, y - 4, PANEL_WIDTH - 24);

    CreatePanelRow(col1X, y, "Equity", "equity", "0.00");
    y += rowH;
    CreatePanelRow(col1X, y, "Balance", "balance", "0.00");
    y += rowH;
    CreatePanelRow(col1X, y, "P/L Harian", "pnl", "0.00");
    y += rowH;
    CreatePanelRow(col1X, y, "Target Cycle", "targetCycle", "0.00");
    y += rowH;
    CreatePanelRow(col1X, y, "Target Daily", "targetDaily", "0.00");
    y += rowH;
    CreatePanelRow(col1X, y, "Target Tercapai", "targetAchieved", "0.00");
    y += rowH;
    CreatePanelRow(col1X, y, "Drawdown Angka", "ddAngka", "0.00");
    y += rowH;
    CreatePanelRow(col1X, y, "Drawdown Persen", "ddPersen", "0.00%");
    y += rowH;
    
    CreatePanelRow(col1X, y, "Layer Buy / Sell", "layersCount", "0 / 0");
    y += rowH;
    CreatePanelRow(col1X, y, "Lot Buy / Sell", "lotsCount", "0.00 / 0.00");
    y += rowH;
    CreatePanelRow(col1X, y, "Total Lot", "totalLots", "0.00");
    y += rowH;
    
    CreatePanelRow(col1X, y, "News Status", "newsStatus", "AMAN");
    y += rowH;
    CreatePanelRow(col1X, y, "Magic Number", "magic", IntegerToString(InpMagicNumber));

    y += rowH + 6;
    CreateDivider(panelFooterLn, x0 + 12, y, PANEL_WIDTH - 24);
    y += 6;
    CreateLabelText(panelPrefix + "status", col1X, y, "Status: RUNNING", InpColorProfit, fontSz, fnt, true);

    y += rowH + 8;
    int btnGap = 8;
    int btnW = (PANEL_WIDTH - 24 - btnGap) / 2;
    int btnY = y;

    CreateButton(btnCloseAll, col1X, btnY, btnW, BUTTON_HEIGHT, "CLOSE ALL",
                 C'140,40,40', C'200,70,70', clrWhite, fontSz, fnt);
    CreateButton(btnResetTarget, col1X + btnW + btnGap, btnY, btnW, BUTTON_HEIGHT, "RESET TARGET",
                 C'40,90,140', C'70,140,200', clrWhite, fontSz, fnt);

    y = btnY + BUTTON_HEIGHT;

    int neededHeight = (y + 10) - y0;
    if (neededHeight > 0)
    {
        PANEL_HEIGHT = neededHeight;
        ObjectSetInteger(0, panelBG, OBJPROP_YSIZE, PANEL_HEIGHT);
    }
}

void CreatePanelRow(int x, int y, string labelText, string labelName, string valueText)
{
    string labelFull = panelPrefix + labelName;
    CreateLabelText(labelFull, x, y, labelText, InpColorLabelText, InpPanelFontSize, InpPanelFont, false);

    string valueFull = labelFull + "_val";
    // Offset 165 agar label panjang (Target Tercapai, Drawdown Angka, dll) tidak bertabrakan
    CreateLabelText(valueFull, x + 165, y, valueText, InpColorValueText, InpPanelFontSize, InpPanelFont, true);
}

//+------------------------------------------------------------------+
//| Hitung Target Cycle saat ini (ikut Dynamic TP 1 & 2 jika aktif)  |
//+------------------------------------------------------------------+
string GetCurrentCycleTargetText()
{
    // Hitung total volume & layer untuk kedua arah (ambil yang terbesar agar mewakili kondisi dinamis)
    double totalVolumeBuy = 0, totalVolumeSell = 0;
    int    layersBuy = 0, layersSell = 0;

    for(int i = PositionsTotal() - 1; i >= 0; i--)
    {
        if(m_position.SelectByIndex(i))
        {
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber)
            {
                if(m_position.PositionType() == POSITION_TYPE_BUY)
                {
                    totalVolumeBuy += m_position.Volume();
                    layersBuy++;
                }
                else if(m_position.PositionType() == POSITION_TYPE_SELL)
                {
                    totalVolumeSell += m_position.Volume();
                    layersSell++;
                }
            }
        }
    }

    double totalVolume = MathMax(totalVolumeBuy, totalVolumeSell);
    int    totalLayers = MathMax(layersBuy, layersSell);

    // Target dasar
    double targetProfit = 0;
    string baseTxt = "";

    if (InpTPMode == TP_POINTS)
    {
        double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
        double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
        if (tickSize > 0 && totalVolume > 0)
            targetProfit = totalVolume * (InpTakeProfitPoints * _Point) * (tickValue / tickSize);
        else
            targetProfit = 0;
        baseTxt = IntegerToString(InpTakeProfitPoints) + " pts";
    }
    else // TP_USD
    {
        targetProfit = InpTakeProfitUSD;
        baseTxt = DoubleToString(InpTakeProfitUSD, 2);
    }

    // Dynamic TP 1 override
    bool dynamicActive1 = false;
    if (UseDynamicTP1 && InpDynamicTPMode1 != DTP_MODE_NONE)
    {
        if ((InpDynamicTPMode1 == DTP_MODE_LAYER && InpLayersToChangeTP1 > 0 && totalLayers >= InpLayersToChangeTP1) ||
            (InpDynamicTPMode1 == DTP_MODE_LOT && InpLotToChangeTP1 > 0 && totalVolume >= InpLotToChangeTP1))
        {
            if (InpDynamicTPValueMode1 == DTP_VALUE_POINTS)
            {
                double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
                double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
                if (tickSize > 0 && totalVolume > 0)
                    targetProfit = totalVolume * (InpDynamicTPPoints1 * _Point) * (tickValue / tickSize);
                else
                    targetProfit = 0;
            }
            else // DTP_VALUE_USD
            {
                targetProfit = InpDynamicTPUSD1;
            }
            dynamicActive1 = true;
        }
    }

    // Dynamic TP 2 override (Prioritas lebih tinggi jika terpenuhi)
    bool dynamicActive2 = false;
    if (UseDynamicTP2 && InpDynamicTPMode2 != DTP_MODE_NONE)
    {
        if ((InpDynamicTPMode2 == DTP_MODE_LAYER && InpLayersToChangeTP2 > 0 && totalLayers >= InpLayersToChangeTP2) ||
            (InpDynamicTPMode2 == DTP_MODE_LOT && InpLotToChangeTP2 > 0 && totalVolume >= InpLotToChangeTP2))
        {
            if (InpDynamicTPValueMode2 == DTP_VALUE_POINTS)
            {
                double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
                double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
                if (tickSize > 0 && totalVolume > 0)
                    targetProfit = totalVolume * (InpDynamicTPPoints2 * _Point) * (tickValue / tickSize);
                else
                    targetProfit = 0;
            }
            else // DTP_VALUE_USD
            {
                targetProfit = InpDynamicTPUSD2;
            }
            dynamicActive2 = true;
        }
    }

    // Format tampilan
    if (totalVolume <= 0 && InpTPMode == TP_POINTS)
    {
        if (UseDynamicTP2 && InpDynamicTPMode2 != DTP_MODE_NONE)
        {
            if (InpDynamicTPValueMode2 == DTP_VALUE_POINTS)
                return baseTxt + " (Dyn2: " + IntegerToString(InpDynamicTPPoints2) + " pts)";
            else
                return baseTxt + " (Dyn2: $" + DoubleToString(InpDynamicTPUSD2, 2) + ")";
        }
        else if (UseDynamicTP1 && InpDynamicTPMode1 != DTP_MODE_NONE)
        {
            if (InpDynamicTPValueMode1 == DTP_VALUE_POINTS)
                return baseTxt + " (Dyn1: " + IntegerToString(InpDynamicTPPoints1) + " pts)";
            else
                return baseTxt + " (Dyn1: $" + DoubleToString(InpDynamicTPUSD1, 2) + ")";
        }
        return baseTxt;
    }

    string result = DoubleToString(targetProfit, 2);
    if (dynamicActive2)
        result += " (DYN2)";
    else if (dynamicActive1)
        result += " (DYN1)";
    else if ((UseDynamicTP1 && InpDynamicTPMode1 != DTP_MODE_NONE) || (UseDynamicTP2 && InpDynamicTPMode2 != DTP_MODE_NONE))
        result += " (base)";

    return result;
}

void UpdatePanelInfo()
{
    if (!InpShowPanel) return;
    if (ObjectFind(0, panelBG) < 0) { CreatePanelInfo(); }

    string licStatusText;
    color  licStatusClr;
    if (!InpLicenseCheckEnabled)
    {
        licStatusText = "TIDAK AKTIF (Cek Nonaktif)";
        licStatusClr  = InpColorWarning;
    }
    else if (g_licenseValid)
    {
        licStatusText = "VALID";
        licStatusClr  = InpColorProfit;
    }
    else
    {
        licStatusText = "INVALID (" + g_licenseMessage + ")";
        licStatusClr  = InpColorLoss;
    }
    ObjectSetString(0, panelPrefix + "licStatus_val", OBJPROP_TEXT, licStatusText);
    ObjectSetInteger(0, panelPrefix + "licStatus_val", OBJPROP_COLOR, licStatusClr);

    string licExpiryText = (g_licenseExpiry > 0) ? TimeToString(g_licenseExpiry, TIME_DATE) : "-";
    color  licExpiryClr  = InpColorValueText;
    if (g_licenseExpiry > 0)
    {
        int daysLeft = (int)((g_licenseExpiry - TimeCurrent()) / 86400);
        if (daysLeft < 0) licExpiryClr = InpColorLoss;
        else if (daysLeft <= 7) licExpiryClr = InpColorWarning;
        else licExpiryClr = InpColorProfit;
        if (daysLeft >= 0) licExpiryText += " (" + IntegerToString(daysLeft) + " hari lagi)";
    }
    ObjectSetString(0, panelPrefix + "licExpiry_val", OBJPROP_TEXT, licExpiryText);
    ObjectSetInteger(0, panelPrefix + "licExpiry_val", OBJPROP_COLOR, licExpiryClr);

    ObjectSetString(0, panelPrefix + "symbolName_val", OBJPROP_TEXT, _Symbol);

    ENUM_ACCOUNT_TRADE_MODE tradeMode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
    string accTypeStr = "DEMO";
    color  accTypeClr = InpColorProfit;
    if (tradeMode == ACCOUNT_TRADE_MODE_REAL)    { accTypeStr = "REAL";    accTypeClr = InpColorLoss; }
    else if (tradeMode == ACCOUNT_TRADE_MODE_CONTEST) { accTypeStr = "CONTEST"; accTypeClr = InpColorWarning; }
    else { accTypeStr = "DEMO"; accTypeClr = InpColorProfit; }
    ObjectSetString(0, panelPrefix + "accountType_val", OBJPROP_TEXT, accTypeStr);
    ObjectSetInteger(0, panelPrefix + "accountType_val", OBJPROP_COLOR, accTypeClr);

    ObjectSetString(0, panelPrefix + "lotInitial_val", OBJPROP_TEXT, DoubleToString(InpInitialLot, 2));

    string lotModeStr = (InpLotMode == LOT_LINEAR) ? "LINEAR" : "PERKALIAN";
    ObjectSetString(0, panelPrefix + "lotMode_val", OBJPROP_TEXT, lotModeStr);

    ObjectSetString(0, panelPrefix + "lotMultiplier_val", OBJPROP_TEXT, DoubleToString(InpLotMultiplier, 2));
    ObjectSetString(0, panelPrefix + "gridDist_val", OBJPROP_TEXT, IntegerToString(InpGridDistance) + " pts");
    ObjectSetString(0, panelPrefix + "maxLot_val", OBJPROP_TEXT, UseMaxLot ? DoubleToString(InpMaxLot, 2) : "OFF");

    double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double pnl     = GetDailyPnL();
    double floatingPnL = GetFloatingPnL();
    double closedPnL = pnl - floatingPnL;   // Target Tercapai (profit yang sudah close)

    ObjectSetString(0, panelPrefix + "equity_val", OBJPROP_TEXT, DoubleToString(equity, 2));
    ObjectSetString(0, panelPrefix + "balance_val", OBJPROP_TEXT, DoubleToString(balance, 2));

    ObjectSetString(0, panelPrefix + "pnl_val", OBJPROP_TEXT, DoubleToString(pnl, 2));
    ObjectSetInteger(0, panelPrefix + "pnl_val", OBJPROP_COLOR, (pnl >= 0) ? InpColorProfit : InpColorLoss);

    // --- Target Cycle (TP basket, mengikuti Dynamic TP jika aktif) ---
    string cycleTxt = GetCurrentCycleTargetText();
    ObjectSetString(0, panelPrefix + "targetCycle_val", OBJPROP_TEXT, cycleTxt);

    // --- Target Daily: jika % tampilkan "10.00% ($1000.00)", jika fixed tampilkan nilai fix ---
    double actualProfitTarget = (InpTargetMode == TARGET_PERCENT) ? balance * (DailyProfitValue / 100.0) : DailyProfitValue;
    double actualLossTarget   = (InpTargetMode == TARGET_PERCENT) ? balance * (DailyLossValue / 100.0)   : DailyLossValue;

    string dailyTxt = "OFF";
    if (UseDailyProfit || UseDailyLoss)
    {
        if (InpTargetMode == TARGET_PERCENT)
        {
            string profitPart = UseDailyProfit
                ? (DoubleToString(DailyProfitValue, 2) + "% ($" + DoubleToString(actualProfitTarget, 2) + ")")
                : "-";
            string lossPart = UseDailyLoss
                ? ("-" + DoubleToString(DailyLossValue, 2) + "% ($" + DoubleToString(actualLossTarget, 2) + ")")
                : "-";
            dailyTxt = profitPart + " / " + lossPart;
        }
        else
        {
            string profitPart = UseDailyProfit ? ("+$" + DoubleToString(actualProfitTarget, 2)) : "-";
            string lossPart   = UseDailyLoss   ? ("-$" + DoubleToString(actualLossTarget, 2))   : "-";
            dailyTxt = profitPart + " / " + lossPart;
        }
    }
    ObjectSetString(0, panelPrefix + "targetDaily_val", OBJPROP_TEXT, dailyTxt);

    // --- Target Tercapai (profit yang sudah close hari ini) ---
    ObjectSetString(0, panelPrefix + "targetAchieved_val", OBJPROP_TEXT, DoubleToString(closedPnL, 2));
    ObjectSetInteger(0, panelPrefix + "targetAchieved_val", OBJPROP_COLOR, (closedPnL >= 0) ? InpColorProfit : InpColorLoss);

    // --- Drawdown Angka (floating loss dalam $) ---
    double ddAngka = (floatingPnL < 0) ? floatingPnL : 0.0;
    ObjectSetString(0, panelPrefix + "ddAngka_val", OBJPROP_TEXT, DoubleToString(ddAngka, 2));
    ObjectSetInteger(0, panelPrefix + "ddAngka_val", OBJPROP_COLOR, (ddAngka < 0) ? InpColorLoss : InpColorValueText);

    // --- Drawdown Persen (floating loss dalam % terhadap balance) ---
    double ddPersen = 0.0;
    if (balance > 0 && floatingPnL < 0)
        ddPersen = (MathAbs(floatingPnL) / balance) * 100.0;
    ObjectSetString(0, panelPrefix + "ddPersen_val", OBJPROP_TEXT, DoubleToString(ddPersen, 2) + "%");
    ObjectSetInteger(0, panelPrefix + "ddPersen_val", OBJPROP_COLOR, (ddPersen > 0) ? InpColorLoss : InpColorValueText);

    int buyLayers = CountPositions(POSITION_TYPE_BUY);
    int sellLayers = CountPositions(POSITION_TYPE_SELL);
    double buyLots = 0.0;
    double sellLots = 0.0;

    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(m_position.SelectByIndex(i)) {
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber) {
                if(m_position.PositionType() == POSITION_TYPE_BUY)
                    buyLots += m_position.Volume();
                else if(m_position.PositionType() == POSITION_TYPE_SELL)
                    sellLots += m_position.Volume();
            }
        }
    }
    double totalLotsSum = buyLots + sellLots;

    ObjectSetString(0, panelPrefix + "layersCount_val", OBJPROP_TEXT, IntegerToString(buyLayers) + " / " + IntegerToString(sellLayers));
    ObjectSetString(0, panelPrefix + "lotsCount_val", OBJPROP_TEXT, DoubleToString(buyLots, 2) + " / " + DoubleToString(sellLots, 2));
    ObjectSetString(0, panelPrefix + "totalLots_val", OBJPROP_TEXT, DoubleToString(totalLotsSum, 2));

    string newsTxt = "AMAN";
    color  newsClr = InpColorProfit;
    if (UseNewsFilter && g_isNewsTime) {
        newsTxt = "BERITA (" + g_activeNewsName + ")";
        newsClr = InpColorLoss;
    }
    ObjectSetString(0, panelPrefix + "newsStatus_val", OBJPROP_TEXT, newsTxt);
    ObjectSetInteger(0, panelPrefix + "newsStatus_val", OBJPROP_COLOR, newsClr);

    ObjectSetString(0, panelPrefix + "magic_val", OBJPROP_TEXT, IntegerToString(InpMagicNumber));

    string statusText = "Status: RUNNING";
    color  statusClr   = InpColorProfit;
    if (isTradingStoppedForDay) { statusText = "Status: STOPPED (Target Harian Tercapai)"; statusClr = InpColorLoss; }
    else if (isDrawdownTriggered) { statusText = "Status: STOPPED (Max Drawdown)"; statusClr = InpColorLoss; }
    else if (g_newsTriggeredByAction) { statusText = "Status: STOPPED (News Action)"; statusClr = InpColorLoss; }
    else if (ddPauseEndTime > 0 && TimeCurrent() < ddPauseEndTime) { statusText = "Status: PAUSED (DD Jeda)"; statusClr = InpColorWarning; }
    else if (UseNewsFilter && g_isNewsTime) { statusText = "Status: PAUSED (News Filter)"; statusClr = InpColorWarning; }
    else if (pauseEndTime > 0)  { statusText = "Status: PAUSED"; statusClr = InpColorWarning; }
    else if (!IsTradingTimeWIB()) { statusText = "Status: OUTSIDE TRADING HOURS"; statusClr = InpColorWarning; }

    ObjectSetString(0, panelPrefix + "status", OBJPROP_TEXT, statusText);
    ObjectSetInteger(0, panelPrefix + "status", OBJPROP_COLOR, statusClr);
}

int OnInit() {
    if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
        Alert("EA ini hanya berjalan di akun Hedging!");
        return(INIT_FAILED);
    }
    if (InpLayerStep < 1) {
        Alert("InpLayerStep minimal harus 1!");
        return(INIT_FAILED);
    }

    if (InpLicenseCheckEnabled)
    {
        g_licenseValid = ValidateLicense(InpLicenseKey, g_licenseExpiry, g_licenseMessage);
        if (!g_licenseValid)
        {
            Alert("Lisensi EA tidak valid: ", g_licenseMessage, ". EA tidak akan melakukan entry baru.");
        }
    }
    else
    {
        g_licenseValid = true; 
        g_licenseMessage = "Pengecekan lisensi dinonaktifkan";
    }
    
    trade.SetExpertMagicNumber(InpMagicNumber);
    trade.SetDeviationInPoints(InpSlippage);
    startTrackingTime = GetStartOfDay(TimeCurrent());
    
    CreatePanelInfo();
    UpdatePanelInfo();

    if(InpWebEnabled) {
        int intervalSec = (InpWebIntervalSec < 1) ? 1 : InpWebIntervalSec;
        EventSetTimer(intervalSec);
        QueueWebLog("EA terhubung ke web panel pada " + _Symbol, "info");
        SyncWithWebPanel();
    }
    
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    if(InpWebEnabled) EventKillTimer();
    DeletePanelObjects();
    ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Timer: dipanggil tiap InpWebIntervalSec detik untuk sinkronisasi |
//| data real-time dengan web panel (Vercel)                         |
//+------------------------------------------------------------------+
void OnTimer()
{
    SyncWithWebPanel();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if (id != CHARTEVENT_OBJECT_CLICK) return;

    if (sparam == btnCloseAll)
    {
        CloseAllPositions();
        QueueWebLog("Semua posisi ditutup dari panel chart MT5", "loss");
        ObjectSetInteger(0, btnCloseAll, OBJPROP_STATE, false);
        UpdatePanelInfo();
        ChartRedraw(0);
        return;
    }

    if (sparam == btnResetTarget)
    {
        isTradingStoppedForDay = false;
        isDrawdownTriggered = false;
        g_newsTriggeredByAction = false;
        pauseEndTime = 0;
        ddPauseEndTime = 0;
        timePauseEndTime = 0;
        overrideTimeFilter = false;
        timeActionTriggered = false;
        startTrackingTime = TimeCurrent();
        QueueWebLog("Target harian direset dari panel chart MT5", "profit");
        ObjectSetInteger(0, btnResetTarget, OBJPROP_STATE, false);
        UpdatePanelInfo();
        ChartRedraw(0);
        return;
    }
}

//+------------------------------------------------------------------+
//| FUNGSI PEMERIKSAAN KALENDER NEWS MT5 & AKSI                      |
//+------------------------------------------------------------------+
bool CheckNewsFilter()
{
    if (!UseNewsFilter) return false;
    if (g_newsTriggeredByAction) return true;

    datetime currentTime = TimeCurrent();
    datetime fromTime = currentTime - (InpNewsMinutesAfter * 60);
    datetime toTime = currentTime + (InpNewsMinutesBefore * 60);

    MqlCalendarValue values[];
    
    if (CalendarValueHistory(values, fromTime, toTime))
    {
        int totalValues = ArraySize(values);
        for (int i = 0; i < totalValues; i++)
        {
            MqlCalendarEvent event;
            if (CalendarEventById(values[i].event_id, event))
            {
                int importance = event.importance;
                bool checkImpact = false;

                if (InpNewsMode == NEWS_MODE_LOW)
                {
                    if (importance <= 2) checkImpact = true;
                }
                else if (InpNewsMode == NEWS_MODE_MEDIUM)
                {
                    if (importance >= 1) checkImpact = true;
                }
                else if (InpNewsMode == NEWS_MODE_HIGH)
                {
                    if (importance >= 2) checkImpact = true;
                }

                if (checkImpact)
                {
                    bool matchPair = true;
                    if (UseNewsPairOnly)
                    {
                        matchPair = (StringFind(_Symbol, event.name) >= 0 || StringFind(event.name, StringSubstr(_Symbol, 0, 3)) >= 0 || StringFind(event.name, StringSubstr(_Symbol, 3, 3)) >= 0);
                    }

                    if (matchPair)
                    {
                        g_activeNewsName = event.name;
                        g_isNewsTime = true;

                        int totalPos = CountPositions(POSITION_TYPE_BUY) + CountPositions(POSITION_TYPE_SELL);

                        if (InpNewsAction == NEWS_ACTION_CYCLE_STOP)
                        {
                            if (totalPos == 0) g_newsTriggeredByAction = true;
                        }
                        else if (InpNewsAction == NEWS_ACTION_CLOSE_STOP)
                        {
                            CloseAllPositions();
                            g_newsTriggeredByAction = true;
                        }
                        else if (InpNewsAction == NEWS_ACTION_CYCLE_REMOVE)
                        {
                            if (totalPos == 0) ExpertRemove();
                        }
                        else if (InpNewsAction == NEWS_ACTION_CLOSE_REMOVE)
                        {
                            CloseAllPositions();
                            ExpertRemove();
                        }
                        else if (InpNewsAction == NEWS_ACTION_PAUSE_ENTRY)
                        {
                            return true;
                        }

                        return true;
                    }
                }
            }
        }
    }

    g_isNewsTime = false;
    g_activeNewsName = "";
    return false;
}

bool CheckMaxDrawdown()
{
    if (!UseMaxDrawdown) return false;
    if (isDrawdownTriggered) return true;

    if (ddPauseEndTime > 0)
    {
        if (TimeCurrent() < ddPauseEndTime) return true;
        else
        {
            ddPauseEndTime = 0;
            startTrackingTime = TimeCurrent();
        }
    }

    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double floatingPL = GetFloatingPnL();

    bool isHit = false;

    if (InpDDMode == DD_MODE_USD)
    {
        if (floatingPL <= -MathAbs(InpDDValue)) isHit = true;
    }
    else if (InpDDMode == DD_MODE_PERCENT)
    {
        double currentDDPercent = ((balance - equity) / balance) * 100.0;
        if (currentDDPercent >= MathAbs(InpDDValue)) isHit = true;
    }

    if (isHit)
    {
        CloseAllPositions();
        if (InpDDAction == DD_ACTION_CLOSE_STOP) isDrawdownTriggered = true;
        else if (InpDDAction == DD_ACTION_CLOSE_REMOVE) ExpertRemove();
        else if (InpDDAction == DD_ACTION_CLOSE_PAUSE) ddPauseEndTime = TimeCurrent() + (InpDDPauseMinutes * 60);
        return true;
    }
    return false;
}

void OnTick() {
    datetime currentTickTime = TimeCurrent();

    // --- KONTROL START/STOP DARI WEB PANEL ---
    // Saat bot dihentikan dari web, EA tetap menutup TP yang sudah tercapai
    // (agar posisi terbuka tidak menggantung tanpa pengawasan) tapi tidak entry baru.
    if (!g_botRunning) {
        CheckAndCloseTP(POSITION_TYPE_BUY);
        CheckAndCloseTP(POSITION_TYPE_SELL);
        UpdatePanelInfo();
        return;
    }

    if (InpLicenseCheckEnabled) {
        bool stillValid = (g_licenseExpiry > 0 && currentTickTime <= g_licenseExpiry);
        if (g_licenseValid && !stillValid) {
            g_licenseValid = false;
            g_licenseMessage = "Lisensi sudah EXPIRED";
            UpdatePanelInfo();
        }
    }
    
    if(GetDay(currentTickTime) != currentDay) {
        currentDay = GetDay(currentTickTime);
        isTradingStoppedForDay = false; 
        isDrawdownTriggered = false;
        g_newsTriggeredByAction = false;
        pauseEndTime = 0;
        ddPauseEndTime = 0;
        timePauseEndTime = 0;
        overrideTimeFilter = false;
        startTrackingTime = GetStartOfDay(currentTickTime); 
        nextEntryAllowed = true;
        nextEntryTime = 0;
    }

    if (InpTargetAction == ACTION_PAUSE_MINUTES && pauseEndTime > 0) {
        if (currentTickTime < pauseEndTime) { UpdatePanelInfo(); return; }
        else {
            pauseEndTime = 0; 
            startTrackingTime = currentTickTime; 
        }
    }

    if (CheckNewsFilter()) { UpdatePanelInfo(); return; }
    if (g_newsTriggeredByAction) { UpdatePanelInfo(); return; }

    if (CheckMaxDrawdown()) { UpdatePanelInfo(); return; }
    if (CheckDailyTarget()) { UpdatePanelInfo(); return; }
    if (isTradingStoppedForDay) { UpdatePanelInfo(); return; }

    // --- INTEGRASI AKSI SAAT LISENSI EXPIRED / INVALID (Mode 1 - 4) ---
    if (InpLicenseCheckEnabled && !g_licenseValid) {
        int totalBuyPos  = CountPositions(POSITION_TYPE_BUY);
        int totalSellPos = CountPositions(POSITION_TYPE_SELL);
        int totalAllPos  = totalBuyPos + totalSellPos;

        switch (InpLicenseAction) {
            case LICENSE_ACTION_FINISH_CYCLE_STOP:
                CheckAndCloseTP(POSITION_TYPE_BUY);
                CheckAndCloseTP(POSITION_TYPE_SELL);
                if (CountPositions(POSITION_TYPE_BUY) == 0 && CountPositions(POSITION_TYPE_SELL) == 0) {
                    isTradingStoppedForDay = true;
                }
                break;

            case LICENSE_ACTION_FINISH_CYCLE_REMOVE:
                CheckAndCloseTP(POSITION_TYPE_BUY);
                CheckAndCloseTP(POSITION_TYPE_SELL);
                if (CountPositions(POSITION_TYPE_BUY) == 0 && CountPositions(POSITION_TYPE_SELL) == 0) {
                    ExpertRemove();
                }
                break;

            case LICENSE_ACTION_CLOSE_STOP:
                if (totalAllPos > 0) {
                    CloseAllPositions();
                }
                isTradingStoppedForDay = true;
                break;

            case LICENSE_ACTION_CLOSE_REMOVE:
                if (totalAllPos > 0) {
                    CloseAllPositions();
                }
                ExpertRemove();
                break;
        }

        UpdatePanelInfo();
        return;
    }

    int totalBuys = CountPositions(POSITION_TYPE_BUY);
    int totalSells = CountPositions(POSITION_TYPE_SELL);
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    
    CheckAndCloseTP(POSITION_TYPE_BUY);
    CheckAndCloseTP(POSITION_TYPE_SELL);
    
    totalBuys = CountPositions(POSITION_TYPE_BUY);
    totalSells = CountPositions(POSITION_TYPE_SELL);

    if (totalBuys > 0 || totalSells > 0) timeActionTriggered = false;

    if (timePauseEndTime > 0 && currentTickTime >= timePauseEndTime) {
        timePauseEndTime = 0;
        overrideTimeFilter = true; 
    }

    // --- INTEGRASI CUT LOSE JAM TRADING SAAT TARGET HARIAN / DILUAR WAKTU ---
    if (UseTimeFilter && !IsTradingTimeWIB()) {
        if (UseTimeOutCutLoss && (totalBuys > 0 || totalSells > 0)) {
            double currentFloating = GetFloatingPnL();
            if (currentFloating <= -TimeOutCutLossUSD) {
                CloseAllPositions();
                totalBuys = 0; 
                totalSells = 0;
            }
        }

        if (totalBuys == 0 && totalSells == 0) {
            if (!timeActionTriggered) {
                if (InpTimeEndAction == ACTION_REMOVE_EA) { ExpertRemove(); return; }
                else if (InpTimeEndAction == ACTION_PAUSE_MINUTES) { timePauseEndTime = currentTickTime + (InpTimePauseMinutes * 60); }
                timeActionTriggered = true; 
            }
            if (timePauseEndTime > 0) { UpdatePanelInfo(); return; } 
        }
    }

    if (IsTradingTimeWIB()) { overrideTimeFilter = false; timePauseEndTime = 0; }
    if(TimeCurrent() - lastActionTime < 1) { UpdatePanelInfo(); return; }

    if (InpDelayMode != DELAY_MODE_NONE) {
        if (!nextEntryAllowed) {
            if (currentTickTime < nextEntryTime) { UpdatePanelInfo(); return; }
            else { nextEntryAllowed = true; nextEntryTime = 0; }
        }
    }

    if (totalBuys == 0 && totalSells == 0) {
        bool canTrade = (!UseTimeFilter || IsTradingTimeWIB() || overrideTimeFilter);
        if (canTrade) {
            trade.Buy(NormalizeVolume(InpInitialLot), _Symbol, ask, 0, 0, HIDDEN_ORDER_COMMENT);
            trade.Sell(NormalizeVolume(InpInitialLot), _Symbol, bid, 0, 0, HIDDEN_ORDER_COMMENT);
            lastActionTime = TimeCurrent();
            overrideTimeFilter = false; 
            
            if (InpDelayMode == DELAY_MODE_PER_LAYER || InpDelayMode == DELAY_MODE_AFTER_CLOSE) {
                nextEntryAllowed = false;
                nextEntryTime = currentTickTime + (InpDelayMilliseconds / 1000);
            }
        }
        UpdatePanelInfo();
        return;
    }

    double refBuyTimePrice  = GetLastPriceByTime(POSITION_TYPE_BUY);
    double refSellTimePrice = GetLastPriceByTime(POSITION_TYPE_SELL);

    if (totalBuys == totalSells) {
        double refPrice = (GetLastTime(POSITION_TYPE_BUY) > GetLastTime(POSITION_TYPE_SELL)) ? refBuyTimePrice : refSellTimePrice;
        if (refPrice > 0 && (ask <= refPrice - (InpGridDistance * _Point) || bid >= refPrice + (InpGridDistance * _Point))) {
            if (IsDistanceValid(POSITION_TYPE_BUY, ask) && IsDistanceValid(POSITION_TYPE_SELL, bid) && IsMaxLayerReached(POSITION_TYPE_BUY, ask) && IsMaxLayerReached(POSITION_TYPE_SELL, bid)) {
                trade.Buy(CalculateNextLot(totalBuys), _Symbol, ask, 0, 0, HIDDEN_ORDER_COMMENT);
                trade.Sell(CalculateNextLot(totalSells), _Symbol, bid, 0, 0, HIDDEN_ORDER_COMMENT);
                lastActionTime = TimeCurrent();
            }
        }
    }
    else if (totalBuys > totalSells) {
        double triggerUp = (totalSells == 0) ? GetLowestPrice(POSITION_TYPE_BUY) : refSellTimePrice;
        if (bid >= triggerUp + (InpGridDistance * _Point)) {
            if (IsDistanceValid(POSITION_TYPE_SELL, bid) && IsMaxLayerReached(POSITION_TYPE_SELL, bid)) { 
                trade.Sell(CalculateNextLot(totalSells), _Symbol, bid, 0, 0, HIDDEN_ORDER_COMMENT);
                lastActionTime = TimeCurrent();
            }
        }
        if (ask <= refBuyTimePrice - (InpGridDistance * _Point)) {
            if (IsDistanceValid(POSITION_TYPE_BUY, ask) && IsDistanceValid(POSITION_TYPE_SELL, bid) && IsMaxLayerReached(POSITION_TYPE_BUY, ask) && IsMaxLayerReached(POSITION_TYPE_SELL, bid)) {
                trade.Buy(CalculateNextLot(totalBuys), _Symbol, ask, 0, 0, HIDDEN_ORDER_COMMENT);
                trade.Sell(CalculateNextLot(totalSells), _Symbol, bid, 0, 0, HIDDEN_ORDER_COMMENT);
                lastActionTime = TimeCurrent();
            }
        }
    }
    else if (totalSells > totalBuys) {
        double triggerDown = (totalBuys == 0) ? GetHighestPrice(POSITION_TYPE_SELL) : refBuyTimePrice;
        if (ask <= triggerDown - (InpGridDistance * _Point)) {
            if (IsDistanceValid(POSITION_TYPE_BUY, ask) && IsMaxLayerReached(POSITION_TYPE_BUY, ask)) { 
                trade.Buy(CalculateNextLot(totalBuys), _Symbol, ask, 0, 0, HIDDEN_ORDER_COMMENT);
                lastActionTime = TimeCurrent();
            }
        }
        if (bid >= refSellTimePrice + (InpGridDistance * _Point)) {
             if (IsDistanceValid(POSITION_TYPE_BUY, ask) && IsDistanceValid(POSITION_TYPE_SELL, bid) && IsMaxLayerReached(POSITION_TYPE_BUY, ask) && IsMaxLayerReached(POSITION_TYPE_SELL, bid)) {
                trade.Buy(CalculateNextLot(totalBuys), _Symbol, ask, 0, 0, HIDDEN_ORDER_COMMENT);
                trade.Sell(CalculateNextLot(totalSells), _Symbol, bid, 0, 0, HIDDEN_ORDER_COMMENT);
                lastActionTime = TimeCurrent();
            }
        }
    }
    
    UpdatePanelInfo();
}

void CheckAndCloseTP(ENUM_POSITION_TYPE type) {
    if (CountPositions(type) == 0) return;
    
    double totalProfit = 0;
    double totalVolume = 0;
    int    layerCount  = 0;
    
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(m_position.SelectByIndex(i)) {
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber && m_position.PositionType() == type) {
                totalProfit += m_position.Profit() + m_position.Swap() + m_position.Commission();
                totalVolume += m_position.Volume();
                layerCount++;
            }
        }
    }
    
    double targetProfit = 0;
    if (InpTPMode == TP_POINTS) {
        double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
        double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
        if (tickSize > 0) targetProfit = totalVolume * (InpTakeProfitPoints * _Point) * (tickValue / tickSize);
    } 
    else if (InpTPMode == TP_USD) targetProfit = InpTakeProfitUSD;
    
    // Dynamic TP 1 check
    if (UseDynamicTP1 && InpDynamicTPMode1 != DTP_MODE_NONE) {
        if ((InpDynamicTPMode1 == DTP_MODE_LAYER && InpLayersToChangeTP1 > 0 && layerCount >= InpLayersToChangeTP1) ||
            (InpDynamicTPMode1 == DTP_MODE_LOT && InpLotToChangeTP1 > 0 && totalVolume >= InpLotToChangeTP1)) {
            if (InpDynamicTPValueMode1 == DTP_VALUE_POINTS) {
                double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
                double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
                if (tickSize > 0) targetProfit = totalVolume * (InpDynamicTPPoints1 * _Point) * (tickValue / tickSize);
            }
            else { // DTP_VALUE_USD
                targetProfit = InpDynamicTPUSD1;
            }
        }
    }
    
    // Dynamic TP 2 check (Menimpa TP 1 jika aktif dan terpenuhi)
    if (UseDynamicTP2 && InpDynamicTPMode2 != DTP_MODE_NONE) {
        if ((InpDynamicTPMode2 == DTP_MODE_LAYER && InpLayersToChangeTP2 > 0 && layerCount >= InpLayersToChangeTP2) ||
            (InpDynamicTPMode2 == DTP_MODE_LOT && InpLotToChangeTP2 > 0 && totalVolume >= InpLotToChangeTP2)) {
            if (InpDynamicTPValueMode2 == DTP_VALUE_POINTS) {
                double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
                double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
                if (tickSize > 0) targetProfit = totalVolume * (InpDynamicTPPoints2 * _Point) * (tickValue / tickSize);
            }
            else { // DTP_VALUE_USD
                targetProfit = InpDynamicTPUSD2;
            }
        }
    }
    
    if (targetProfit > 0 && totalProfit >= targetProfit) {
        for(int i = PositionsTotal() - 1; i >= 0; i--) {
            if(m_position.SelectByIndex(i)) {
                if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber && m_position.PositionType() == type) { 
                    trade.PositionClose(m_position.Ticket()); 
                }
            }
        }
    }
}

double GetFloatingPnL() {
    double floatPnL = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(m_position.SelectByIndex(i)) {
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber) {
                floatPnL += m_position.Profit() + m_position.Swap() + m_position.Commission();
            }
        }
    }
    return floatPnL;
}

bool IsTradingTimeWIB() {
    if (!UseTimeFilter) return true;
    datetime currentWIB = TimeGMT() + (7 * 3600); 
    MqlDateTime dtWIB; TimeToStruct(currentWIB, dtWIB);
    int currentMins = dtWIB.hour * 60 + dtWIB.min;
    int startMins = InpStartHour * 60 + InpStartMinute;
    int endMins = InpEndHour * 60 + InpEndMinute;
    
    if (startMins < endMins) return (currentMins >= startMins && currentMins < endMins);
    else if (startMins > endMins) return (currentMins >= startMins || currentMins < endMins);
    else return true; 
}

bool CheckDailyTarget() {
    if (isTradingStoppedForDay) {
        // --- JIKA TARGET HARIAN / STOP SUDAH TERCAPAI, AKTIFKAN CUT LOSE JIKA ADA FLOATING ---
        if (UseTimeOutCutLoss) {
            int totalActivePos = CountPositions(POSITION_TYPE_BUY) + CountPositions(POSITION_TYPE_SELL);
            if (totalActivePos > 0) {
                double currentFloating = GetFloatingPnL();
                if (currentFloating <= -TimeOutCutLossUSD) {
                    CloseAllPositions();
                }
            }
        }
        return true;
    }

    if (!UseDailyProfit && !UseDailyLoss) return false;

    double dailyPnL = GetDailyPnL(); 
    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double actualProfitTarget = (InpTargetMode == TARGET_PERCENT) ? currentBalance * (DailyProfitValue / 100.0) : DailyProfitValue;
    double actualLossTarget = (InpTargetMode == TARGET_PERCENT) ? currentBalance * (DailyLossValue / 100.0) : DailyLossValue;

    bool targetHit = false;
    if (UseDailyProfit && dailyPnL >= actualProfitTarget) targetHit = true;
    else if (UseDailyLoss && dailyPnL <= -actualLossTarget) targetHit = true;

    if (targetHit) {
        CloseAllPositions(); 
        if (InpTargetAction == ACTION_STOP_TOMORROW) isTradingStoppedForDay = true;
        else if (InpTargetAction == ACTION_REMOVE_EA) ExpertRemove();
        else if (InpTargetAction == ACTION_PAUSE_MINUTES) pauseEndTime = TimeCurrent() + (InpPauseMinutes * 60);
        return true; 
    }
    return false;
}

double GetDailyPnL() {
    double dailyPnL = 0;
    if(HistorySelect(startTrackingTime, TimeCurrent())) {
        for(int i = 0; i < HistoryDealsTotal(); i++) {
            ulong ticket = HistoryDealGetTicket(i);
            if(ticket > 0) {
                if(HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol && HistoryDealGetInteger(ticket, DEAL_MAGIC) == InpMagicNumber && HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT) {
                   dailyPnL += HistoryDealGetDouble(ticket, DEAL_PROFIT) + HistoryDealGetDouble(ticket, DEAL_SWAP) + HistoryDealGetDouble(ticket, DEAL_COMMISSION);
                }
            }
        }
    }
    dailyPnL += GetFloatingPnL();
    return dailyPnL;
}

void CloseAllPositions() {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(m_position.SelectByIndex(i)) {
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber) { trade.PositionClose(m_position.Ticket()); }
        }
    }
}

double CalculateNextLot(int layerCount) {
    int safeLayerStep = (InpLayerStep < 1) ? 1 : InpLayerStep;
    int effectiveLayer = layerCount / safeLayerStep; 
    double nextLot = InpInitialLot;
    if (InpLotMode == LOT_MULTIPLIER) nextLot = InpInitialLot * MathPow(InpLotMultiplier, effectiveLayer);
    else if (InpLotMode == LOT_LINEAR) nextLot = InpInitialLot + (InpLotStep * effectiveLayer);
    
    if (UseMaxLot && nextLot > InpMaxLot) {
        nextLot = InpMaxLot;
    }

    return NormalizeVolume(nextLot);
}

datetime GetStartOfDay(datetime time) { MqlDateTime dt; TimeToStruct(time, dt); dt.hour = 0; dt.min = 0; dt.sec = 0; return StructToTime(dt); }
int GetDay(datetime time) { MqlDateTime dt; TimeToStruct(time, dt); return dt.day; }

bool IsDistanceValid(ENUM_POSITION_TYPE type, double currentPrice) {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(m_position.SelectByIndex(i)) {
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber && m_position.PositionType() == type) {
                if(MathAbs(m_position.PriceOpen() - currentPrice) < (InpGridDistance * 0.8 * _Point)) return false; 
            }
        }
    }
    return true;
}

bool IsMaxLayerReached(ENUM_POSITION_TYPE type, double currentPrice) {
    if (!UseMaxLayers) return true;

    int count = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(m_position.SelectByIndex(i)) {
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber && m_position.PositionType() == type) {
                count++;
            }
        }
    }
    return (count < InpMaxLayersPerDirection);
}

double NormalizeVolume(double volume) {
    double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    double min_vol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double max_vol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    if (step == 0) return volume; 
    double normalized = MathRound(volume / step) * step;
    if(normalized < min_vol) normalized = min_vol;
    if(normalized > max_vol) normalized = max_vol;
    return normalized;
}

int CountPositions(ENUM_POSITION_TYPE type) { 
    int count = 0; 
    for(int i = PositionsTotal() - 1; i >= 0; i--) { 
        if(m_position.SelectByIndex(i)) { 
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber && m_position.PositionType() == type) count++; 
        } 
    } 
    return count; 
}

double GetLastPriceByTime(ENUM_POSITION_TYPE type) { 
    double lastPrice = 0; 
    datetime lastTime = 0; 
    for(int i = PositionsTotal() - 1; i >= 0; i--) { 
        if(m_position.SelectByIndex(i)) { 
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber && m_position.PositionType() == type) { 
                if(m_position.Time() > lastTime) { 
                    lastPrice = m_position.PriceOpen(); 
                    lastTime = m_position.Time(); 
                } 
            } 
        } 
    } 
    return lastPrice; 
}

datetime GetLastTime(ENUM_POSITION_TYPE type) { 
    datetime lastTime = 0; 
    for(int i = PositionsTotal() - 1; i >= 0; i--) { 
        if(m_position.SelectByIndex(i)) { 
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber && m_position.PositionType() == type) { 
                if(m_position.Time() > lastTime) lastTime = m_position.Time(); 
            } 
        } 
    } 
    return lastTime; 
}

double GetLowestPrice(ENUM_POSITION_TYPE type) { 
    double minPrice = DBL_MAX; 
    for(int i = PositionsTotal() - 1; i >= 0; i--) { 
        if(m_position.SelectByIndex(i)) { 
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber && m_position.PositionType() == type) { 
                if(m_position.PriceOpen() < minPrice) minPrice = m_position.PriceOpen(); 
            } 
        } 
    } 
    return (minPrice == DBL_MAX) ? 0 : minPrice; 
}

double GetHighestPrice(ENUM_POSITION_TYPE type) { 
    double maxPrice = 0; 
    for(int i = PositionsTotal() - 1; i >= 0; i--) { 
        if(m_position.SelectByIndex(i)) { 
            if(m_position.Symbol() == _Symbol && m_position.Magic() == InpMagicNumber && m_position.PositionType() == type) { 
                if(m_position.PriceOpen() > maxPrice) maxPrice = m_position.PriceOpen(); 
            } 
        } 
    } 
    return maxPrice; 
}
//+------------------------------------------------------------------+