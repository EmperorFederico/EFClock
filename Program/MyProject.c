sbit LCD_RS at RD2_bit; // LCD'nin RS pininin, mikrodenetleyicinin hangi pinine baðlý olduðu belirtiliyor
sbit LCD_EN at RD3_bit; // LCD'nin Enable pininin, mikrodenetleyicinin hangi pinine baðlý olduðu belirtiliyor
sbit LCD_D4 at RD4_bit; // LCD'nin Data 4 pininin, mikrodenetleyicinin hangi pinine baðlý olduðu belirtiliyor
sbit LCD_D5 at RD5_bit; // LCD'nin Data 5 pininin, mikrodenetleyicinin hangi pinine baðlý olduðu belirtiliyor
sbit LCD_D6 at RD6_bit; // LCD'nin Data 6 pininin, mikrodenetleyicinin hangi pinine baðlý olduðu belirtiliyor
sbit LCD_D7 at RD7_bit; // LCD'nin Data 7 pininin, mikrodenetleyicinin hangi pinine baðlý olduðu belirtiliyor

sbit LCD_RS_Direction at TRISD2_bit;
sbit LCD_EN_Direction at TRISD3_bit;
sbit LCD_D4_Direction at TRISD4_bit;
sbit LCD_D5_Direction at TRISD5_bit;
sbit LCD_D6_Direction at TRISD6_bit;
sbit LCD_D7_Direction at TRISD7_bit;

unsigned short saniye = 0;      // ZAMANIN SANÝYESÝNÝ TUTMAK ÝÇÝN 8 bitlik deðiþken
unsigned short dakika = 0;      // ZAMANIN DAKÝKASINI TUTMAK ÝÇÝN 8 bitlik deðiþken
unsigned short saat = 0;        // ZAMANIN SAAT DEÐERÝNÝ TUTMAK ÝÇÝN 8 bitlik deðiþken
unsigned short alarm_dakika = 0;  // ALARM ZAMANININ DAKÝKASINI TUTMAK ÝÇÝN 8 bitlik deðiþken
unsigned short alarm_saat = 0;    // ALARM ZAMANININ SAATÝNÝ TUTMAK ÝÇÝN 8 bitlik deðiþken
unsigned short sayac = 0;         // TIMER1 kesmesinde kullanýlmak için tanýmlanan sayaç deðiþkeni
unsigned short mod = 0;           // Menü ekranlarý ve alt menüler arasýnda geçiþler için tanýmlanan mod deðiþkeni
unsigned short yaz = 0;            // Saniyede 1 kez ekranýn temizlenmesini saðlayacak olan bayrak deðiþkeni
unsigned short pos = 10;           // LCD imlecinin konumunun tayin edilmesi için kullanýlan deðiþken
unsigned short alarm_kurulum = 0;   // Alarm kurulumunun yapýlýp yapýlmadýðýný ya da hangi alarmýn kurulduðunu ayýrt etmek için kullanýlan deðiþken
unsigned short tekrar = 0;      // Günlük ilaç kullaným sayýsý için kullanýlan dðeiþken
unsigned yardimci = 0;    // Periyodik alarmda bir sonraki ilaç saatinin hesaplanmasý aþamasýnda kullanýlan yardýmcý deðiþken
char txt[3];  // LCD'ye sayýsal deðer yazdýrýla iblmesi için, sayýsal deðerin önce karakter haline getirilmesi gerekir. Bunun içn sayýsal deðerden karaktere dönüþtürülen verinin tutulacaðý ir karakter dizisi tanýmlanmaktadýr

void interrupt() // Herhangi bir kesme oluþtuðunda, program duraksatýlýr ve bu fonksiyona girilir. Kýsacasý bu fonksiyon, kesme fonksiyonudur
{
   if(PIR1.TMR1IF == 1) // Eðer TIMER1'in  INTERRUPT FLAG bitinin deðeri 1 ise; yani TIMER1 kesmesi (interrupt) meydana gelmiþ ise aþaðýdaki komutlar icra edilir
   {
      if(mod != 10) // Eðer mod deðiþkeninin deðeri 10'a eþit deðilse aþaðýdaki komutlar icra edilir (mod deðiþkeninin deðeri 10 ise, saat ayarý yapýlýyor demektir. Bu yüzden saat ilerletilmez ve bu kodlar icra edilmez.)
      {
         sayac = sayac+1; // Sayaç deðiþkeninin deðerini 1 arttýr (Yapýlan ayarlamalar sonucu, TIMER1 kesmesi, 200 ms periyotla meydana gelmektedir. Doðal olarak her 200ms'de bir kez sayac deðiþkeninin deðeri arttýrýlýr.)
         if(sayac == 5) // Eðer sayaç deðiþkeninin deðeri 5 ise; yani 1 saniye olmuþ ise aþaðýdaki komutlar icra edilir
         {
            saniye = saniye+1; // Saniye deðerini bir arttýr
            yaz = 1; // LCD'yi yenilemek için kullanýlan bayrak deðiþkeninin deðerini 1 yap (Yani LCD'yi temizlemek için gerekli deðeri "set" et. LCD, ana program içerisinde her döngüde temizlenecek olsaydý ekrandaki görüntü göz ile görülemezdi. Bu sebeple, LCD'ye yazma iþlemini yavaþlatmak adýna saniyede 1 kez ekran temizlenir ve yeni deðerler yazýlýr. Bu iþlem mod = 0 yani standart çalýþma modu için yapýlýr)
            if(saniye == 60) // Eðer saniye deðeri 60'a ulaþtýysa aþaðýdaki komutlar icra edilir
            {
               dakika = dakika+1; // Dakika deðiþkeninin deðeri 1 artttýrýlýr
               saniye = 0; // Saniye deðeri sýfýrlanýr
            }
            sayac = 0; // Her saniyenin sonunda sayac deðiþkeni sýfýrlanýr. Böylece sayaç deðiþkeninin taþma yapmasý (yani alabileceði maksimum deðer olan 255'e ulaþmasý ) engellenir.
         }
         if(dakika == 60)  // Eðer dakika deðeri 60'a ulaþtýysa aþaðýdaki komutlar icra edilir
         {
            saat = saat+1; // Saat deðeri 1 arttýrýlýr
            dakika = 0; // Dakika deðeri sýfýrlanýr
         }
         if(saat == 24) // Eðer saat deðeri 24'e eþitse aþaðýdaki komutlar icra edilir.
         {
            saat = 0; // Saat deðeri sýfýrlanýr
            dakika = 0; // Dakika deðeri sýfýrlanýr
            saniye = 0; // Saniye deðeri sýfýrlanýr
         }
         if((((alarm_saat == saat) && (alarm_dakika == dakika))&&(saniye == 0)) && ((alarm_kurulum == 2) || (alarm_kurulum == 3))) // Eðer kurulmuþ olan alarm saati ve dakikasý, mevcut saat ve dakikaya eþitse, eðer saniye deðeri sýfýrsa (yani o dakikaya yeni geçilmiþse) ve periyodik alarm veya tek seferlik alarm kurulmuþsa ( yani sistemde aktif bir alarm varsa ve alarm saati geldiyse aþaðýdaki kodlar icra edilir.
         {
            if(alarm_kurulum == 3)
               alarm_kurulum = 10; // Tek seferlik alarm için alarm çal
            if(alarm_kurulum == 2)
               alarm_kurulum = 11;  // Periyodik alarm için alarm çal
         }
         if((alarm_kurulum == 10)||(alarm_kurulum == 11))  // Eðer alarm çalýyorsa aþaðýdaki kodlar icra edilir
         {
            if(sayac<=3)    // sayaç deðiþkeninin deðeri 3'ten küçük veya eþitse (yani 0-600 ms arasý)
            {
               PORTB = 254; // B0 hariç tüm pinlerin çýkýþlarý Lojik-1 yapýlýr. Böylece ledler yakýlýr ve buzzer öter.
            }
            else
               PORTB = 0; // B portunun tüm pinlerinin çýkýþlarý Lojik -0 yapýlýr

         }

      }

      TMR1H = 0b00111100; // TIMER 1 sayýcýsýnýn deðerinin (saydýðý deðer) kurulumu yapýlýyor (Yüksek deðerlikli 8 bitinin)
      TMR1L = 0b10101111; // TIMER 1 sayýcýsýnýn deðerinin (saydýðý deðer) kurulumu yapýlýyor (Düþük deðerlikli 8 bitinin)
      PIR1.TMR1IF = 0; // TIMER1 sayýcýsýnýn INTERRUPT FLAG bitinin deðeri sýfýra eþitleniyor (resetleniyor). Böylece programýn, kesme fonksiyonundan çýkmasý saðlanýyor. Eðer kesme fonksiyonunun sonunda, ilgili kesmeye ait FLAG biti resetlenmezse, program sonsuz döngüye girer.
   }
   if(INTCON.INTF == 1) // Eðer INTF bitinin deðeri 1 ise, yani harici kesme meydana geldiyse aþaðýdaki kodlar icra edilir ( Diðer bir deyiþle, mod/kur tuþuna basýldýysa)
   {
      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //////////////////////// Aþaðýdaki kýsým, mod/kur tuþunun mod deðiþtirme (menü ekranlarý arasýndaki geçiþ) iþlemlerini gerçekleþtirmesini////////////////
      //////////////////////// saðlayan kod bloðudur.                                                                                          ////////////////
      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      if(alarm_kurulum != 1) // Eðer alarm kurulum bayrak deðiþkeninin deðeri 1 deðilse (yani kullanýcý herhangi bir alarm menüsünün alt menüsüne girmemiþse) aþaðýdaki kodlar icra edilir ( kullanýcý alarm kurulumu yapýlan menülerden birisine geldiði takdirde alarm_ kurulum deðikeninin deðeri 1 olarak ayarlanýr )
      {
         if((mod == 0)&&(PORTB.RB0 == 1))  // Eðer mod 0 (ana ekranda )ise ve hâlâ mod/kur tuþuna basýlýyorsa aþaðýdaki kodlar icra edilir
         {
            mod = 1;
            while(PORTB.RB0);// bu satýr sayesinde, butona ne kadar basýlý tutulursa tutulsun, kullanýcý elini çekene kadar iþlem yapýlmaz. Program burada kýsýr döngüye sokulur. Program içerisinde benzer kod satýrýný birçok yerde görebilirsiniz.
         }
         if((mod == 1)&&(PORTB.RB0 == 1))  // Eðer mod 1 ise (Periyodik alarm ekraný) ve  hâlâ mod/kur tuþuna basýlýyorsa aþaðýdaki kodlar icra edilir
         {
            mod = 4; // Periyodik alarm menüsünün alt menülerine girilmeyip mod/kur tuþuna basýldýysa modu 4 yapar
            while(PORTB.RB0);
         }
         if(mod == 2)     // Eðer mod 2 ise (Periyodik alarmýn alt menüsü. Ýlk alarm saatinin girildiði ekran )ve  hâlâ mod/kur tuþuna basýlýyorsa aþaðýdaki kodlar icra edilir
         {
            alarm_kurulum = 1; // Alarm kurulum iþleminin yapýldýðýna dair bayrak deðeri 1 yapýlýr.
            mod = 3;           // bir sonraki menüye geçiþ için mod deðeri 3 yapýlýr.
            while(PORTB.RB0);
         }
         if((mod == 4)&&(PORTB.RB0 == 1)) // Eðer mod 4 ise (Tek seferlik alarm ekraný )
         {
            mod = 10; // Mode deðiþkeninin deðeri 10 yapýlýr. Böylece, saat kurulum ekranýna geçilir.
            while(PORTB.RB0);
         }
         if((mod == 10)&&(PORTB.RB0 == 1))  // Eðer mod deðeri 10 ise (yani saat kurulum ekranýndayken mod/kur tuþuna basýldýysa) ve mod/kur tuþuna basýlý tutuluyorsa aþaðýdaki kodlar icra edilir
         {
            mod = 0; // mod deðerini sýfýrlar
            while(PORTB.RB0);
         }
      }
      ///////////////////////////////////////////////////////////////////////////////////////
      /////// Aþaðýdaki kýsým, mod/kur tuþunun; kurma iþlemlerini yaptýðý kod bloðudur //////
      ///////////////////////////////////////////////////////////////////////////////////////
      if(alarm_kurulum == 1) // eðer alarm kurulum deðeri 1 ise yani herhangi bir alarmýn alt menüsüne girilmiþse aþaðýdaki kodlar icra edilir
      {
         if(mod == 5) // Eðer mod 5 ise yani mevcut ekranda tek seferlik alarm kurulumu yapýlýyor ise aþaðýdaki kodlar icra edilir
         {
            alarm_kurulum = 3; // alarm kurulum deðiþkeninin deðeri 3 olarak atanýr.
            mod = 0; // alarm kurulumu tamamlanýr ve mod deðeri sýfýrlanarak ana ekrana geri dönülür
            while(PORTB.RB0);
         }
         if((mod == 3)&&(PORTB.RB0 == 1)) // Eðer mod 3 ise yani mevcut ekranda periyodik alarm için günde kaç kez tekrar yapýlacaðýnýn kurulumu yapýlýyor ise aþaðýdaki kodlar icra edilir
         {
            alarm_kurulum = 2; // alarm kurulum deðiþkeninin deðeri 2 olarak atanýr
            mod = 0; // alarm kurulumu tamamlanýr ve mod deðeri sýfýrlanarak ana ekrana geri dönülür
            while(PORTB.RB0);
         }
      }
      INTCON.INTF = 0;  // Harici kesmenin INTERRUPT FLAG biti resetleniyor. Aksi takdirde sistem sonsuz döngüye girecektir.
   }
}
void alarm_yaz()     // LCD ekrana alarm uyarýsýný yazdýran fonksiyonun tanýmlanmasý
{
   Lcd_Out(1,1,"ILAC SAATI"); // Birinci satýr, birinci sütundan baþlayarak ilgili metni ekrana yazar
   ByteToStrWithZeros(alarm_saat,txt); // Sayýsal bir deðer olan alarm_saat deðiþkeninin deðeri, karakter dizisi olan txt deðiþkenine dönüþtürülmektedir.
   Lcd_Chr(2,9,txt[1]); // 2. satýr 9. sütuna, txt dizisinin 2. elemanýnýn deðerini (yani alarm_saat ifadesinin onlar basamaðýný) yazdýrýr
   Lcd_Chr(2,10,txt[2]); // 2. satýr 10. sütuna, txt dizisinin 3. elemanýnýn deðerini (yani alarm_saat ifadesinin  birler basamaðýný) yazdýrýr
   Lcd_Chr(2,11,':'); // 2. satýr 11. sütuna ':' karakterini yazar. Böylelikle saat ve dakika basamaklarý arasýndaki ayrým saðlanýr
   ByteToStrWithZeros(alarm_dakika,txt); // Sayýsal bir deðer olan alarm_dakika deðiþkeninin deðeri, karakter dizisi olan txt deðiþkenine dönüþtürülmektedir.
   Lcd_Chr(2,12,txt[1]); // 2. satýr 12. sütuna, txt dizisinin 2. elemanýnýn deðerini (yani alarm_dakika ifadesinin onlar basamaðýný) yazdýrýr
   Lcd_Chr(2,13,txt[2]);// 2. satýr 13. sütuna, txt dizisinin 3. elemanýnýn deðerini (yani alarm_dakika ifadesinin  birler basamaðýný) yazdýrýr
}
void alarm_kurulum_yaz()   // Alarm kurulum ekranýný, LCD'ye yazdýran fonksiyonun tanýmlanmasý
{
   ByteToStrWithZeros(alarm_saat,txt); // Sayýsal bir deðer olan alarm_saat deðiþkeninin deðeri, karakter dizisi olan txt deðiþkenine dönüþtürülmektedir.
   Lcd_Chr(2,5,txt[1]); // 2. satýr 5. sütuna, txt dizisinin 2. elemanýnýn deðerini (yani alarm_saat ifadesinin onlar basamaðýný) yazdýrýr
   Lcd_Chr(2,6,txt[2]); // 2. satýr 6. sütuna, txt dizisinin 3. elemanýnýn deðerini (yani alarm_saat ifadesinin  birler basamaðýný) yazdýrýr
   Lcd_Chr(2,7,':'); // 2. satýr 7. sütuna ':' karakterini yazar. Böylelikle saat ve dakika basamaklarý arasýndaki ayrým saðlanýr
   ByteToStrWithZeros(alarm_dakika,txt); // Sayýsal bir deðer olan alarm_dakika deðiþkeninin deðeri, karakter dizisi olan txt deðiþkenine dönüþtürülmektedir.
   Lcd_Chr(2,9,txt[2]); // 2. satýr 12. sütuna, txt dizisinin 2. elemanýnýn deðerini (yani alarm_dakika ifadesinin onlar basamaðýný) yazdýrýr
   Lcd_Chr(2,8,txt[1]); // 2. satýr 13. sütuna, txt dizisinin 3. elemanýnýn deðerini (yani alarm_dakika ifadesinin  birler basamaðýný) yazdýrýr
}

void main()
{
   INTCON.GIE = 1;    // INTCON yazmacýnýn tüm kesmelere müsaade eden bitinin deðeri 1 yapýlýyor
   INTCON.PEIE = 1;   // INTCON yazmacýnýn çevresel kesmeleri aktive eden bitinin deðeri 1 yapýlýyor

   INTCON.INTE = 1;   // INTCON yazmacýnýn, harici kesmeyi aktifleþtiren bitiinn deðeri 1 yapýlýyor
   INTCON.INTF = 0;   // INTCON yazmacýnýn, harici kesme bayrak bitinin deðeri sýfýr yapýlýyor
   OPTION_REG.INTEDG = 1; // OPTION_REG yazmacýnýn ilgili bitinin deðeri 1 olarak ayarlanýyor. Böylece kesme iþleminin, yükselen kenarda gerçekleþmesi saðanýyor

   T1CON.T1CKPS1 = 1;  // T1CON yazmacýnýn, ön bölücü ayarýný saðlayan
   T1CON.T1CKPS0 = 0;  //  Bu iki bit, ilgili deðerlere ayarlanarak 1:4 ön bölücü oraný saðlanýyr
   T1CON.TMR1CS = 0;   // TIMER1'in, mikrodenetleyiciyi çalýþtýran ve OSC1 ile OSC2 uçlarý arasýna baðlanmýþ olan osilatör tarafýndan tetikleneceði belirtiliyor
   T1CON.TMR1ON = 1;    // TIMER1 modülü aktifleþtiriliyor
   T1CON.T1OSCEN = 0;   // TIMER1 modülü için osilatör ayarý pasif hale getiriliyor
   TMR1H = 0b00111100; // TIMER 1 sayýcýsýnýn deðerinin (saydýðý deðer) kurulumu yapýlýyor (Yüksek deðerlikli 8 bitinin)
   TMR1L = 0b10101111; // TIMER 1 sayýcýsýnýn deðerinin (saydýðý deðer) kurulumu yapýlýyor (Düþük deðerlikli 8 bitinin)
   PIR1.TMR1IF = 0; // TIMER1 sayýcýsýnýn INTERRUPT FLAG bitinin deðeri sýfýra eþitleniyor (resetleniyor). Programýn baþýnda, güvenlik ve temizlik amaçlý olarak bu iþlem yapýlýyor.
   PIE1.TMR1IE = 1;

   TRISB = 0b00000001;  // B portunun tamamý (B0 pini hariç) çýkýþ olarak ayarlanýyor
   TRISD = 0b00000011;  // D portunun ilk iki biti giriþ, geri kalanlarý çýkýþ olarak ayarlanýyor
   TRISC = 0b00001100;   // C portunun 2. ve 3. bitleri giriþ, geriye kalanlarý ise çýkýþ olarak ayarlanýyor
   PORTB = 0;  // B portunun çýkýþlarý sýfýrlanýyor. Lojik-0 seviyesine çekiliyor
   PORTC = 0; // C portunun çýkýþlarý sýfýrlanýyor. Lojik-0 seviyesine çekiliyor
   Lcd_Init();  // LCD ekran baþlatýlýyor.
   Lcd_Cmd(_LCD_CLEAR); // LCD ekran temizleniyor
   Lcd_Cmd(_LCD_CURSOR_OFF);  // LCD ekran üzerindeki imleç kapatýlýyor
   while(1)// Sonsuz döngü
   {
      Lcd_Cmd(_LCD_CLEAR); // LCD ekran temizleniyor. Her mod deðiþiminde bu döngünün sonuna gidilip baþýna dönüldüðü için
      while(mod == 0) // mod deðeri sýfýrsa yani ana ekranda ise
      {
         if((alarm_kurulum == 10)||(alarm_kurulum == 11)) // Eðer tek seferlik veya periyodik alarm kurulduysa ve alarm saati geldiyse
         {
            if(alarm_kurulum == 10)   // Eðer tek seferlik alarm saati geldiyse
            {
               alarm_yaz();    // Daha önce hazýrlanmýþ olan alarm yazdýrma fonksiyonu çaðýrýlýyor
               if(PORTC.RC3 == 1)  // Eðer "ÝPTAL" tuþuna basýlýrsa aþaðýdaki kodlar icra edilir
               {
                  alarm_kurulum = 0; // Alarmý siler
                  delay_ms(200);    // kasti olarak gecikme
                  PORTB = 0;         // B portunun tüm çýkýþlarýný sýfýrlar
                  while(PORTC.RC3);
               }
            }
            if(alarm_kurulum == 11)  // Eðer periyodik alarm çalýyorsa
            {
              alarm_yaz();        // Ekrana alarm ifadesi yazdýrýlýr
              if(PORTC.RC3 == 1)
              {
                 yardimci = 24/tekrar;  // Bir sonraki ilaç saatini hesaplamak için
                 yardimci = alarm_saat + yardimci; // gerekli iþlemler yapýlýr
                 alarm_saat = yardimci%24;       // Bu iþlemler sonucunda
                 alarm_kurulum = 2;     // Yeni alarm saati, bir sonraki ilaç saati olur
                 delay_ms(200);
                 PORTB = 0;
                 while(PORTC.RC3);
              }
           }
           }
         else // Eðer herhangi bir alarm yoksa e alarm saati gelmediyse
         {
             ByteToStrWithZeros(saat,txt);  // Sayýsal bir ifade olan saat ifadesini karakter haline getirir ve her bir basamaðý, txt isimli karakter dizisinin bir elemaný olarak atar. txt dizisi 3 elemanlýdýr. Eðer dönüþtürülen sayý 3 basamaktan küçükse, baþýna sýfýr koyar. Örneðin saat = 5 ise bu durumda txt dizisi = "005" olur
             Lcd_Out(1,1,"SAAT :");      // 1. satýr 1. sütune "SAAT :" metnini yazar.
             Lcd_Chr(1,8,txt[1]); // txt dizisinin ikinci elemaný yani saatin onlar basamaðý ekrana yazdýrýlýr
             Lcd_Chr(1,9,txt[2]); // txt dizisinin üçüncü elemaný yani saatin birler basamaðý ekrana yazdýrýlýr
             Lcd_Chr(1,10,':'); // Ekranda belirtilen konuma ':' karakterini yazar
             ByteToStrWithZeros(dakika,txt);
             Lcd_Chr(1,11,txt[1]);
             Lcd_Chr(1,12,txt[2]);
             Lcd_Chr(1,13,':');
             ByteToStrWithZeros(saniye,txt);
             Lcd_Chr(1,14,txt[1]);
             Lcd_Chr(1,15,txt[2]);
             if((alarm_kurulum == 2)||(alarm_kurulum == 3)) // Eðer sstemde kurulmuþ bir alarm var ise
             {
                Lcd_Out(2,1,"ALARM :"); // 2. satýr 1. sütundna baþlayarak "ALARM" yazar
                ByteToStrWithZeros(alarm_saat,txt); // Buradaki fonksiyonlar ile, sistemde
                Lcd_Chr(2,9,txt[1]);                // Bir alarm var ise
                Lcd_Chr(2,10,txt[2]);                // Ana ekranda, saatin altýnda
                Lcd_Chr(2,11,':');                  // Alarm ifadesinin yazmasý saðlanýr
                ByteToStrWithZeros(alarm_dakika,txt);
                Lcd_Chr(2,12,txt[1]);
                Lcd_Chr(2,13,txt[2]);
             }
             if(yaz == 1)  // yaz deðeri 1 ise, yani 1 saniye geçtiyse
             {
                Lcd_Cmd(_LCD_CLEAR);// LCD'yi temizle
                yaz = 0;   // yaz deðerini sýfýrla
             }
             if(PORTC.RC3 == 1) // Eðer "ÇIK/ÝPTAL/SÝL "  tuþuna basýldýysa
             {
                   alarm_dakika = 0; // Tüm alarm verilerini
                   alarm_saat = 0;   // Siler
                   alarm_kurulum = 0;
             }
          }
      }
      Lcd_Cmd(_LCD_CLEAR);
      Lcd_Cmd(_LCD_CURSOR_OFF);
      while(mod == 1)  // mod deðiþkeninin deðeri 1 oldukça aþaðýdaki kodlar icra edilir.
      {
         Lcd_Out(1,1,"PERIYODIK ALARM");   // 1. satýr ve 1. sütundan baþlayarak ekrana ilgili metin ifadesini yazdýrý.
         if(PORTC.RC2 == 1)  // Eðer "SEÇ" tuþuna basýldýysa aþaðýdaki kodlar icra edilir
         {
            mod = 2;     // mod deðiþkeninin deðeri 2 yapýlýr. Böylece, periyodik alarmýn baþlangýç saatinin ayarlandýðý alt menüye girilir.
            delay_ms(200);  // sistemi kasti olarak yavaþlatmak için 200 ms'lik gecikme fonksiyonu kullanýlýr
         }
         if(PORTC.RC3 == 1)   // Eðer "ÝPTAL/ÇIK/SÝL" tuþuna basýldýysa aþaðýdaki kodlar icra edilir
         {
            mod = 0;  // mod deðiþkeninin deðeri 0 yapýlýr. Böylece, ana ekrana geri dönülür
            delay_ms(200);// sistemi kasti olarak yavaþlatmak için 200 ms'lik gecikme fonksiyonu kullanýlýr
         }
      }
      Lcd_Cmd(_LCD_CLEAR); // ekraný temizler
      
      if(mod == 2)  // Eðer mod deðiþkeninin deðeri 2 ise, bu kod bloðu yalnýzca bir kez çalýþýr. Bunun sebebi, LCD'ye sonsuz döngü içerisinde gecikme fonksiyonlarý kullanmadan
      {   // bir metin ifadesinin yazýlmasý sýrasýnda, sisstem çok hýzlý çalýþtýðý için yazýlan karakterlerin tam olarak görünememesidir. Bu sebeple, bir kez
         Lcd_Out(1,2,"ILK ALARM");  // "ILK ALARM" ifadesi ekrana yazdýrýlýr ve bir sonraki ekran temizleme komuduna kadar ekranda kalýr
         alarm_kurulum_yaz();  // daha önce tanýmlanmýþ olan fonksiyon çaðýrýlýyor
      }
      while(mod == 2)// Bu kod bloðu, mod deðiþkeninin deðeri 2 olduðu sürece çalýþýr
      {
         Lcd_Cmd(_LCD_BLINK_CURSOR_ON);
         if(PORTC.RC2 == 1) // eðer "SEÇ" tuþuna basýldýysa aþaðýdaki kodlar icra edilir. Burada seç tuþu, basamaklar arasýnda deðiþimi saðlamaktadýr.
         {
            if(pos == 7) // eðer imleç pozisyonu için tanýmlanan deðiþkenin deðeri 7 ise aþaðýdaki kodlar icra edilir. BU kýsým ve alttaki kýsým tamamen, kullanýcýya hangi basamakta bulunduðunu belirten imlecin konumu ve gösterimi ile ilgilidir
            {
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT); // LCD ekran üzerindeki imleç bir birim saða kaydýrýlýr
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT); // LCD ekran üzerindeki imleç bir birim saða kaydýrýlýr
               Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT); // LCD ekran üzerindeki imleç bir birim saða kaydýrýlýr
               pos = 10;      // imleç pozisyonu için tanýmlanan deðiþkenin deðeri 10 olarak atanýr
               Delay_ms(250); // sistemi yavaþlatmak adýna 250 ms'lik kasti gecikme eklenir
               while(PORTC.RC2);
            }
            if((pos > 7)&&(PORTC.RC2 == 1)) // Eðer pozisyon deðiþkeninin deðeri 7'den büyükse ve "SEÇ" tuþuna basýlýyorsa (&&(PORTC.RC2 == 1) kýsmý olmasaydý, bir önceki koþul ifadesinde pos = 10 olarak atandýðý için, program otomatik olarak bu koþulun da içerisine girecekti)
            {
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);   // LCD ekran üzerindeki imleç bir birim sola kaydýrýlýr
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);   // LCD ekran üzerindeki imleç bir birim sola kaydýrýlýr
               Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);   // LCD ekran üzerindeki imleç bir birim sola kaydýrýlýr
               pos = pos-3;      // imleç pozisyonu için tanýmlanan deðiþkenin deðeri 3 azaltýlýr
               delay_ms(250);
               while(PORTC.RC2);
            }
         }
         if(PORTC.RC3 == 1)  // Eðer alarm kurulum alt menüsünde "ÝPTAL/ÇIK/SÝL" tuþuna basýldýysa aþaðýdaki kodlar icra edilir.
         {
            alarm_kurulum = 0;  // Alarmlar ile ilgili olan
            alarm_saat = 0;     // Tüm sistem parametreleri
            alarm_dakika = 0;   // Sýfýrlanýr
            mod = 0;            // Mode deðeri sýfýrlanarak ana ekrana dönüþ saðlanýr
         }
         if(PORTD.RD0 == 1) // Eðer ARTTIR tuþuna basýldýysa
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);  // LCD'de görülen imleci kapatýr. Bunun sebebi, aþaðýda bulunan LCD_chr fonksiyonundan önce imleç kapatýlmazsa, her karakteri ekrana yazarken imlecin de metin boyunca hareket ediþinin görünür olmasýdýr.
            if(pos == 10) // eðer imleç pozisyon deðeri 10 ise yani kullanýcý dakika basamaðýndaysa
            {
               if(alarm_dakika == 59) //eðer alarm_dakika deðiþkeninin deðeri 59 ise
                  alarm_dakika = 0;    // deðeri sýfýrlar (baþa döndürür)
               else                    // eðer alarm_dakika deðiþkeninin deðeri 59 deðil ise
                  alarm_dakika = alarm_dakika+1;  // alarm_dakika deðiþkeninin deðerini 1 arttýrýr
               ByteToStrWithZeros(alarm_dakika,txt);
               Lcd_Chr(2,9,txt[2]); // Ekrana yeni alarm_dakika deðeri yazdýrýlýr. ÖNCE BÝRLER BASAMAÐININ, ARDINDAN ONLAR BASAMAÐININ YAZDIRILMA SEBEBÝ ÞUDUR;
               Lcd_Chr(2,8,txt[1]);  // ÝMLEÇ AÇILDIÐI ZAMAN, EN SON ÝÞLEM YAPILAN SÜTUNUN BÝR SAÐINDA ORTAYA ÇIKAR. ÝMLECÝN 9. SÜTUNDA YANÝ DAKÝKA ÝFADESÝNÝN
               // BÝRLER BASAMAÐINDA GÖRÜNÜR OLMASI ÝÇÝN, EN SON YAPILAN ÝÞLEM ONLAR BASAMAÐINA YAPILIR
               delay_ms(250);

            }
            if(pos == 7)  // eðer imleç pozisyon deðeri 7 ise yani kullanýcý SAAT basamaðýndaysa
            {
               if(alarm_saat == 24)        // Bu kez, yukarýda dakika mertebesi için yapýlan iþlemlerin aynýsý, saat mertebesi için yapýlýr
                  alarm_saat = 0;
               else
                  alarm_saat = alarm_saat+1;
               ByteToStrWithZeros(alarm_saat,txt);
               Lcd_Chr(2,6,txt[2]);
               Lcd_Chr(2,5,txt[1]);
               delay_ms(250);
            }
         }
         if(PORTD.RD1 == 1)// Eðer AZALT tuþuna basýldýysa
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);// LCD üzerindeki imleç kapatýlýr
            if(pos == 10)            // Bu aþamada
            {                         // Arttýr tuþuna basýldýðýnda
               if(alarm_dakika == 0)  // gerçekleþen iþlelerin aynýlarý
                  alarm_dakika = 0;   // bu kez alarm_saat ve alarm_dakika deðiþkenleerinin deðerleri a
               else                   // azaltýlacak þekilde tekrarlanýr
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
      Lcd_Cmd(_LCD_CURSOR_OFF); // modlar arasý geçiþlerde güvenlik amacýyla imleç kapatýlýr
      Lcd_Cmd(_LCD_CLEAR);      // ve ekran temizlenir
      
      if(mod == 3)
         Lcd_Out(1,1,"GUNDE KAC KEZ?");
      while(mod == 3)   // mod deðeri üç ise ;yani periyodik alarmýn günde kaç tekrar yapacaðý seçiliyorsa bu döngü çalýþýr
      {
         if(PORTD.RD0 == 1)  // Eðer arttýr tuþun basýlýyorsa   aþaðýdaki kodlar icra edilir
         {
            Lcd_Cmd(_LCD_CURSOR_OFF);
            if(tekrar == 4) // Eðer günlük kullaným sayýsý 4'e
               tekrar = 4;  // Ulaþtýysa daha fazla artmasý engellenir
            else
               tekrar = tekrar+1;  // Aksi takdirde bir arttýrýlýr
            ByteToStrWithZeros(tekrar,txt);
            Lcd_Chr(2,9,txt[2]);
            delay_ms(250);
         }
         if(PORTD.RD1 == 1) // Eðer azalt tuþuna basýldýysa aþaðýdaki kodlar icra edilir
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
         if(PORTC.RC3 == 1)     // Eðer "ÝPTAL" TUÞUN BASILDIYSA AÞAÐIDAKÝ KODLAR ÝÝCRA EDÝLÝR
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