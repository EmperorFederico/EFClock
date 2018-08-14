sbit LCD_RS at RD2_bit; // LCD'nin RS pininin, mikrodenetleyicinin hangi pinine ba�l� oldu�u belirtiliyor
sbit LCD_EN at RD3_bit; // LCD'nin Enable pininin, mikrodenetleyicinin hangi pinine ba�l� oldu�u belirtiliyor
sbit LCD_D4 at RD4_bit; // LCD'nin Data 4 pininin, mikrodenetleyicinin hangi pinine ba�l� oldu�u belirtiliyor
sbit LCD_D5 at RD5_bit; // LCD'nin Data 5 pininin, mikrodenetleyicinin hangi pinine ba�l� oldu�u belirtiliyor
sbit LCD_D6 at RD6_bit; // LCD'nin Data 6 pininin, mikrodenetleyicinin hangi pinine ba�l� oldu�u belirtiliyor
sbit LCD_D7 at RD7_bit; // LCD'nin Data 7 pininin, mikrodenetleyicinin hangi pinine ba�l� oldu�u belirtiliyor

sbit LCD_RS_Direction at TRISD2_bit;
sbit LCD_EN_Direction at TRISD3_bit;
sbit LCD_D4_Direction at TRISD4_bit;
sbit LCD_D5_Direction at TRISD5_bit;
sbit LCD_D6_Direction at TRISD6_bit;
sbit LCD_D7_Direction at TRISD7_bit;

unsigned short saniye = 0;      // ZAMANIN SAN�YES�N� TUTMAK ���N 8 bitlik de�i�ken
unsigned short dakika = 0;      // ZAMANIN DAK�KASINI TUTMAK ���N 8 bitlik de�i�ken
unsigned short saat = 0;        // ZAMANIN SAAT DE�ER�N� TUTMAK ���N 8 bitlik de�i�ken
unsigned short alarm_dakika = 0;  // ALARM ZAMANININ DAK�KASINI TUTMAK ���N 8 bitlik de�i�ken
unsigned short alarm_saat = 0;    // ALARM ZAMANININ SAAT�N� TUTMAK ���N 8 bitlik de�i�ken
unsigned short sayac = 0;         // TIMER1 kesmesinde kullan�lmak i�in tan�mlanan saya� de�i�keni
unsigned short mod = 0;           // Men� ekranlar� ve alt men�ler aras�nda ge�i�ler i�in tan�mlanan mod de�i�keni
unsigned short yaz = 0;            // Saniyede 1 kez ekran�n temizlenmesini sa�layacak olan bayrak de�i�keni
unsigned short pos = 10;           // LCD imlecinin konumunun tayin edilmesi i�in kullan�lan de�i�ken
unsigned short alarm_kurulum = 0;   // Alarm kurulumunun yap�l�p yap�lmad���n� ya da hangi alarm�n kuruldu�unu ay�rt etmek i�in kullan�lan de�i�ken
unsigned short tekrar = 0;      // G�nl�k ila� kullan�m say�s� i�in kullan�lan d�ei�ken
unsigned yardimci = 0;    // Periyodik alarmda bir sonraki ila� saatinin hesaplanmas� a�amas�nda kullan�lan yard�mc� de�i�ken
char txt[3];  // LCD'ye say�sal de�er yazd�r�la iblmesi i�in, say�sal de�erin �nce karakter haline getirilmesi gerekir. Bunun i�n say�sal de�erden karaktere d�n��t�r�len verinin tutulaca�� ir karakter dizisi tan�mlanmaktad�r

void interrupt() // Herhangi bir kesme olu�tu�unda, program duraksat�l�r ve bu fonksiyona girilir. K�sacas� bu fonksiyon, kesme fonksiyonudur
{
   if(PIR1.TMR1IF == 1) // E�er TIMER1'in  INTERRUPT FLAG bitinin de�eri 1 ise; yani TIMER1 kesmesi (interrupt) meydana gelmi� ise a�a��daki komutlar icra edilir
   {
      if(mod != 10) // E�er mod de�i�keninin de�eri 10'a e�it de�ilse a�a��daki komutlar icra edilir (mod de�i�keninin de�eri 10 ise, saat ayar� yap�l�yor demektir. Bu y�zden saat ilerletilmez ve bu kodlar icra edilmez.)
      {
         sayac = sayac+1; // Saya� de�i�keninin de�erini 1 artt�r (Yap�lan ayarlamalar sonucu, TIMER1 kesmesi, 200 ms periyotla meydana gelmektedir. Do�al olarak her 200ms'de bir kez sayac de�i�keninin de�eri artt�r�l�r.)
         if(sayac == 5) // E�er saya� de�i�keninin de�eri 5 ise; yani 1 saniye olmu� ise a�a��daki komutlar icra edilir
         {
            saniye = saniye+1; // Saniye de�erini bir artt�r
            yaz = 1; // LCD'yi yenilemek i�in kullan�lan bayrak de�i�keninin de�erini 1 yap (Yani LCD'yi temizlemek i�in gerekli de�eri "set" et. LCD, ana program i�erisinde her d�ng�de temizlenecek olsayd� ekrandaki g�r�nt� g�z ile g�r�lemezdi. Bu sebeple, LCD'ye yazma i�lemini yava�latmak ad�na saniyede 1 kez ekran temizlenir ve yeni de�erler yaz�l�r. Bu i�lem mod = 0 yani standart �al��ma modu i�in yap�l�r)
            if(saniye == 60) // E�er saniye de�eri 60'a ula�t�ysa a�a��daki komutlar icra edilir
            {
               dakika = dakika+1; // Dakika de�i�keninin de�eri 1 arttt�r�l�r
               saniye = 0; // Saniye de�eri s�f�rlan�r
            }
            sayac = 0; // Her saniyenin sonunda sayac de�i�keni s�f�rlan�r. B�ylece saya� de�i�keninin ta�ma yapmas� (yani alabilece�i maksimum de�er olan 255'e ula�mas� ) engellenir.
         }
         if(dakika == 60)  // E�er dakika de�eri 60'a ula�t�ysa a�a��daki komutlar icra edilir
         {
            saat = saat+1; // Saat de�eri 1 artt�r�l�r
            dakika = 0; // Dakika de�eri s�f�rlan�r
         }
         if(saat == 24) // E�er saat de�eri 24'e e�itse a�a��daki komutlar icra edilir.
         {
            saat = 0; // Saat de�eri s�f�rlan�r
            dakika = 0; // Dakika de�eri s�f�rlan�r
            saniye = 0; // Saniye de�eri s�f�rlan�r
         }
         if((((alarm_saat == saat) && (alarm_dakika == dakika))&&(saniye == 0)) && ((alarm_kurulum == 2) || (alarm_kurulum == 3))) // E�er kurulmu� olan alarm saati ve dakikas�, mevcut saat ve dakikaya e�itse, e�er saniye de�eri s�f�rsa (yani o dakikaya yeni ge�ilmi�se) ve periyodik alarm veya tek seferlik alarm kurulmu�sa ( yani sistemde aktif bir alarm varsa ve alarm saati geldiyse a�a��daki kodlar icra edilir.
         {
            if(alarm_kurulum == 3)
               alarm_kurulum = 10; // Tek seferlik alarm i�in alarm �al
            if(alarm_kurulum == 2)
               alarm_kurulum = 11;  // Periyodik alarm i�in alarm �al
         }
         if((alarm_kurulum == 10)||(alarm_kurulum == 11))  // E�er alarm �al�yorsa a�a��daki kodlar icra edilir
         {
            if(sayac<=3)    // saya� de�i�keninin de�eri 3'ten k���k veya e�itse (yani 0-600 ms aras�)
            {
               PORTB = 254; // B0 hari� t�m pinlerin ��k��lar� Lojik-1 yap�l�r. B�ylece ledler yak�l�r ve buzzer �ter.
            }
            else
               PORTB = 0; // B portunun t�m pinlerinin ��k��lar� Lojik -0 yap�l�r

         }

      }

      TMR1H = 0b00111100; // TIMER 1 say�c�s�n�n de�erinin (sayd��� de�er) kurulumu yap�l�yor (Y�ksek de�erlikli 8 bitinin)
      TMR1L = 0b10101111; // TIMER 1 say�c�s�n�n de�erinin (sayd��� de�er) kurulumu yap�l�yor (D���k de�erlikli 8 bitinin)
      PIR1.TMR1IF = 0; // TIMER1 say�c�s�n�n INTERRUPT FLAG bitinin de�eri s�f�ra e�itleniyor (resetleniyor). B�ylece program�n, kesme fonksiyonundan ��kmas� sa�lan�yor. E�er kesme fonksiyonunun sonunda, ilgili kesmeye ait FLAG biti resetlenmezse, program sonsuz d�ng�ye girer.
   }
   if(INTCON.INTF == 1) // E�er INTF bitinin de�eri 1 ise, yani harici kesme meydana geldiyse a�a��daki kodlar icra edilir ( Di�er bir deyi�le, mod/kur tu�una bas�ld�ysa)
   {
      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //////////////////////// A�a��daki k�s�m, mod/kur tu�unun mod de�i�tirme (men� ekranlar� aras�ndaki ge�i�) i�lemlerini ger�ekle�tirmesini////////////////
      //////////////////////// sa�layan kod blo�udur.                                                                                          ////////////////
      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      if(alarm_kurulum != 1) // E�er alarm kurulum bayrak de�i�keninin de�eri 1 de�ilse (yani kullan�c� herhangi bir alarm men�s�n�n alt men�s�ne girmemi�se) a�a��daki kodlar icra edilir ( kullan�c� alarm kurulumu yap�lan men�lerden birisine geldi�i takdirde alarm_ kurulum de�ikeninin de�eri 1 olarak ayarlan�r )
      {
         if((mod == 0)&&(PORTB.RB0 == 1))  // E�er mod 0 (ana ekranda )ise ve h�l� mod/kur tu�una bas�l�yorsa a�a��daki kodlar icra edilir
         {
            mod = 1;
            while(PORTB.RB0);// bu sat�r sayesinde, butona ne kadar bas�l� tutulursa tutulsun, kullan�c� elini �ekene kadar i�lem yap�lmaz. Program burada k�s�r d�ng�ye sokulur. Program i�erisinde benzer kod sat�r�n� bir�ok yerde g�rebilirsiniz.
         }
         if((mod == 1)&&(PORTB.RB0 == 1))  // E�er mod 1 ise (Periyodik alarm ekran�) ve  h�l� mod/kur tu�una bas�l�yorsa a�a��daki kodlar icra edilir
         {
            mod = 4; // Periyodik alarm men�s�n�n alt men�lerine girilmeyip mod/kur tu�una bas�ld�ysa modu 4 yapar
            while(PORTB.RB0);
         }
         if(mod == 2)     // E�er mod 2 ise (Periyodik alarm�n alt men�s�. �lk alarm saatinin girildi�i ekran )ve  h�l� mod/kur tu�una bas�l�yorsa a�a��daki kodlar icra edilir
         {
            alarm_kurulum = 1; // Alarm kurulum i�leminin yap�ld���na dair bayrak de�eri 1 yap�l�r.
            mod = 3;           // bir sonraki men�ye ge�i� i�in mod de�eri 3 yap�l�r.
            while(PORTB.RB0);
         }
         if((mod == 4)&&(PORTB.RB0 == 1)) // E�er mod 4 ise (Tek seferlik alarm ekran� )
         {
            mod = 10; // Mode de�i�keninin de�eri 10 yap�l�r. B�ylece, saat kurulum ekran�na ge�ilir.
            while(PORTB.RB0);
         }
         if((mod == 10)&&(PORTB.RB0 == 1))  // E�er mod de�eri 10 ise (yani saat kurulum ekran�ndayken mod/kur tu�una bas�ld�ysa) ve mod/kur tu�una bas�l� tutuluyorsa a�a��daki kodlar icra edilir
         {
            mod = 0; // mod de�erini s�f�rlar
            while(PORTB.RB0);
         }
      }
      ///////////////////////////////////////////////////////////////////////////////////////
      /////// A�a��daki k�s�m, mod/kur tu�unun; kurma i�lemlerini yapt��� kod blo�udur //////
      ///////////////////////////////////////////////////////////////////////////////////////
      if(alarm_kurulum == 1) // e�er alarm kurulum de�eri 1 ise yani herhangi bir alarm�n alt men�s�ne girilmi�se a�a��daki kodlar icra edilir
      {
         if(mod == 5) // E�er mod 5 ise yani mevcut ekranda tek seferlik alarm kurulumu yap�l�yor ise a�a��daki kodlar icra edilir
         {
            alarm_kurulum = 3; // alarm kurulum de�i�keninin de�eri 3 olarak atan�r.
            mod = 0; // alarm kurulumu tamamlan�r ve mod de�eri s�f�rlanarak ana ekrana geri d�n�l�r
            while(PORTB.RB0);
         }
         if((mod == 3)&&(PORTB.RB0 == 1)) // E�er mod 3 ise yani mevcut ekranda periyodik alarm i�in g�nde ka� kez tekrar yap�laca��n�n kurulumu yap�l�yor ise a�a��daki kodlar icra edilir
         {
            alarm_kurulum = 2; // alarm kurulum de�i�keninin de�eri 2 olarak atan�r
            mod = 0; // alarm kurulumu tamamlan�r ve mod de�eri s�f�rlanarak ana ekrana geri d�n�l�r
            while(PORTB.RB0);
         }
      }
      INTCON.INTF = 0;  // Harici kesmenin INTERRUPT FLAG biti resetleniyor. Aksi takdirde sistem sonsuz d�ng�ye girecektir.
   }
}
void alarm_yaz()     // LCD ekrana alarm uyar�s�n� yazd�ran fonksiyonun tan�mlanmas�
{
   Lcd_Out(1,1,"ILAC SAATI"); // Birinci sat�r, birinci s�tundan ba�layarak ilgili metni ekrana yazar
   ByteToStrWithZeros(alarm_saat,txt); // Say�sal bir de�er olan alarm_saat de�i�keninin de�eri, karakter dizisi olan txt de�i�kenine d�n��t�r�lmektedir.
   Lcd_Chr(2,9,txt[1]); // 2. sat�r 9. s�tuna, txt dizisinin 2. eleman�n�n de�erini (yani alarm_saat ifadesinin onlar basama��n�) yazd�r�r
   Lcd_Chr(2,10,txt[2]); // 2. sat�r 10. s�tuna, txt dizisinin 3. eleman�n�n de�erini (yani alarm_saat ifadesinin  birler basama��n�) yazd�r�r
   Lcd_Chr(2,11,':'); // 2. sat�r 11. s�tuna ':' karakterini yazar. B�ylelikle saat ve dakika basamaklar� aras�ndaki ayr�m sa�lan�r
   ByteToStrWithZeros(alarm_dakika,txt); // Say�sal bir de�er olan alarm_dakika de�i�keninin de�eri, karakter dizisi olan txt de�i�kenine d�n��t�r�lmektedir.
   Lcd_Chr(2,12,txt[1]); // 2. sat�r 12. s�tuna, txt dizisinin 2. eleman�n�n de�erini (yani alarm_dakika ifadesinin onlar basama��n�) yazd�r�r
   Lcd_Chr(2,13,txt[2]);// 2. sat�r 13. s�tuna, txt dizisinin 3. eleman�n�n de�erini (yani alarm_dakika ifadesinin  birler basama��n�) yazd�r�r
}
void alarm_kurulum_yaz()   // Alarm kurulum ekran�n�, LCD'ye yazd�ran fonksiyonun tan�mlanmas�
{
   ByteToStrWithZeros(alarm_saat,txt); // Say�sal bir de�er olan alarm_saat de�i�keninin de�eri, karakter dizisi olan txt de�i�kenine d�n��t�r�lmektedir.
   Lcd_Chr(2,5,txt[1]); // 2. sat�r 5. s�tuna, txt dizisinin 2. eleman�n�n de�erini (yani alarm_saat ifadesinin onlar basama��n�) yazd�r�r
   Lcd_Chr(2,6,txt[2]); // 2. sat�r 6. s�tuna, txt dizisinin 3. eleman�n�n de�erini (yani alarm_saat ifadesinin  birler basama��n�) yazd�r�r
   Lcd_Chr(2,7,':'); // 2. sat�r 7. s�tuna ':' karakterini yazar. B�ylelikle saat ve dakika basamaklar� aras�ndaki ayr�m sa�lan�r
   ByteToStrWithZeros(alarm_dakika,txt); // Say�sal bir de�er olan alarm_dakika de�i�keninin de�eri, karakter dizisi olan txt de�i�kenine d�n��t�r�lmektedir.
   Lcd_Chr(2,9,txt[2]); // 2. sat�r 12. s�tuna, txt dizisinin 2. eleman�n�n de�erini (yani alarm_dakika ifadesinin onlar basama��n�) yazd�r�r
   Lcd_Chr(2,8,txt[1]); // 2. sat�r 13. s�tuna, txt dizisinin 3. eleman�n�n de�erini (yani alarm_dakika ifadesinin  birler basama��n�) yazd�r�r
}

void main()
{
   INTCON.GIE = 1;    // INTCON yazmac�n�n t�m kesmelere m�saade eden bitinin de�eri 1 yap�l�yor
   INTCON.PEIE = 1;   // INTCON yazmac�n�n �evresel kesmeleri aktive eden bitinin de�eri 1 yap�l�yor

   INTCON.INTE = 1;   // INTCON yazmac�n�n, harici kesmeyi aktifle�tiren bitiinn de�eri 1 yap�l�yor
   INTCON.INTF = 0;   // INTCON yazmac�n�n, harici kesme bayrak bitinin de�eri s�f�r yap�l�yor
   OPTION_REG.INTEDG = 1; // OPTION_REG yazmac�n�n ilgili bitinin de�eri 1 olarak ayarlan�yor. B�ylece kesme i�leminin, y�kselen kenarda ger�ekle�mesi sa�an�yor

   T1CON.T1CKPS1 = 1;  // T1CON yazmac�n�n, �n b�l�c� ayar�n� sa�layan
   T1CON.T1CKPS0 = 0;  //  Bu iki bit, ilgili de�erlere ayarlanarak 1:4 �n b�l�c� oran� sa�lan�yr
   T1CON.TMR1CS = 0;   // TIMER1'in, mikrodenetleyiciyi �al��t�ran ve OSC1 ile OSC2 u�lar� aras�na ba�lanm�� olan osilat�r taraf�ndan tetiklenece�i belirtiliyor
   T1CON.TMR1ON = 1;    // TIMER1 mod�l� aktifle�tiriliyor
   T1CON.T1OSCEN = 0;   // TIMER1 mod�l� i�in osilat�r ayar� pasif hale getiriliyor
   TMR1H = 0b00111100; // TIMER 1 say�c�s�n�n de�erinin (sayd��� de�er) kurulumu yap�l�yor (Y�ksek de�erlikli 8 bitinin)
   TMR1L = 0b10101111; // TIMER 1 say�c�s�n�n de�erinin (sayd��� de�er) kurulumu yap�l�yor (D���k de�erlikli 8 bitinin)
   PIR1.TMR1IF = 0; // TIMER1 say�c�s�n�n INTERRUPT FLAG bitinin de�eri s�f�ra e�itleniyor (resetleniyor). Program�n ba��nda, g�venlik ve temizlik ama�l� olarak bu i�lem yap�l�yor.
   PIE1.TMR1IE = 1;

   TRISB = 0b00000001;  // B portunun tamam� (B0 pini hari�) ��k�� olarak ayarlan�yor
   TRISD = 0b00000011;  // D portunun ilk iki biti giri�, geri kalanlar� ��k�� olarak ayarlan�yor
   TRISC = 0b00001100;   // C portunun 2. ve 3. bitleri giri�, geriye kalanlar� ise ��k�� olarak ayarlan�yor
   PORTB = 0;  // B portunun ��k��lar� s�f�rlan�yor. Lojik-0 seviyesine �ekiliyor
   PORTC = 0; // C portunun ��k��lar� s�f�rlan�yor. Lojik-0 seviyesine �ekiliyor
   Lcd_Init();  // LCD ekran ba�lat�l�yor.
   Lcd_Cmd(_LCD_CLEAR); // LCD ekran temizleniyor
   Lcd_Cmd(_LCD_CURSOR_OFF);  // LCD ekran �zerindeki imle� kapat�l�yor
   while(1)// Sonsuz d�ng�
   {
      Lcd_Cmd(_LCD_CLEAR); // LCD ekran temizleniyor. Her mod de�i�iminde bu d�ng�n�n sonuna gidilip ba��na d�n�ld��� i�in
      while(mod == 0) // mod de�eri s�f�rsa yani ana ekranda ise
      {
         if((alarm_kurulum == 10)||(alarm_kurulum == 11)) // E�er tek seferlik veya periyodik alarm kurulduysa ve alarm saati geldiyse
         {
            if(alarm_kurulum == 10)   // E�er tek seferlik alarm saati geldiyse
            {
               alarm_yaz();    // Daha �nce haz�rlanm�� olan alarm yazd�rma fonksiyonu �a��r�l�yor
               if(PORTC.RC3 == 1)  // E�er "�PTAL" tu�una bas�l�rsa a�a��daki kodlar icra edilir
               {
                  alarm_kurulum = 0; // Alarm� siler
                  delay_ms(200);    // kasti olarak gecikme
                  PORTB = 0;         // B portunun t�m ��k��lar�n� s�f�rlar
                  while(PORTC.RC3);
               }
            }
            if(alarm_kurulum == 11)  // E�er periyodik alarm �al�yorsa
            {
              alarm_yaz();        // Ekrana alarm ifadesi yazd�r�l�r
              if(PORTC.RC3 == 1)
              {
                 yardimci = 24/tekrar;  // Bir sonraki ila� saatini hesaplamak i�in
                 yardimci = alarm_saat + yardimci; // gerekli i�lemler yap�l�r
                 alarm_saat = yardimci%24;       // Bu i�lemler sonucunda
                 alarm_kurulum = 2;     // Yeni alarm saati, bir sonraki ila� saati olur
                 delay_ms(200);
                 PORTB = 0;
                 while(PORTC.RC3);
              }
           }
           }
         else // E�er herhangi bir alarm yoksa e alarm saati gelmediyse
         {
             ByteToStrWithZeros(saat,txt);  // Say�sal bir ifade olan saat ifadesini karakter haline getirir ve her bir basama��, txt isimli karakter dizisinin bir eleman� olarak atar. txt dizisi 3 elemanl�d�r. E�er d�n��t�r�len say� 3 basamaktan k���kse, ba��na s�f�r koyar. �rne�in saat = 5 ise bu durumda txt dizisi = "005" olur
             Lcd_Out(1,1,"SAAT :");      // 1. sat�r 1. s�tune "SAAT :" metnini yazar.
             Lcd_Chr(1,8,txt[1]); // txt dizisinin ikinci eleman� yani saatin onlar basama�� ekrana yazd�r�l�r
             Lcd_Chr(1,9,txt[2]); // txt dizisinin ���nc� eleman� yani saatin birler basama�� ekrana yazd�r�l�r
             Lcd_Chr(1,10,':'); // Ekranda belirtilen konuma ':' karakterini yazar
             ByteToStrWithZeros(dakika,txt);
             Lcd_Chr(1,11,txt[1]);
             Lcd_Chr(1,12,txt[2]);
             Lcd_Chr(1,13,':');
             ByteToStrWithZeros(saniye,txt);
             Lcd_Chr(1,14,txt[1]);
             Lcd_Chr(1,15,txt[2]);
             if((alarm_kurulum == 2)||(alarm_kurulum == 3)) // E�er sstemde kurulmu� bir alarm var ise
             {
                Lcd_Out(2,1,"ALARM :"); // 2. sat�r 1. s�tundna ba�layarak "ALARM" yazar
                ByteToStrWithZeros(alarm_saat,txt); // Buradaki fonksiyonlar ile, sistemde
                Lcd_Chr(2,9,txt[1]);                // Bir alarm var ise
                Lcd_Chr(2,10,txt[2]);                // Ana ekranda, saatin alt�nda
                Lcd_Chr(2,11,':');                  // Alarm ifadesinin yazmas� sa�lan�r
                ByteToStrWithZeros(alarm_dakika,txt);
                Lcd_Chr(2,12,txt[1]);
                Lcd_Chr(2,13,txt[2]);
             }
             if(yaz == 1)  // yaz de�eri 1 ise, yani 1 saniye ge�tiyse
             {
                Lcd_Cmd(_LCD_CLEAR);// LCD'yi temizle
                yaz = 0;   // yaz de�erini s�f�rla
             }
             if(PORTC.RC3 == 1) // E�er "�IK/�PTAL/S�L "  tu�una bas�ld�ysa
             {
                   alarm_dakika = 0; // T�m alarm verilerini
                   alarm_saat = 0;   // Siler
                   alarm_kurulum = 0;
             }
          }
      }
      Lcd_Cmd(_LCD_CLEAR);
      Lcd_Cmd(_LCD_CURSOR_OFF);
      while(mod == 1)  // mod de�i�keninin de�eri 1 olduk�a a�a��daki kodlar icra edilir.
      {
         Lcd_Out(1,1,"PERIYODIK ALARM");   // 1. sat�r ve 1. s�tundan ba�layarak ekrana ilgili metin ifadesini yazd�r�.
         if(PORTC.RC2 == 1)  // E�er "SE�" tu�una bas�ld�ysa a�a��daki kodlar icra edilir
         {
            mod = 2;     // mod de�i�keninin de�eri 2 yap�l�r. B�ylece, periyodik alarm�n ba�lang�� saatinin ayarland��� alt men�ye girilir.
            delay_ms(200);  // sistemi kasti olarak yava�latmak i�in 200 ms'lik gecikme fonksiyonu kullan�l�r
         }
         if(PORTC.RC3 == 1)   // E�er "�PTAL/�IK/S�L" tu�una bas�ld�ysa a�a��daki kodlar icra edilir
         {
            mod = 0;  // mod de�i�keninin de�eri 0 yap�l�r. B�ylece, ana ekrana geri d�n�l�r
            delay_ms(200);// sistemi kasti olarak yava�latmak i�in 200 ms'lik gecikme fonksiyonu kullan�l�r
         }
      }
      Lcd_Cmd(_LCD_CLEAR); // ekran� temizler
      
      if(mod == 2)  // E�er mod de�i�keninin de�eri 2 ise, bu kod blo�u yaln�zca bir kez �al���r. Bunun sebebi, LCD'ye sonsuz d�ng� i�erisinde gecikme fonksiyonlar� kullanmadan
      {   // bir metin ifadesinin yaz�lmas� s�ras�nda, sisstem �ok h�zl� �al��t��� i�in yaz�lan karakterlerin tam olarak g�r�nememesidir. Bu sebeple, bir kez
         Lcd_Out(1,2,"ILK ALARM");  // "ILK ALARM" ifadesi ekrana yazd�r�l�r ve bir sonraki ekran temizleme komuduna kadar ekranda kal�r
         alarm_kurulum_yaz();  // daha �nce tan�mlanm�� olan fonksiyon �a��r�l�yor
      }
      while(mod == 2)// Bu kod blo�u, mod de�i�keninin de�eri 2 oldu�u s�rece �al���r
      {
         Lcd_Cmd(_LCD_BLINK_CURSOR_ON);
         if(PORTC.RC2 == 1) // e�er "SE�" tu�una bas�ld�ysa a�a��daki kodlar icra edilir. Burada se� tu�u, basamaklar aras�nda de�i�imi sa�lamaktad�r.
         {
            if(pos == 7) // e�er imle� pozisyonu i�in tan�mlanan de�i�kenin de�eri 7 ise a�a��daki kodlar icra edilir. BU k�s�m ve alttaki k�s�m tamamen, kullan�c�ya hangi basamakta bulundu�unu belirten imlecin konumu ve g�sterimi ile ilgilidir
            {
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT); // LCD ekran �zerindeki imle� bir birim sa�a kayd�r�l�r
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT); // LCD ekran �zerindeki imle� bir birim sa�a kayd�r�l�r
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT); // LCD ekran �zerindeki imle� bir birim sa�a kayd�r�l�r
               pos = 10;      // imle� pozisyonu i�in tan�mlanan de�i�kenin de�eri 10 olarak atan�r
               Delay_ms(250); // sistemi yava�latmak ad�na 250 ms'lik kasti gecikme eklenir
               while(PORTC.RC2);
            }
            if((pos > 7)&&(PORTC.RC2 == 1)) // E�er pozisyon de�i�keninin de�eri 7'den b�y�kse ve "SE�" tu�una bas�l�yorsa (&&(PORTC.RC2 == 1) k�sm� olmasayd�, bir �nceki ko�ul ifadesinde pos = 10 olarak atand��� i�in, program otomatik olarak bu ko�ulun da i�erisine girecekti)
            {
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);   // LCD ekran �zerindeki imle� bir birim sola kayd�r�l�r
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);   // LCD ekran �zerindeki imle� bir birim sola kayd�r�l�r
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);   // LCD ekran �zerindeki imle� bir birim sola kayd�r�l�r
               pos = pos-3;      // imle� pozisyonu i�in tan�mlanan de�i�kenin de�eri 3 azalt�l�r
               delay_ms(250);
               while(PORTC.RC2);
            }
         }
         if(PORTC.RC3 == 1)  // E�er alarm kurulum alt men�s�nde "�PTAL/�IK/S�L" tu�una bas�ld�ysa a�a��daki kodlar icra edilir.
         {
            alarm_kurulum = 0;  // Alarmlar ile ilgili olan
            alarm_saat = 0;     // T�m sistem parametreleri
            alarm_dakika = 0;   // S�f�rlan�r
            mod = 0;            // Mode de�eri s�f�rlanarak ana ekrana d�n�� sa�lan�r
         }
         if(PORTD.RD0 == 1) // E�er ARTTIR tu�una bas�ld�ysa
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);  // LCD'de g�r�len imleci kapat�r. Bunun sebebi, a�a��da bulunan LCD_chr fonksiyonundan �nce imle� kapat�lmazsa, her karakteri ekrana yazarken imlecin de metin boyunca hareket edi�inin g�r�n�r olmas�d�r.
            if(pos == 10) // e�er imle� pozisyon de�eri 10 ise yani kullan�c� dakika basama��ndaysa
            {
               if(alarm_dakika == 59) //e�er alarm_dakika de�i�keninin de�eri 59 ise
                  alarm_dakika = 0;    // de�eri s�f�rlar (ba�a d�nd�r�r)
               else                    // e�er alarm_dakika de�i�keninin de�eri 59 de�il ise
                  alarm_dakika = alarm_dakika+1;  // alarm_dakika de�i�keninin de�erini 1 artt�r�r
               ByteToStrWithZeros(alarm_dakika,txt);
               Lcd_Chr(2,9,txt[2]); // Ekrana yeni alarm_dakika de�eri yazd�r�l�r. �NCE B�RLER BASAMA�ININ, ARDINDAN ONLAR BASAMA�ININ YAZDIRILMA SEBEB� �UDUR;
               Lcd_Chr(2,8,txt[1]);  // �MLE� A�ILDI�I ZAMAN, EN SON ��LEM YAPILAN S�TUNUN B�R SA�INDA ORTAYA �IKAR. �MLEC�N 9. S�TUNDA YAN� DAK�KA �FADES�N�N
               // B�RLER BASAMA�INDA G�R�N�R OLMASI ���N, EN SON YAPILAN ��LEM ONLAR BASAMA�INA YAPILIR
               delay_ms(250);

            }
            if(pos == 7)  // e�er imle� pozisyon de�eri 7 ise yani kullan�c� SAAT basama��ndaysa
            {
               if(alarm_saat == 24)        // Bu kez, yukar�da dakika mertebesi i�in yap�lan i�lemlerin ayn�s�, saat mertebesi i�in yap�l�r
                  alarm_saat = 0;
               else
                  alarm_saat = alarm_saat+1;
               ByteToStrWithZeros(alarm_saat,txt);
               Lcd_Chr(2,6,txt[2]);
               Lcd_Chr(2,5,txt[1]);
               delay_ms(250);
            }
         }
         if(PORTD.RD1 == 1)// E�er AZALT tu�una bas�ld�ysa
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);// LCD �zerindeki imle� kapat�l�r
            if(pos == 10)            // Bu a�amada
            {                         // Artt�r tu�una bas�ld���nda
               if(alarm_dakika == 0)  // ger�ekle�en i�lelerin ayn�lar�
                  alarm_dakika = 0;   // bu kez alarm_saat ve alarm_dakika de�i�kenleerinin de�erleri a
               else                   // azalt�lacak �ekilde tekrarlan�r
                  alarm_dakika = alarm_dakika-1;
               ByteToStrWithZeros(alarm_dakika,txt);
               Lcd_Chr(2,9,txt[2]);
               Lcd_Chr(2,8,txt[1]);
               delay_ms(250);
            }
            if(pos == 7)
            {
               if(alarm_saat == 0)
                  alarm_saat = 0;
               else
                  alarm_saat = alarm_saat-1;
               ByteToStrWithZeros(alarm_saat,txt);
               Lcd_Chr(2,6,txt[2]);
               Lcd_Chr(2,5,txt[1]);
               delay_ms(250);
            }
         }
      }
      Lcd_Cmd(_LCD_CURSOR_OFF); // modlar aras� ge�i�lerde g�venlik amac�yla imle� kapat�l�r
      Lcd_Cmd(_LCD_CLEAR);      // ve ekran temizlenir
      
      if(mod == 3)
         Lcd_Out(1,1,"GUNDE KAC KEZ?");
      while(mod == 3)   // mod de�eri �� ise ;yani periyodik alarm�n g�nde ka� tekrar yapaca�� se�iliyorsa bu d�ng� �al���r
      {
         if(PORTD.RD0 == 1)  // E�er artt�r tu�un bas�l�yorsa   a�a��daki kodlar icra edilir
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);
            if(tekrar == 4) // E�er g�nl�k kullan�m say�s� 4'e
               tekrar = 4;  // Ula�t�ysa daha fazla artmas� engellenir
            else
               tekrar = tekrar+1;  // Aksi takdirde bir artt�r�l�r
            ByteToStrWithZeros(tekrar,txt);
            Lcd_Chr(2,9,txt[2]);
            delay_ms(250);
         }
         if(PORTD.RD1 == 1) // E�er azalt tu�una bas�ld�ysa a�a��daki kodlar icra edilir
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);
            if(tekrar == 1)
               tekrar = 1;
            else
               tekrar = tekrar-1;
            ByteToStrWithZeros(tekrar,txt);
            Lcd_Chr(2,9,txt[2]);
            delay_ms(250);
         }
         if(PORTC.RC3 == 1)     // E�er "�PTAL" TU�UN BASILDIYSA A�A�IDAK� KODLAR ��CRA ED�L�R
         {
            alarm_kurulum = 0;
            alarm_saat = 0;
            alarm_dakika = 0;
            mod = 0;
         }
      }
      Lcd_Cmd(_LCD_CLEAR);
      Lcd_Cmd(_LCD_CURSOR_OFF);
      while(mod == 4)
      {
         Lcd_Out(1,1,"TEK SEFERLIK");
         Lcd_Out(2,1,"ALARM");
         if(PORTC.RC2 == 1)
         {
            alarm_kurulum = 1;
            mod = 5;
            delay_ms(50);
            while(PORTC.RC2);
         }
         if(PORTC.RC3 == 1)
         {
            mod = 0;
            alarm_kurulum = 0;
            delay_ms(50);
            while(PORTC.RC2);
         }
      }
      Lcd_Cmd(_LCD_CLEAR);
      if((mod == 5)&&(alarm_kurulum == 1))
      {
         Lcd_Out(1,2,"ALARM SAATI");
         alarm_kurulum_yaz();
      }
      while((mod == 5)&&(alarm_kurulum == 1))
      {
         Lcd_Cmd(_LCD_BLINK_CURSOR_ON);
         if(PORTC.RC2 == 1)
         {
            if(pos == 7)
            {
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
               pos = 10;
               delay_ms(250);
               while(PORTC.RC2);
            }
            if((pos > 7)&&(PORTC.RC2 == 1))
            {
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
               pos = pos-3;
               delay_ms(250);
               while(PORTC.RC2);
            }
         }
         if(PORTC.RC3 == 1)
         {
            alarm_kurulum = 0;
            alarm_saat = 0;
            alarm_dakika = 0;
            mod = 0;
         }
         if(PORTD.RD0 == 1)
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);
            if(pos == 10)
            {
               if(alarm_dakika == 59)
                  alarm_dakika = 0;
               else
                  alarm_dakika = alarm_dakika+1;
               ByteToStrWithZeros(alarm_dakika,txt);
               Lcd_Chr(2,9,txt[2]);
               Lcd_Chr(2,8,txt[1]);
               delay_ms(250);

            }
            if(pos == 7)
            {
               if(alarm_saat == 24)
                  alarm_saat = 0;
               else
                  alarm_saat = alarm_saat+1;
               ByteToStrWithZeros(alarm_saat,txt);
               Lcd_Chr(2,6,txt[2]);
               Lcd_Chr(2,5,txt[1]);
               delay_ms(250);
            }
         }
         if(PORTD.RD1 == 1)
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);
            if(pos == 10)
            {
               if(alarm_dakika == 0)
                  alarm_dakika = 0;
               else
                  alarm_dakika = alarm_dakika-1;
               ByteToStrWithZeros(alarm_dakika,txt);
               Lcd_Chr(2,9,txt[2]);
               Lcd_Chr(2,8,txt[1]);
               delay_ms(250);
            }
            if(pos == 7)
            {
               if(alarm_saat == 0)
                  alarm_saat = 0;
               else
                  alarm_saat = alarm_saat-1;
               ByteToStrWithZeros(alarm_saat,txt);
               Lcd_Chr(2,6,txt[2]);
               Lcd_Chr(2,5,txt[1]);
               delay_ms(250);
            }
         }
         Lcd_Cmd(_LCD_CURSOR_OFF);
      }
      Lcd_Cmd(_LCD_CURSOR_OFF);
      Lcd_Cmd(_LCD_CLEAR);
      if(mod == 10)
      {
         Lcd_Out(1,2,"SAAT KURULUMU");
         ByteToStrWithZeros(saat,txt);
         Lcd_Chr(2,4,txt[1]);
         Lcd_Chr(2,5,txt[2]);
         Lcd_Chr(2,6,':');
         ByteToStrWithZeros(dakika,txt);
         Lcd_Chr(2,7,txt[1]);
         Lcd_Chr(2,8,txt[2]);
         Lcd_Chr(2,9,':');
         ByteToStrWithZeros(saniye,txt);
         Lcd_Chr(2,11,txt[2]);
         Lcd_Chr(2,10,txt[1]);
      }
      while(mod == 10)
      {
         Lcd_Cmd(_LCD_BLINK_CURSOR_ON);
         if(PORTC.RC2 == 1)
         {
            if(pos == 4)
            {
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
               pos = 10;
               delay_ms(250);
               while(PORTC.RC2);
            }
            if((pos > 4)&&(PORTC.RC2 == 1))
            {
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
               pos = pos-3;
               delay_ms(250);
               while(PORTC.RC2);
            }
         }
         if(PORTD.RD0 == 1)
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);
            if(pos == 10)
            {
               if(saniye == 59)
                  saniye = 0;
               else
                  saniye = saniye +1;
               ByteToStrWithZeros(saniye,txt);
               Lcd_Chr(2,11,txt[2]);
               Lcd_Chr(2,10,txt[1]);
               delay_ms(250);

            }
            if(pos == 7)
            {
               if(dakika == 59)
                  dakika = 0;
               else
                  dakika = dakika +1;
               ByteToStrWithZeros(dakika,txt);
               Lcd_Chr(2,8,txt[2]);
               Lcd_Chr(2,7,txt[1]);
               delay_ms(250);
            }
            if(pos == 4)
            {

               if(saat == 24)
                  saat = 0;
               else
                  saat = saat+1;
               ByteToStrWithZeros(saat,txt);
               Lcd_Chr(2,5,txt[2]);
               Lcd_Chr(2,4,txt[1]);
               delay_ms(250);
            }
         }
         if(PORTD.RD1 == 1)
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);
            if(pos == 10)
            {
               if(saniye == 0)
                  saniye = 0;
               else
                  saniye = saniye-1;
               ByteToStrWithZeros(saniye,txt);
               Lcd_Chr(2,11,txt[2]);
               Lcd_Chr(2,10,txt[1]);
               delay_ms(250);

            }
            if(pos == 7)
            {
               if(dakika == 0)
                  dakika = 0;
               else
                  dakika = dakika-1;
               ByteToStrWithZeros(dakika,txt);
               Lcd_Chr(2,8,txt[2]);
               Lcd_Chr(2,7,txt[1]);
               delay_ms(250);
            }
            if(pos == 4)
            {
               if(saat == 0)
                  saat = 0;
               else
                  saat = saat-1;
               ByteToStrWithZeros(saat,txt);
               Lcd_Chr(2,5,txt[2]);
               Lcd_Chr(2,4,txt[1]);
               delay_ms(250);
            }
         }
         Lcd_Cmd(_LCD_CURSOR_OFF);
      }
   }
}