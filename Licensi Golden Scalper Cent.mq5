//+------------------------------------------------------------------+
//|                                     LicenseKeyGenerator.mq5       |
//|   Script untuk generate kode lisensi EA (untuk Developer/Admin)  |
//|   Cara pakai: Drag & drop script ini ke chart mana saja.         |
//|   Kode lisensi akan muncul di tab Experts/Journal (Ctrl+T).      |
//|                                                                    |
//|   PENTING: Kode lisensi sekarang TERIKAT ke satu Nomor Akun MT5  |
//|   (InpTargetAccount). Kode TIDAK akan valid jika dipasang di     |
//|   akun MT5 lain. Isi InpTargetAccount dengan nomor akun MT5      |
//|   milik customer yang membeli lisensi (lihat di Journal terminal |
//|   mereka, atau tanyakan langsung).                                |
//+------------------------------------------------------------------+
#property script_show_inputs

input long   InpTargetAccount = 0;      // WAJIB DIISI: Nomor Akun MT5 customer (akun tujuan lisensi)
input int    InpValidDays     = 30;     // Masa berlaku lisensi (hari)
input ulong  InpMagicNumber   = 88888;  // WAJIB SAMA dengan Magic Number di EA target

//+------------------------------------------------------------------+
//| Checksum sederhana - HARUS IDENTIK dengan fungsi di file EA      |
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

string GenerateLicenseKey(long targetAccount, int validDays)
{
    MathSrand((int)TimeLocal() + (int)GetTickCount());
    string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    string block1 = "", block2 = "", block3 = "";
    for (int i = 0; i < 4; i++) block1 += StringSubstr(chars, MathRand() % StringLen(chars), 1);
    for (int i = 0; i < 4; i++) block2 += StringSubstr(chars, MathRand() % StringLen(chars), 1);
    for (int i = 0; i < 4; i++) block3 += StringSubstr(chars, MathRand() % StringLen(chars), 1);

    string accountStr = IntegerToString(targetAccount);

    datetime expiry = TimeCurrent() + (validDays * 86400);
    MqlDateTime dtExp;
    TimeToStruct(expiry, dtExp);
    string dateStr = StringFormat("%04d%02d%02d", dtExp.year, dtExp.mon, dtExp.day);

    int chk = LicenseChecksum(block1, block2, block3, accountStr, dateStr);
    string chkStr = StringFormat("%03d", chk);

    return block1 + "-" + block2 + "-" + block3 + "-" + accountStr + "-" + dateStr + "-" + chkStr;
}

void OnStart()
{
    if (InpTargetAccount <= 0)
    {
        Alert("GAGAL: Isi InpTargetAccount dengan nomor akun MT5 customer terlebih dahulu (tidak boleh 0).");
        Print("GAGAL: InpTargetAccount belum diisi / masih 0. Kode lisensi tidak dibuat.");
        return;
    }

    string key = GenerateLicenseKey(InpTargetAccount, InpValidDays);
    datetime expiry = TimeCurrent() + (InpValidDays * 86400);

    Print("========================================");
    Print("   KODE LISENSI BERHASIL DIBUAT");
    Print("========================================");
    Print("Kode Lisensi   : ", key);
    Print("Terikat Akun   : ", InpTargetAccount, " (HANYA valid di akun MT5 ini)");
    Print("Magic Number   : ", InpMagicNumber, " (harus sama dgn Magic Number di EA)");
    Print("Berlaku Sampai : ", TimeToString(expiry, TIME_DATE));
    Print("Durasi         : ", InpValidDays, " hari");
    Print("========================================");
    Print("Salin kode di atas dan masukkan ke input 'InpLicenseKey' pada EA");
    Print("yang dipasang di akun MT5 nomor ", InpTargetAccount, ". Di akun lain kode ini akan ditolak.");

    Alert("Kode Lisensi (akun ", InpTargetAccount, "): ", key, "\nBerlaku sampai: ", TimeToString(expiry, TIME_DATE));
}
//+------------------------------------------------------------------+
