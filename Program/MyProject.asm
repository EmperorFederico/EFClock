
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;MyProject.c,29 :: 		void interrupt() // Herhangi bir kesme olu�tu�unda, program duraksat�l�r ve bu fonksiyona girilir. K�sacas� bu fonksiyon, kesme fonksiyonudur
;MyProject.c,31 :: 		if(PIR1.TMR1IF == 1) // E�er TIMER1'in  INTERRUPT FLAG bitinin de�eri 1 ise; yani TIMER1 kesmesi (interrupt) meydana gelmi� ise a�a��daki komutlar icra edilir
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt0
;MyProject.c,33 :: 		if(mod != 10) // E�er mod de�i�keninin de�eri 10'a e�it de�ilse a�a��daki komutlar icra edilir (mod de�i�keninin de�eri 10 ise, saat ayar� yap�l�yor demektir. Bu y�zden saat ilerletilmez ve bu kodlar icra edilmez.)
	MOVF       _mod+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt1
;MyProject.c,35 :: 		sayac = sayac+1; // Saya� de�i�keninin de�erini 1 artt�r (Yap�lan ayarlamalar sonucu, TIMER1 kesmesi, 200 ms periyotla meydana gelmektedir. Do�al olarak her 200ms'de bir kez sayac de�i�keninin de�eri artt�r�l�r.)
	INCF       _sayac+0, 1
;MyProject.c,36 :: 		if(sayac == 5) // E�er saya� de�i�keninin de�eri 5 ise; yani 1 saniye olmu� ise a�a��daki komutlar icra edilir
	MOVF       _sayac+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt2
;MyProject.c,38 :: 		saniye = saniye+1; // Saniye de�erini bir artt�r
	INCF       _saniye+0, 1
;MyProject.c,39 :: 		yaz = 1; // LCD'yi yenilemek i�in kullan�lan bayrak de�i�keninin de�erini 1 yap (Yani LCD'yi temizlemek i�in gerekli de�eri "set" et. LCD, ana program i�erisinde her d�ng�de temizlenecek olsayd� ekrandaki g�r�nt� g�z ile g�r�lemezdi. Bu sebeple, LCD'ye yazma i�lemini yava�latmak ad�na saniyede 1 kez ekran temizlenir ve yeni de�erler yaz�l�r. Bu i�lem mod = 0 yani standart �al��ma modu i�in yap�l�r)
	MOVLW      1
	MOVWF      _yaz+0
;MyProject.c,40 :: 		if(saniye == 60) // E�er saniye de�eri 60'a ula�t�ysa a�a��daki komutlar icra edilir
	MOVF       _saniye+0, 0
	XORLW      60
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt3
;MyProject.c,42 :: 		dakika = dakika+1; // Dakika de�i�keninin de�eri 1 arttt�r�l�r
	INCF       _dakika+0, 1
;MyProject.c,43 :: 		saniye = 0; // Saniye de�eri s�f�rlan�r
	CLRF       _saniye+0
;MyProject.c,44 :: 		}
L_interrupt3:
;MyProject.c,45 :: 		sayac = 0; // Her saniyenin sonunda sayac de�i�keni s�f�rlan�r. B�ylece saya� de�i�keninin ta�ma yapmas� (yani alabilece�i maksimum de�er olan 255'e ula�mas� ) engellenir.
	CLRF       _sayac+0
;MyProject.c,46 :: 		}
L_interrupt2:
;MyProject.c,47 :: 		if(dakika == 60)  // E�er dakika de�eri 60'a ula�t�ysa a�a��daki komutlar icra edilir
	MOVF       _dakika+0, 0
	XORLW      60
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt4
;MyProject.c,49 :: 		saat = saat+1; // Saat de�eri 1 artt�r�l�r
	INCF       _saat+0, 1
;MyProject.c,50 :: 		dakika = 0; // Dakika de�eri s�f�rlan�r
	CLRF       _dakika+0
;MyProject.c,51 :: 		}
L_interrupt4:
;MyProject.c,52 :: 		if(saat == 24) // E�er saat de�eri 24'e e�itse a�a��daki komutlar icra edilir.
	MOVF       _saat+0, 0
	XORLW      24
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt5
;MyProject.c,54 :: 		saat = 0; // Saat de�eri s�f�rlan�r
	CLRF       _saat+0
;MyProject.c,55 :: 		dakika = 0; // Dakika de�eri s�f�rlan�r
	CLRF       _dakika+0
;MyProject.c,56 :: 		saniye = 0; // Saniye de�eri s�f�rlan�r
	CLRF       _saniye+0
;MyProject.c,57 :: 		}
L_interrupt5:
;MyProject.c,58 :: 		if((((alarm_saat == saat) && (alarm_dakika == dakika))&&(saniye == 0)) && ((alarm_kurulum == 2) || (alarm_kurulum == 3))) // E�er kurulmu� olan alarm saati ve dakikas�, mevcut saat ve dakikaya e�itse, e�er saniye de�eri s�f�rsa (yani o dakikaya yeni ge�ilmi�se) ve periyodik alarm veya tek seferlik alarm kurulmu�sa ( yani sistemde aktif bir alarm varsa ve alarm saati geldiyse a�a��daki kodlar icra edilir.
	MOVF       _alarm_saat+0, 0
	XORWF      _saat+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
	MOVF       _alarm_dakika+0, 0
	XORWF      _dakika+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
L__interrupt226:
	MOVF       _saniye+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt14
L__interrupt225:
	MOVF       _alarm_kurulum+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt224
	MOVF       _alarm_kurulum+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt224
	GOTO       L_interrupt14
L__interrupt224:
L__interrupt223:
;MyProject.c,60 :: 		if(alarm_kurulum == 3)
	MOVF       _alarm_kurulum+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt15
;MyProject.c,61 :: 		alarm_kurulum = 10; // Tek seferlik alarm i�in alarm �al
	MOVLW      10
	MOVWF      _alarm_kurulum+0
L_interrupt15:
;MyProject.c,62 :: 		if(alarm_kurulum == 2)
	MOVF       _alarm_kurulum+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt16
;MyProject.c,63 :: 		alarm_kurulum = 11;  // Periyodik alarm i�in alarm �al
	MOVLW      11
	MOVWF      _alarm_kurulum+0
L_interrupt16:
;MyProject.c,64 :: 		}
L_interrupt14:
;MyProject.c,65 :: 		if((alarm_kurulum == 10)||(alarm_kurulum == 11))  // E�er alarm �al�yorsa a�a��daki kodlar icra edilir
	MOVF       _alarm_kurulum+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt222
	MOVF       _alarm_kurulum+0, 0
	XORLW      11
	BTFSC      STATUS+0, 2
	GOTO       L__interrupt222
	GOTO       L_interrupt19
L__interrupt222:
;MyProject.c,67 :: 		if(sayac<=3)    // saya� de�i�keninin de�eri 3'ten k���k veya e�itse (yani 0-600 ms aras�)
	MOVF       _sayac+0, 0
	SUBLW      3
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt20
;MyProject.c,69 :: 		PORTB = 254; // B0 hari� t�m pinlerin ��k��lar� Lojik-1 yap�l�r. B�ylece ledler yak�l�r ve buzzer �ter.
	MOVLW      254
	MOVWF      PORTB+0
;MyProject.c,70 :: 		}
	GOTO       L_interrupt21
L_interrupt20:
;MyProject.c,72 :: 		PORTB = 0; // B portunun t�m pinlerinin ��k��lar� Lojik -0 yap�l�r
	CLRF       PORTB+0
L_interrupt21:
;MyProject.c,74 :: 		}
L_interrupt19:
;MyProject.c,76 :: 		}
L_interrupt1:
;MyProject.c,78 :: 		TMR1H = 0b00111100; // TIMER 1 say�c�s�n�n de�erinin (sayd��� de�er) kurulumu yap�l�yor (Y�ksek de�erlikli 8 bitinin)
	MOVLW      60
	MOVWF      TMR1H+0
;MyProject.c,79 :: 		TMR1L = 0b10101111; // TIMER 1 say�c�s�n�n de�erinin (sayd��� de�er) kurulumu yap�l�yor (D���k de�erlikli 8 bitinin)
	MOVLW      175
	MOVWF      TMR1L+0
;MyProject.c,80 :: 		PIR1.TMR1IF = 0; // TIMER1 say�c�s�n�n INTERRUPT FLAG bitinin de�eri s�f�ra e�itleniyor (resetleniyor). B�ylece program�n, kesme fonksiyonundan ��kmas� sa�lan�yor. E�er kesme fonksiyonunun sonunda, ilgili kesmeye ait FLAG biti resetlenmezse, program sonsuz d�ng�ye girer.
	BCF        PIR1+0, 0
;MyProject.c,81 :: 		}
L_interrupt0:
;MyProject.c,82 :: 		if(INTCON.INTF == 1) // E�er INTF bitinin de�eri 1 ise, yani harici kesme meydana geldiyse a�a��daki kodlar icra edilir ( Di�er bir deyi�le, mod/kur tu�una bas�ld�ysa)
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt22
;MyProject.c,88 :: 		if(alarm_kurulum != 1) // E�er alarm kurulum bayrak de�i�keninin de�eri 1 de�ilse (yani kullan�c� herhangi bir alarm men�s�n�n alt men�s�ne girmemi�se) a�a��daki kodlar icra edilir ( kullan�c� alarm kurulumu yap�lan men�lerden birisine geldi�i takdirde alarm_ kurulum de�ikeninin de�eri 1 olarak ayarlan�r )
	MOVF       _alarm_kurulum+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt23
;MyProject.c,90 :: 		if((mod == 0)&&(PORTB.RB0 == 1))  // E�er mod 0 (ana ekranda )ise ve h�l� mod/kur tu�una bas�l�yorsa a�a��daki kodlar icra edilir
	MOVF       _mod+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt26
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt26
L__interrupt221:
;MyProject.c,92 :: 		mod = 1;
	MOVLW      1
	MOVWF      _mod+0
;MyProject.c,93 :: 		while(PORTB.RB0);// bu sat�r sayesinde, butona ne kadar bas�l� tutulursa tutulsun, kullan�c� elini �ekene kadar i�lem yap�lmaz. Program burada k�s�r d�ng�ye sokulur. Program i�erisinde benzer kod sat�r�n� bir�ok yerde g�rebilirsiniz.
L_interrupt27:
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt28
	GOTO       L_interrupt27
L_interrupt28:
;MyProject.c,94 :: 		}
L_interrupt26:
;MyProject.c,95 :: 		if((mod == 1)&&(PORTB.RB0 == 1))  // E�er mod 1 ise (Periyodik alarm ekran�) ve  h�l� mod/kur tu�una bas�l�yorsa a�a��daki kodlar icra edilir
	MOVF       _mod+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt31
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt31
L__interrupt220:
;MyProject.c,97 :: 		mod = 4; // Periyodik alarm men�s�n�n alt men�lerine girilmeyip mod/kur tu�una bas�ld�ysa modu 4 yapar
	MOVLW      4
	MOVWF      _mod+0
;MyProject.c,98 :: 		while(PORTB.RB0);
L_interrupt32:
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt33
	GOTO       L_interrupt32
L_interrupt33:
;MyProject.c,99 :: 		}
L_interrupt31:
;MyProject.c,100 :: 		if(mod == 2)     // E�er mod 2 ise (Periyodik alarm�n alt men�s�. �lk alarm saatinin girildi�i ekran )ve  h�l� mod/kur tu�una bas�l�yorsa a�a��daki kodlar icra edilir
	MOVF       _mod+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt34
;MyProject.c,102 :: 		alarm_kurulum = 1; // Alarm kurulum i�leminin yap�ld���na dair bayrak de�eri 1 yap�l�r.
	MOVLW      1
	MOVWF      _alarm_kurulum+0
;MyProject.c,103 :: 		mod = 3;           // bir sonraki men�ye ge�i� i�in mod de�eri 3 yap�l�r.
	MOVLW      3
	MOVWF      _mod+0
;MyProject.c,104 :: 		while(PORTB.RB0);
L_interrupt35:
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt36
	GOTO       L_interrupt35
L_interrupt36:
;MyProject.c,105 :: 		}
L_interrupt34:
;MyProject.c,106 :: 		if((mod == 4)&&(PORTB.RB0 == 1)) // E�er mod 4 ise (Tek seferlik alarm ekran� )
	MOVF       _mod+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt39
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt39
L__interrupt219:
;MyProject.c,108 :: 		mod = 10; // Mode de�i�keninin de�eri 10 yap�l�r. B�ylece, saat kurulum ekran�na ge�ilir.
	MOVLW      10
	MOVWF      _mod+0
;MyProject.c,109 :: 		while(PORTB.RB0);
L_interrupt40:
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt41
	GOTO       L_interrupt40
L_interrupt41:
;MyProject.c,110 :: 		}
L_interrupt39:
;MyProject.c,111 :: 		if((mod == 10)&&(PORTB.RB0 == 1))  // E�er mod de�eri 10 ise (yani saat kurulum ekran�ndayken mod/kur tu�una bas�ld�ysa) ve mod/kur tu�una bas�l� tutuluyorsa a�a��daki kodlar icra edilir
	MOVF       _mod+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt44
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt44
L__interrupt218:
;MyProject.c,113 :: 		mod = 0; // mod de�erini s�f�rlar
	CLRF       _mod+0
;MyProject.c,114 :: 		while(PORTB.RB0);
L_interrupt45:
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt46
	GOTO       L_interrupt45
L_interrupt46:
;MyProject.c,115 :: 		}
L_interrupt44:
;MyProject.c,116 :: 		}
L_interrupt23:
;MyProject.c,120 :: 		if(alarm_kurulum == 1) // e�er alarm kurulum de�eri 1 ise yani herhangi bir alarm�n alt men�s�ne girilmi�se a�a��daki kodlar icra edilir
	MOVF       _alarm_kurulum+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt47
;MyProject.c,122 :: 		if(mod == 5) // E�er mod 5 ise yani mevcut ekranda tek seferlik alarm kurulumu yap�l�yor ise a�a��daki kodlar icra edilir
	MOVF       _mod+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt48
;MyProject.c,124 :: 		alarm_kurulum = 3; // alarm kurulum de�i�keninin de�eri 3 olarak atan�r.
	MOVLW      3
	MOVWF      _alarm_kurulum+0
;MyProject.c,125 :: 		mod = 0; // alarm kurulumu tamamlan�r ve mod de�eri s�f�rlanarak ana ekrana geri d�n�l�r
	CLRF       _mod+0
;MyProject.c,126 :: 		while(PORTB.RB0);
L_interrupt49:
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt50
	GOTO       L_interrupt49
L_interrupt50:
;MyProject.c,127 :: 		}
L_interrupt48:
;MyProject.c,128 :: 		if((mod == 3)&&(PORTB.RB0 == 1)) // E�er mod 3 ise yani mevcut ekranda periyodik alarm i�in g�nde ka� kez tekrar yap�laca��n�n kurulumu yap�l�yor ise a�a��daki kodlar icra edilir
	MOVF       _mod+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt53
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt53
L__interrupt217:
;MyProject.c,130 :: 		alarm_kurulum = 2; // alarm kurulum de�i�keninin de�eri 2 olarak atan�r
	MOVLW      2
	MOVWF      _alarm_kurulum+0
;MyProject.c,131 :: 		mod = 0; // alarm kurulumu tamamlan�r ve mod de�eri s�f�rlanarak ana ekrana geri d�n�l�r
	CLRF       _mod+0
;MyProject.c,132 :: 		while(PORTB.RB0);
L_interrupt54:
	BTFSS      PORTB+0, 0
	GOTO       L_interrupt55
	GOTO       L_interrupt54
L_interrupt55:
;MyProject.c,133 :: 		}
L_interrupt53:
;MyProject.c,134 :: 		}
L_interrupt47:
;MyProject.c,135 :: 		INTCON.INTF = 0;  // Harici kesmenin INTERRUPT FLAG biti resetleniyor. Aksi takdirde sistem sonsuz d�ng�ye girecektir.
	BCF        INTCON+0, 1
;MyProject.c,136 :: 		}
L_interrupt22:
;MyProject.c,137 :: 		}
L_end_interrupt:
L__interrupt235:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_alarm_yaz:

;MyProject.c,138 :: 		void alarm_yaz()     // LCD ekrana alarm uyar�s�n� yazd�ran fonksiyonun tan�mlanmas�
;MyProject.c,140 :: 		Lcd_Out(1,1,"ILAC SAATI"); // Birinci sat�r, birinci s�tundan ba�layarak ilgili metni ekrana yazar
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr1_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject.c,141 :: 		ByteToStrWithZeros(alarm_saat,txt); // Say�sal bir de�er olan alarm_saat de�i�keninin de�eri, karakter dizisi olan txt de�i�kenine d�n��t�r�lmektedir.
	MOVF       _alarm_saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,142 :: 		Lcd_Chr(2,9,txt[1]); // 2. sat�r 9. s�tuna, txt dizisinin 2. eleman�n�n de�erini (yani alarm_saat ifadesinin onlar basama��n�) yazd�r�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,143 :: 		Lcd_Chr(2,10,txt[2]); // 2. sat�r 10. s�tuna, txt dizisinin 3. eleman�n�n de�erini (yani alarm_saat ifadesinin  birler basama��n�) yazd�r�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      10
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,144 :: 		Lcd_Chr(2,11,':'); // 2. sat�r 11. s�tuna ':' karakterini yazar. B�ylelikle saat ve dakika basamaklar� aras�ndaki ayr�m sa�lan�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      11
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,145 :: 		ByteToStrWithZeros(alarm_dakika,txt); // Say�sal bir de�er olan alarm_dakika de�i�keninin de�eri, karakter dizisi olan txt de�i�kenine d�n��t�r�lmektedir.
	MOVF       _alarm_dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,146 :: 		Lcd_Chr(2,12,txt[1]); // 2. sat�r 12. s�tuna, txt dizisinin 2. eleman�n�n de�erini (yani alarm_dakika ifadesinin onlar basama��n�) yazd�r�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      12
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,147 :: 		Lcd_Chr(2,13,txt[2]);// 2. sat�r 13. s�tuna, txt dizisinin 3. eleman�n�n de�erini (yani alarm_dakika ifadesinin  birler basama��n�) yazd�r�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      13
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,148 :: 		}
L_end_alarm_yaz:
	RETURN
; end of _alarm_yaz

_alarm_kurulum_yaz:

;MyProject.c,149 :: 		void alarm_kurulum_yaz()   // Alarm kurulum ekran�n�, LCD'ye yazd�ran fonksiyonun tan�mlanmas�
;MyProject.c,151 :: 		ByteToStrWithZeros(alarm_saat,txt); // Say�sal bir de�er olan alarm_saat de�i�keninin de�eri, karakter dizisi olan txt de�i�kenine d�n��t�r�lmektedir.
	MOVF       _alarm_saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,152 :: 		Lcd_Chr(2,5,txt[1]); // 2. sat�r 5. s�tuna, txt dizisinin 2. eleman�n�n de�erini (yani alarm_saat ifadesinin onlar basama��n�) yazd�r�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,153 :: 		Lcd_Chr(2,6,txt[2]); // 2. sat�r 6. s�tuna, txt dizisinin 3. eleman�n�n de�erini (yani alarm_saat ifadesinin  birler basama��n�) yazd�r�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,154 :: 		Lcd_Chr(2,7,':'); // 2. sat�r 7. s�tuna ':' karakterini yazar. B�ylelikle saat ve dakika basamaklar� aras�ndaki ayr�m sa�lan�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,155 :: 		ByteToStrWithZeros(alarm_dakika,txt); // Say�sal bir de�er olan alarm_dakika de�i�keninin de�eri, karakter dizisi olan txt de�i�kenine d�n��t�r�lmektedir.
	MOVF       _alarm_dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,156 :: 		Lcd_Chr(2,9,txt[2]); // 2. sat�r 12. s�tuna, txt dizisinin 2. eleman�n�n de�erini (yani alarm_dakika ifadesinin onlar basama��n�) yazd�r�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,157 :: 		Lcd_Chr(2,8,txt[1]); // 2. sat�r 13. s�tuna, txt dizisinin 3. eleman�n�n de�erini (yani alarm_dakika ifadesinin  birler basama��n�) yazd�r�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,158 :: 		}
L_end_alarm_kurulum_yaz:
	RETURN
; end of _alarm_kurulum_yaz

_main:

;MyProject.c,160 :: 		void main()
;MyProject.c,162 :: 		INTCON.GIE = 1;    // INTCON yazmac�n�n t�m kesmelere m�saade eden bitinin de�eri 1 yap�l�yor
	BSF        INTCON+0, 7
;MyProject.c,163 :: 		INTCON.PEIE = 1;   // INTCON yazmac�n�n �evresel kesmeleri aktive eden bitinin de�eri 1 yap�l�yor
	BSF        INTCON+0, 6
;MyProject.c,165 :: 		INTCON.INTE = 1;   // INTCON yazmac�n�n, harici kesmeyi aktifle�tiren bitiinn de�eri 1 yap�l�yor
	BSF        INTCON+0, 4
;MyProject.c,166 :: 		INTCON.INTF = 0;   // INTCON yazmac�n�n, harici kesme bayrak bitinin de�eri s�f�r yap�l�yor
	BCF        INTCON+0, 1
;MyProject.c,167 :: 		OPTION_REG.INTEDG = 1; // OPTION_REG yazmac�n�n ilgili bitinin de�eri 1 olarak ayarlan�yor. B�ylece kesme i�leminin, y�kselen kenarda ger�ekle�mesi sa�an�yor
	BSF        OPTION_REG+0, 6
;MyProject.c,169 :: 		T1CON.T1CKPS1 = 1;  // T1CON yazmac�n�n, �n b�l�c� ayar�n� sa�layan
	BSF        T1CON+0, 5
;MyProject.c,170 :: 		T1CON.T1CKPS0 = 0;  //  Bu iki bit, ilgili de�erlere ayarlanarak 1:4 �n b�l�c� oran� sa�lan�yr
	BCF        T1CON+0, 4
;MyProject.c,171 :: 		T1CON.TMR1CS = 0;   // TIMER1'in, mikrodenetleyiciyi �al��t�ran ve OSC1 ile OSC2 u�lar� aras�na ba�lanm�� olan osilat�r taraf�ndan tetiklenece�i belirtiliyor
	BCF        T1CON+0, 1
;MyProject.c,172 :: 		T1CON.TMR1ON = 1;    // TIMER1 mod�l� aktifle�tiriliyor
	BSF        T1CON+0, 0
;MyProject.c,173 :: 		T1CON.T1OSCEN = 0;   // TIMER1 mod�l� i�in osilat�r ayar� pasif hale getiriliyor
	BCF        T1CON+0, 3
;MyProject.c,174 :: 		TMR1H = 0b00111100; // TIMER 1 say�c�s�n�n de�erinin (sayd��� de�er) kurulumu yap�l�yor (Y�ksek de�erlikli 8 bitinin)
	MOVLW      60
	MOVWF      TMR1H+0
;MyProject.c,175 :: 		TMR1L = 0b10101111; // TIMER 1 say�c�s�n�n de�erinin (sayd��� de�er) kurulumu yap�l�yor (D���k de�erlikli 8 bitinin)
	MOVLW      175
	MOVWF      TMR1L+0
;MyProject.c,176 :: 		PIR1.TMR1IF = 0; // TIMER1 say�c�s�n�n INTERRUPT FLAG bitinin de�eri s�f�ra e�itleniyor (resetleniyor). Program�n ba��nda, g�venlik ve temizlik ama�l� olarak bu i�lem yap�l�yor.
	BCF        PIR1+0, 0
;MyProject.c,177 :: 		PIE1.TMR1IE = 1;
	BSF        PIE1+0, 0
;MyProject.c,179 :: 		TRISB = 0b00000001;  // B portunun tamam� (B0 pini hari�) ��k�� olarak ayarlan�yor
	MOVLW      1
	MOVWF      TRISB+0
;MyProject.c,180 :: 		TRISD = 0b00000011;  // D portunun ilk iki biti giri�, geri kalanlar� ��k�� olarak ayarlan�yor
	MOVLW      3
	MOVWF      TRISD+0
;MyProject.c,181 :: 		TRISC = 0b00001100;   // C portunun 2. ve 3. bitleri giri�, geriye kalanlar� ise ��k�� olarak ayarlan�yor
	MOVLW      12
	MOVWF      TRISC+0
;MyProject.c,182 :: 		PORTB = 0;  // B portunun ��k��lar� s�f�rlan�yor. Lojik-0 seviyesine �ekiliyor
	CLRF       PORTB+0
;MyProject.c,183 :: 		PORTC = 0; // C portunun ��k��lar� s�f�rlan�yor. Lojik-0 seviyesine �ekiliyor
	CLRF       PORTC+0
;MyProject.c,184 :: 		Lcd_Init();  // LCD ekran ba�lat�l�yor.
	CALL       _Lcd_Init+0
;MyProject.c,185 :: 		Lcd_Cmd(_LCD_CLEAR); // LCD ekran temizleniyor
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,186 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);  // LCD ekran �zerindeki imle� kapat�l�yor
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,187 :: 		while(1)// Sonsuz d�ng�
L_main56:
;MyProject.c,189 :: 		Lcd_Cmd(_LCD_CLEAR); // LCD ekran temizleniyor. Her mod de�i�iminde bu d�ng�n�n sonuna gidilip ba��na d�n�ld��� i�in
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,190 :: 		while(mod == 0) // mod de�eri s�f�rsa yani ana ekranda ise
L_main58:
	MOVF       _mod+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main59
;MyProject.c,192 :: 		if((alarm_kurulum == 10)||(alarm_kurulum == 11)) // E�er tek seferlik veya periyodik alarm kurulduysa ve alarm saati geldiyse
	MOVF       _alarm_kurulum+0, 0
	XORLW      10
	BTFSC      STATUS+0, 2
	GOTO       L__main233
	MOVF       _alarm_kurulum+0, 0
	XORLW      11
	BTFSC      STATUS+0, 2
	GOTO       L__main233
	GOTO       L_main62
L__main233:
;MyProject.c,194 :: 		if(alarm_kurulum == 10)   // E�er tek seferlik alarm saati geldiyse
	MOVF       _alarm_kurulum+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main63
;MyProject.c,196 :: 		alarm_yaz();    // Daha �nce haz�rlanm�� olan alarm yazd�rma fonksiyonu �a��r�l�yor
	CALL       _alarm_yaz+0
;MyProject.c,197 :: 		if(PORTC.RC3 == 1)  // E�er "�PTAL" tu�una bas�l�rsa a�a��daki kodlar icra edilir
	BTFSS      PORTC+0, 3
	GOTO       L_main64
;MyProject.c,199 :: 		alarm_kurulum = 0; // Alarm� siler
	CLRF       _alarm_kurulum+0
;MyProject.c,200 :: 		delay_ms(200);    // kasti olarak gecikme
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_main65:
	DECFSZ     R13+0, 1
	GOTO       L_main65
	DECFSZ     R12+0, 1
	GOTO       L_main65
	DECFSZ     R11+0, 1
	GOTO       L_main65
	NOP
;MyProject.c,201 :: 		PORTB = 0;         // B portunun t�m ��k��lar�n� s�f�rlar
	CLRF       PORTB+0
;MyProject.c,202 :: 		while(PORTC.RC3);
L_main66:
	BTFSS      PORTC+0, 3
	GOTO       L_main67
	GOTO       L_main66
L_main67:
;MyProject.c,203 :: 		}
L_main64:
;MyProject.c,204 :: 		}
L_main63:
;MyProject.c,205 :: 		if(alarm_kurulum == 11)  // E�er periyodik alarm �al�yorsa
	MOVF       _alarm_kurulum+0, 0
	XORLW      11
	BTFSS      STATUS+0, 2
	GOTO       L_main68
;MyProject.c,207 :: 		alarm_yaz();        // Ekrana alarm ifadesi yazd�r�l�r
	CALL       _alarm_yaz+0
;MyProject.c,208 :: 		if(PORTC.RC3 == 1)
	BTFSS      PORTC+0, 3
	GOTO       L_main69
;MyProject.c,210 :: 		yardimci = 24/tekrar;  // Bir sonraki ila� saatini hesaplamak i�in
	MOVF       _tekrar+0, 0
	MOVWF      R4+0
	MOVLW      24
	MOVWF      R0+0
	CALL       _Div_8X8_U+0
	MOVF       R0+0, 0
	MOVWF      _yardimci+0
	CLRF       _yardimci+1
;MyProject.c,211 :: 		yardimci = alarm_saat + yardimci; // gerekli i�lemler yap�l�r
	MOVF       _yardimci+0, 0
	ADDWF      _alarm_saat+0, 0
	MOVWF      R0+0
	MOVLW      0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _yardimci+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _yardimci+0
	MOVF       R0+1, 0
	MOVWF      _yardimci+1
;MyProject.c,212 :: 		alarm_saat = yardimci%24;       // Bu i�lemler sonucunda
	MOVLW      24
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _alarm_saat+0
;MyProject.c,213 :: 		alarm_kurulum = 2;     // Yeni alarm saati, bir sonraki ila� saati olur
	MOVLW      2
	MOVWF      _alarm_kurulum+0
;MyProject.c,214 :: 		delay_ms(200);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_main70:
	DECFSZ     R13+0, 1
	GOTO       L_main70
	DECFSZ     R12+0, 1
	GOTO       L_main70
	DECFSZ     R11+0, 1
	GOTO       L_main70
	NOP
;MyProject.c,215 :: 		PORTB = 0;
	CLRF       PORTB+0
;MyProject.c,216 :: 		while(PORTC.RC3);
L_main71:
	BTFSS      PORTC+0, 3
	GOTO       L_main72
	GOTO       L_main71
L_main72:
;MyProject.c,217 :: 		}
L_main69:
;MyProject.c,218 :: 		}
L_main68:
;MyProject.c,219 :: 		}
	GOTO       L_main73
L_main62:
;MyProject.c,222 :: 		ByteToStrWithZeros(saat,txt);  // Say�sal bir ifade olan saat ifadesini karakter haline getirir ve her bir basama��, txt isimli karakter dizisinin bir eleman� olarak atar. txt dizisi 3 elemanl�d�r. E�er d�n��t�r�len say� 3 basamaktan k���kse, ba��na s�f�r koyar. �rne�in saat = 5 ise bu durumda txt dizisi = "005" olur
	MOVF       _saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,223 :: 		Lcd_Out(1,1,"SAAT :");      // 1. sat�r 1. s�tune "SAAT :" metnini yazar.
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr2_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject.c,224 :: 		Lcd_Chr(1,8,txt[1]); // txt dizisinin ikinci eleman� yani saatin onlar basama�� ekrana yazd�r�l�r
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,225 :: 		Lcd_Chr(1,9,txt[2]); // txt dizisinin ���nc� eleman� yani saatin birler basama�� ekrana yazd�r�l�r
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,226 :: 		Lcd_Chr(1,10,':'); // Ekranda belirtilen konuma ':' karakterini yazar
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      10
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,227 :: 		ByteToStrWithZeros(dakika,txt);
	MOVF       _dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,228 :: 		Lcd_Chr(1,11,txt[1]);
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      11
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,229 :: 		Lcd_Chr(1,12,txt[2]);
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      12
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,230 :: 		Lcd_Chr(1,13,':');
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      13
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,231 :: 		ByteToStrWithZeros(saniye,txt);
	MOVF       _saniye+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,232 :: 		Lcd_Chr(1,14,txt[1]);
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      14
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,233 :: 		Lcd_Chr(1,15,txt[2]);
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      15
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,234 :: 		if((alarm_kurulum == 2)||(alarm_kurulum == 3)) // E�er sstemde kurulmu� bir alarm var ise
	MOVF       _alarm_kurulum+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L__main232
	MOVF       _alarm_kurulum+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L__main232
	GOTO       L_main76
L__main232:
;MyProject.c,236 :: 		Lcd_Out(2,1,"ALARM :"); // 2. sat�r 1. s�tundna ba�layarak "ALARM" yazar
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr3_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject.c,237 :: 		ByteToStrWithZeros(alarm_saat,txt); // Buradaki fonksiyonlar ile, sistemde
	MOVF       _alarm_saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,238 :: 		Lcd_Chr(2,9,txt[1]);                // Bir alarm var ise
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,239 :: 		Lcd_Chr(2,10,txt[2]);                // Ana ekranda, saatin alt�nda
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      10
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,240 :: 		Lcd_Chr(2,11,':');                  // Alarm ifadesinin yazmas� sa�lan�r
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      11
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,241 :: 		ByteToStrWithZeros(alarm_dakika,txt);
	MOVF       _alarm_dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,242 :: 		Lcd_Chr(2,12,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      12
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,243 :: 		Lcd_Chr(2,13,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      13
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,244 :: 		}
L_main76:
;MyProject.c,245 :: 		if(yaz == 1)  // yaz de�eri 1 ise, yani 1 saniye ge�tiyse
	MOVF       _yaz+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main77
;MyProject.c,247 :: 		Lcd_Cmd(_LCD_CLEAR);// LCD'yi temizle
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,248 :: 		yaz = 0;   // yaz de�erini s�f�rla
	CLRF       _yaz+0
;MyProject.c,249 :: 		}
L_main77:
;MyProject.c,250 :: 		if(PORTC.RC3 == 1) // E�er "�IK/�PTAL/S�L "  tu�una bas�ld�ysa
	BTFSS      PORTC+0, 3
	GOTO       L_main78
;MyProject.c,252 :: 		alarm_dakika = 0; // T�m alarm verilerini
	CLRF       _alarm_dakika+0
;MyProject.c,253 :: 		alarm_saat = 0;   // Siler
	CLRF       _alarm_saat+0
;MyProject.c,254 :: 		alarm_kurulum = 0;
	CLRF       _alarm_kurulum+0
;MyProject.c,255 :: 		}
L_main78:
;MyProject.c,256 :: 		}
L_main73:
;MyProject.c,257 :: 		}
	GOTO       L_main58
L_main59:
;MyProject.c,258 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,259 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,260 :: 		while(mod == 1)  // mod de�i�keninin de�eri 1 olduk�a a�a��daki kodlar icra edilir.
L_main79:
	MOVF       _mod+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main80
;MyProject.c,262 :: 		Lcd_Out(1,1,"PERIYODIK ALARM");   // 1. sat�r ve 1. s�tundan ba�layarak ekrana ilgili metin ifadesini yazd�r�.
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr4_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject.c,263 :: 		if(PORTC.RC2 == 1)  // E�er "SE�" tu�una bas�ld�ysa a�a��daki kodlar icra edilir
	BTFSS      PORTC+0, 2
	GOTO       L_main81
;MyProject.c,265 :: 		mod = 2;     // mod de�i�keninin de�eri 2 yap�l�r. B�ylece, periyodik alarm�n ba�lang�� saatinin ayarland��� alt men�ye girilir.
	MOVLW      2
	MOVWF      _mod+0
;MyProject.c,266 :: 		delay_ms(200);  // sistemi kasti olarak yava�latmak i�in 200 ms'lik gecikme fonksiyonu kullan�l�r
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_main82:
	DECFSZ     R13+0, 1
	GOTO       L_main82
	DECFSZ     R12+0, 1
	GOTO       L_main82
	DECFSZ     R11+0, 1
	GOTO       L_main82
	NOP
;MyProject.c,267 :: 		}
L_main81:
;MyProject.c,268 :: 		if(PORTC.RC3 == 1)   // E�er "�PTAL/�IK/S�L" tu�una bas�ld�ysa a�a��daki kodlar icra edilir
	BTFSS      PORTC+0, 3
	GOTO       L_main83
;MyProject.c,270 :: 		mod = 0;  // mod de�i�keninin de�eri 0 yap�l�r. B�ylece, ana ekrana geri d�n�l�r
	CLRF       _mod+0
;MyProject.c,271 :: 		delay_ms(200);// sistemi kasti olarak yava�latmak i�in 200 ms'lik gecikme fonksiyonu kullan�l�r
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_main84:
	DECFSZ     R13+0, 1
	GOTO       L_main84
	DECFSZ     R12+0, 1
	GOTO       L_main84
	DECFSZ     R11+0, 1
	GOTO       L_main84
	NOP
;MyProject.c,272 :: 		}
L_main83:
;MyProject.c,273 :: 		}
	GOTO       L_main79
L_main80:
;MyProject.c,274 :: 		Lcd_Cmd(_LCD_CLEAR); // ekran� temizler
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,276 :: 		if(mod == 2)  // E�er mod de�i�keninin de�eri 2 ise, bu kod blo�u yaln�zca bir kez �al���r. Bunun sebebi, LCD'ye sonsuz d�ng� i�erisinde gecikme fonksiyonlar� kullanmadan
	MOVF       _mod+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_main85
;MyProject.c,278 :: 		Lcd_Out(1,2,"ILK ALARM");  // "ILK ALARM" ifadesi ekrana yazd�r�l�r ve bir sonraki ekran temizleme komuduna kadar ekranda kal�r
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr5_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject.c,279 :: 		alarm_kurulum_yaz();  // daha �nce tan�mlanm�� olan fonksiyon �a��r�l�yor
	CALL       _alarm_kurulum_yaz+0
;MyProject.c,280 :: 		}
L_main85:
;MyProject.c,281 :: 		while(mod == 2)// Bu kod blo�u, mod de�i�keninin de�eri 2 oldu�u s�rece �al���r
L_main86:
	MOVF       _mod+0, 0
	XORLW      2
	BTFSS      STATUS+0, 2
	GOTO       L_main87
;MyProject.c,283 :: 		Lcd_Cmd(_LCD_BLINK_CURSOR_ON);
	MOVLW      15
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,284 :: 		if(PORTC.RC2 == 1) // e�er "SE�" tu�una bas�ld�ysa a�a��daki kodlar icra edilir. Burada se� tu�u, basamaklar aras�nda de�i�imi sa�lamaktad�r.
	BTFSS      PORTC+0, 2
	GOTO       L_main88
;MyProject.c,286 :: 		if(pos == 7) // e�er imle� pozisyonu i�in tan�mlanan de�i�kenin de�eri 7 ise a�a��daki kodlar icra edilir. BU k�s�m ve alttaki k�s�m tamamen, kullan�c�ya hangi basamakta bulundu�unu belirten imlecin konumu ve g�sterimi ile ilgilidir
	MOVF       _pos+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_main89
;MyProject.c,288 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT); // LCD ekran �zerindeki imle� bir birim sa�a kayd�r�l�r
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,289 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT); // LCD ekran �zerindeki imle� bir birim sa�a kayd�r�l�r
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,290 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT); // LCD ekran �zerindeki imle� bir birim sa�a kayd�r�l�r
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,291 :: 		pos = 10;      // imle� pozisyonu i�in tan�mlanan de�i�kenin de�eri 10 olarak atan�r
	MOVLW      10
	MOVWF      _pos+0
;MyProject.c,292 :: 		Delay_ms(250); // sistemi yava�latmak ad�na 250 ms'lik kasti gecikme eklenir
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main90:
	DECFSZ     R13+0, 1
	GOTO       L_main90
	DECFSZ     R12+0, 1
	GOTO       L_main90
	DECFSZ     R11+0, 1
	GOTO       L_main90
	NOP
	NOP
;MyProject.c,293 :: 		while(PORTC.RC2);
L_main91:
	BTFSS      PORTC+0, 2
	GOTO       L_main92
	GOTO       L_main91
L_main92:
;MyProject.c,294 :: 		}
L_main89:
;MyProject.c,295 :: 		if((pos > 7)&&(PORTC.RC2 == 1)) // E�er pozisyon de�i�keninin de�eri 7'den b�y�kse ve "SE�" tu�una bas�l�yorsa (&&(PORTC.RC2 == 1) k�sm� olmasayd�, bir �nceki ko�ul ifadesinde pos = 10 olarak atand��� i�in, program otomatik olarak bu ko�ulun da i�erisine girecekti)
	MOVF       _pos+0, 0
	SUBLW      7
	BTFSC      STATUS+0, 0
	GOTO       L_main95
	BTFSS      PORTC+0, 2
	GOTO       L_main95
L__main231:
;MyProject.c,297 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);   // LCD ekran �zerindeki imle� bir birim sola kayd�r�l�r
	MOVLW      16
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,298 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);   // LCD ekran �zerindeki imle� bir birim sola kayd�r�l�r
	MOVLW      16
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,299 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);   // LCD ekran �zerindeki imle� bir birim sola kayd�r�l�r
	MOVLW      16
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,300 :: 		pos = pos-3;      // imle� pozisyonu i�in tan�mlanan de�i�kenin de�eri 3 azalt�l�r
	MOVLW      3
	SUBWF      _pos+0, 1
;MyProject.c,301 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main96:
	DECFSZ     R13+0, 1
	GOTO       L_main96
	DECFSZ     R12+0, 1
	GOTO       L_main96
	DECFSZ     R11+0, 1
	GOTO       L_main96
	NOP
	NOP
;MyProject.c,302 :: 		while(PORTC.RC2);
L_main97:
	BTFSS      PORTC+0, 2
	GOTO       L_main98
	GOTO       L_main97
L_main98:
;MyProject.c,303 :: 		}
L_main95:
;MyProject.c,304 :: 		}
L_main88:
;MyProject.c,305 :: 		if(PORTC.RC3 == 1)  // E�er alarm kurulum alt men�s�nde "�PTAL/�IK/S�L" tu�una bas�ld�ysa a�a��daki kodlar icra edilir.
	BTFSS      PORTC+0, 3
	GOTO       L_main99
;MyProject.c,307 :: 		alarm_kurulum = 0;  // Alarmlar ile ilgili olan
	CLRF       _alarm_kurulum+0
;MyProject.c,308 :: 		alarm_saat = 0;     // T�m sistem parametreleri
	CLRF       _alarm_saat+0
;MyProject.c,309 :: 		alarm_dakika = 0;   // S�f�rlan�r
	CLRF       _alarm_dakika+0
;MyProject.c,310 :: 		mod = 0;            // Mode de�eri s�f�rlanarak ana ekrana d�n�� sa�lan�r
	CLRF       _mod+0
;MyProject.c,311 :: 		}
L_main99:
;MyProject.c,312 :: 		if(PORTD.RD0 == 1) // E�er ARTTIR tu�una bas�ld�ysa
	BTFSS      PORTD+0, 0
	GOTO       L_main100
;MyProject.c,314 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);  // LCD'de g�r�len imleci kapat�r. Bunun sebebi, a�a��da bulunan LCD_chr fonksiyonundan �nce imle� kapat�lmazsa, her karakteri ekrana yazarken imlecin de metin boyunca hareket edi�inin g�r�n�r olmas�d�r.
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,315 :: 		if(pos == 10) // e�er imle� pozisyon de�eri 10 ise yani kullan�c� dakika basama��ndaysa
	MOVF       _pos+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main101
;MyProject.c,317 :: 		if(alarm_dakika == 59) //e�er alarm_dakika de�i�keninin de�eri 59 ise
	MOVF       _alarm_dakika+0, 0
	XORLW      59
	BTFSS      STATUS+0, 2
	GOTO       L_main102
;MyProject.c,318 :: 		alarm_dakika = 0;    // de�eri s�f�rlar (ba�a d�nd�r�r)
	CLRF       _alarm_dakika+0
	GOTO       L_main103
L_main102:
;MyProject.c,320 :: 		alarm_dakika = alarm_dakika+1;  // alarm_dakika de�i�keninin de�erini 1 artt�r�r
	INCF       _alarm_dakika+0, 1
L_main103:
;MyProject.c,321 :: 		ByteToStrWithZeros(alarm_dakika,txt);
	MOVF       _alarm_dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,322 :: 		Lcd_Chr(2,9,txt[2]); // Ekrana yeni alarm_dakika de�eri yazd�r�l�r. �NCE B�RLER BASAMA�ININ, ARDINDAN ONLAR BASAMA�ININ YAZDIRILMA SEBEB� �UDUR;
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,323 :: 		Lcd_Chr(2,8,txt[1]);  // �MLE� A�ILDI�I ZAMAN, EN SON ��LEM YAPILAN S�TUNUN B�R SA�INDA ORTAYA �IKAR. �MLEC�N 9. S�TUNDA YAN� DAK�KA �FADES�N�N
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,325 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main104:
	DECFSZ     R13+0, 1
	GOTO       L_main104
	DECFSZ     R12+0, 1
	GOTO       L_main104
	DECFSZ     R11+0, 1
	GOTO       L_main104
	NOP
	NOP
;MyProject.c,327 :: 		}
L_main101:
;MyProject.c,328 :: 		if(pos == 7)  // e�er imle� pozisyon de�eri 7 ise yani kullan�c� SAAT basama��ndaysa
	MOVF       _pos+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_main105
;MyProject.c,330 :: 		if(alarm_saat == 24)        // Bu kez, yukar�da dakika mertebesi i�in yap�lan i�lemlerin ayn�s�, saat mertebesi i�in yap�l�r
	MOVF       _alarm_saat+0, 0
	XORLW      24
	BTFSS      STATUS+0, 2
	GOTO       L_main106
;MyProject.c,331 :: 		alarm_saat = 0;
	CLRF       _alarm_saat+0
	GOTO       L_main107
L_main106:
;MyProject.c,333 :: 		alarm_saat = alarm_saat+1;
	INCF       _alarm_saat+0, 1
L_main107:
;MyProject.c,334 :: 		ByteToStrWithZeros(alarm_saat,txt);
	MOVF       _alarm_saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,335 :: 		Lcd_Chr(2,6,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,336 :: 		Lcd_Chr(2,5,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,337 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main108:
	DECFSZ     R13+0, 1
	GOTO       L_main108
	DECFSZ     R12+0, 1
	GOTO       L_main108
	DECFSZ     R11+0, 1
	GOTO       L_main108
	NOP
	NOP
;MyProject.c,338 :: 		}
L_main105:
;MyProject.c,339 :: 		}
L_main100:
;MyProject.c,340 :: 		if(PORTD.RD1 == 1)// E�er AZALT tu�una bas�ld�ysa
	BTFSS      PORTD+0, 1
	GOTO       L_main109
;MyProject.c,342 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);// LCD �zerindeki imle� kapat�l�r
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,343 :: 		if(pos == 10)            // Bu a�amada
	MOVF       _pos+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main110
;MyProject.c,345 :: 		if(alarm_dakika == 0)  // ger�ekle�en i�lelerin ayn�lar�
	MOVF       _alarm_dakika+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main111
;MyProject.c,346 :: 		alarm_dakika = 0;   // bu kez alarm_saat ve alarm_dakika de�i�kenleerinin de�erleri a
	CLRF       _alarm_dakika+0
	GOTO       L_main112
L_main111:
;MyProject.c,348 :: 		alarm_dakika = alarm_dakika-1;
	DECF       _alarm_dakika+0, 1
L_main112:
;MyProject.c,349 :: 		ByteToStrWithZeros(alarm_dakika,txt);
	MOVF       _alarm_dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,350 :: 		Lcd_Chr(2,9,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,351 :: 		Lcd_Chr(2,8,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,352 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main113:
	DECFSZ     R13+0, 1
	GOTO       L_main113
	DECFSZ     R12+0, 1
	GOTO       L_main113
	DECFSZ     R11+0, 1
	GOTO       L_main113
	NOP
	NOP
;MyProject.c,353 :: 		}
L_main110:
;MyProject.c,354 :: 		if(pos == 7)
	MOVF       _pos+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_main114
;MyProject.c,356 :: 		if(alarm_saat == 0)
	MOVF       _alarm_saat+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main115
;MyProject.c,357 :: 		alarm_saat = 0;
	CLRF       _alarm_saat+0
	GOTO       L_main116
L_main115:
;MyProject.c,359 :: 		alarm_saat = alarm_saat-1;
	DECF       _alarm_saat+0, 1
L_main116:
;MyProject.c,360 :: 		ByteToStrWithZeros(alarm_saat,txt);
	MOVF       _alarm_saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,361 :: 		Lcd_Chr(2,6,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,362 :: 		Lcd_Chr(2,5,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,363 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main117:
	DECFSZ     R13+0, 1
	GOTO       L_main117
	DECFSZ     R12+0, 1
	GOTO       L_main117
	DECFSZ     R11+0, 1
	GOTO       L_main117
	NOP
	NOP
;MyProject.c,364 :: 		}
L_main114:
;MyProject.c,365 :: 		}
L_main109:
;MyProject.c,366 :: 		}
	GOTO       L_main86
L_main87:
;MyProject.c,367 :: 		Lcd_Cmd(_LCD_CURSOR_OFF); // modlar aras� ge�i�lerde g�venlik amac�yla imle� kapat�l�r
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,368 :: 		Lcd_Cmd(_LCD_CLEAR);      // ve ekran temizlenir
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,370 :: 		if(mod == 3)
	MOVF       _mod+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_main118
;MyProject.c,371 :: 		Lcd_Out(1,1,"GUNDE KAC KEZ?");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr6_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
L_main118:
;MyProject.c,372 :: 		while(mod == 3)   // mod de�eri �� ise ;yani periyodik alarm�n g�nde ka� tekrar yapaca�� se�iliyorsa bu d�ng� �al���r
L_main119:
	MOVF       _mod+0, 0
	XORLW      3
	BTFSS      STATUS+0, 2
	GOTO       L_main120
;MyProject.c,374 :: 		if(PORTD.RD0 == 1)  // E�er artt�r tu�un bas�l�yorsa   a�a��daki kodlar icra edilir
	BTFSS      PORTD+0, 0
	GOTO       L_main121
;MyProject.c,376 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,377 :: 		if(tekrar == 4) // E�er g�nl�k kullan�m say�s� 4'e
	MOVF       _tekrar+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_main122
;MyProject.c,378 :: 		tekrar = 4;  // Ula�t�ysa daha fazla artmas� engellenir
	MOVLW      4
	MOVWF      _tekrar+0
	GOTO       L_main123
L_main122:
;MyProject.c,380 :: 		tekrar = tekrar+1;  // Aksi takdirde bir artt�r�l�r
	INCF       _tekrar+0, 1
L_main123:
;MyProject.c,381 :: 		ByteToStrWithZeros(tekrar,txt);
	MOVF       _tekrar+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,382 :: 		Lcd_Chr(2,9,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,383 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main124:
	DECFSZ     R13+0, 1
	GOTO       L_main124
	DECFSZ     R12+0, 1
	GOTO       L_main124
	DECFSZ     R11+0, 1
	GOTO       L_main124
	NOP
	NOP
;MyProject.c,384 :: 		}
L_main121:
;MyProject.c,385 :: 		if(PORTD.RD1 == 1) // E�er azalt tu�una bas�ld�ysa a�a��daki kodlar icra edilir
	BTFSS      PORTD+0, 1
	GOTO       L_main125
;MyProject.c,387 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,388 :: 		if(tekrar == 1)
	MOVF       _tekrar+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main126
;MyProject.c,389 :: 		tekrar = 1;
	MOVLW      1
	MOVWF      _tekrar+0
	GOTO       L_main127
L_main126:
;MyProject.c,391 :: 		tekrar = tekrar-1;
	DECF       _tekrar+0, 1
L_main127:
;MyProject.c,392 :: 		ByteToStrWithZeros(tekrar,txt);
	MOVF       _tekrar+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,393 :: 		Lcd_Chr(2,9,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,394 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main128:
	DECFSZ     R13+0, 1
	GOTO       L_main128
	DECFSZ     R12+0, 1
	GOTO       L_main128
	DECFSZ     R11+0, 1
	GOTO       L_main128
	NOP
	NOP
;MyProject.c,395 :: 		}
L_main125:
;MyProject.c,396 :: 		if(PORTC.RC3 == 1)     // E�er "�PTAL" TU�UN BASILDIYSA A�A�IDAK� KODLAR ��CRA ED�L�R
	BTFSS      PORTC+0, 3
	GOTO       L_main129
;MyProject.c,398 :: 		alarm_kurulum = 0;
	CLRF       _alarm_kurulum+0
;MyProject.c,399 :: 		alarm_saat = 0;
	CLRF       _alarm_saat+0
;MyProject.c,400 :: 		alarm_dakika = 0;
	CLRF       _alarm_dakika+0
;MyProject.c,401 :: 		mod = 0;
	CLRF       _mod+0
;MyProject.c,402 :: 		}
L_main129:
;MyProject.c,403 :: 		}
	GOTO       L_main119
L_main120:
;MyProject.c,404 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,405 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,406 :: 		while(mod == 4)
L_main130:
	MOVF       _mod+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_main131
;MyProject.c,408 :: 		Lcd_Out(1,1,"TEK SEFERLIK");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr7_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject.c,409 :: 		Lcd_Out(2,1,"ALARM");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr8_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject.c,410 :: 		if(PORTC.RC2 == 1)
	BTFSS      PORTC+0, 2
	GOTO       L_main132
;MyProject.c,412 :: 		alarm_kurulum = 1;
	MOVLW      1
	MOVWF      _alarm_kurulum+0
;MyProject.c,413 :: 		mod = 5;
	MOVLW      5
	MOVWF      _mod+0
;MyProject.c,414 :: 		delay_ms(50);
	MOVLW      65
	MOVWF      R12+0
	MOVLW      238
	MOVWF      R13+0
L_main133:
	DECFSZ     R13+0, 1
	GOTO       L_main133
	DECFSZ     R12+0, 1
	GOTO       L_main133
	NOP
;MyProject.c,415 :: 		while(PORTC.RC2);
L_main134:
	BTFSS      PORTC+0, 2
	GOTO       L_main135
	GOTO       L_main134
L_main135:
;MyProject.c,416 :: 		}
L_main132:
;MyProject.c,417 :: 		if(PORTC.RC3 == 1)
	BTFSS      PORTC+0, 3
	GOTO       L_main136
;MyProject.c,419 :: 		mod = 0;
	CLRF       _mod+0
;MyProject.c,420 :: 		alarm_kurulum = 0;
	CLRF       _alarm_kurulum+0
;MyProject.c,421 :: 		delay_ms(50);
	MOVLW      65
	MOVWF      R12+0
	MOVLW      238
	MOVWF      R13+0
L_main137:
	DECFSZ     R13+0, 1
	GOTO       L_main137
	DECFSZ     R12+0, 1
	GOTO       L_main137
	NOP
;MyProject.c,422 :: 		while(PORTC.RC2);
L_main138:
	BTFSS      PORTC+0, 2
	GOTO       L_main139
	GOTO       L_main138
L_main139:
;MyProject.c,423 :: 		}
L_main136:
;MyProject.c,424 :: 		}
	GOTO       L_main130
L_main131:
;MyProject.c,425 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,426 :: 		if((mod == 5)&&(alarm_kurulum == 1))
	MOVF       _mod+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L_main142
	MOVF       _alarm_kurulum+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main142
L__main230:
;MyProject.c,428 :: 		Lcd_Out(1,2,"ALARM SAATI");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr9_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject.c,429 :: 		alarm_kurulum_yaz();
	CALL       _alarm_kurulum_yaz+0
;MyProject.c,430 :: 		}
L_main142:
;MyProject.c,431 :: 		while((mod == 5)&&(alarm_kurulum == 1))
L_main143:
	MOVF       _mod+0, 0
	XORLW      5
	BTFSS      STATUS+0, 2
	GOTO       L_main144
	MOVF       _alarm_kurulum+0, 0
	XORLW      1
	BTFSS      STATUS+0, 2
	GOTO       L_main144
L__main229:
;MyProject.c,433 :: 		Lcd_Cmd(_LCD_BLINK_CURSOR_ON);
	MOVLW      15
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,434 :: 		if(PORTC.RC2 == 1)
	BTFSS      PORTC+0, 2
	GOTO       L_main147
;MyProject.c,436 :: 		if(pos == 7)
	MOVF       _pos+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_main148
;MyProject.c,438 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,439 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,440 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,441 :: 		pos = 10;
	MOVLW      10
	MOVWF      _pos+0
;MyProject.c,442 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main149:
	DECFSZ     R13+0, 1
	GOTO       L_main149
	DECFSZ     R12+0, 1
	GOTO       L_main149
	DECFSZ     R11+0, 1
	GOTO       L_main149
	NOP
	NOP
;MyProject.c,443 :: 		while(PORTC.RC2);
L_main150:
	BTFSS      PORTC+0, 2
	GOTO       L_main151
	GOTO       L_main150
L_main151:
;MyProject.c,444 :: 		}
L_main148:
;MyProject.c,445 :: 		if((pos > 7)&&(PORTC.RC2 == 1))
	MOVF       _pos+0, 0
	SUBLW      7
	BTFSC      STATUS+0, 0
	GOTO       L_main154
	BTFSS      PORTC+0, 2
	GOTO       L_main154
L__main228:
;MyProject.c,447 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
	MOVLW      16
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,448 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
	MOVLW      16
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,449 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
	MOVLW      16
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,450 :: 		pos = pos-3;
	MOVLW      3
	SUBWF      _pos+0, 1
;MyProject.c,451 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main155:
	DECFSZ     R13+0, 1
	GOTO       L_main155
	DECFSZ     R12+0, 1
	GOTO       L_main155
	DECFSZ     R11+0, 1
	GOTO       L_main155
	NOP
	NOP
;MyProject.c,452 :: 		while(PORTC.RC2);
L_main156:
	BTFSS      PORTC+0, 2
	GOTO       L_main157
	GOTO       L_main156
L_main157:
;MyProject.c,453 :: 		}
L_main154:
;MyProject.c,454 :: 		}
L_main147:
;MyProject.c,455 :: 		if(PORTC.RC3 == 1)
	BTFSS      PORTC+0, 3
	GOTO       L_main158
;MyProject.c,457 :: 		alarm_kurulum = 0;
	CLRF       _alarm_kurulum+0
;MyProject.c,458 :: 		alarm_saat = 0;
	CLRF       _alarm_saat+0
;MyProject.c,459 :: 		alarm_dakika = 0;
	CLRF       _alarm_dakika+0
;MyProject.c,460 :: 		mod = 0;
	CLRF       _mod+0
;MyProject.c,461 :: 		}
L_main158:
;MyProject.c,462 :: 		if(PORTD.RD0 == 1)
	BTFSS      PORTD+0, 0
	GOTO       L_main159
;MyProject.c,464 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,465 :: 		if(pos == 10)
	MOVF       _pos+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main160
;MyProject.c,467 :: 		if(alarm_dakika == 59)
	MOVF       _alarm_dakika+0, 0
	XORLW      59
	BTFSS      STATUS+0, 2
	GOTO       L_main161
;MyProject.c,468 :: 		alarm_dakika = 0;
	CLRF       _alarm_dakika+0
	GOTO       L_main162
L_main161:
;MyProject.c,470 :: 		alarm_dakika = alarm_dakika+1;
	INCF       _alarm_dakika+0, 1
L_main162:
;MyProject.c,471 :: 		ByteToStrWithZeros(alarm_dakika,txt);
	MOVF       _alarm_dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,472 :: 		Lcd_Chr(2,9,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,473 :: 		Lcd_Chr(2,8,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,474 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main163:
	DECFSZ     R13+0, 1
	GOTO       L_main163
	DECFSZ     R12+0, 1
	GOTO       L_main163
	DECFSZ     R11+0, 1
	GOTO       L_main163
	NOP
	NOP
;MyProject.c,476 :: 		}
L_main160:
;MyProject.c,477 :: 		if(pos == 7)
	MOVF       _pos+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_main164
;MyProject.c,479 :: 		if(alarm_saat == 24)
	MOVF       _alarm_saat+0, 0
	XORLW      24
	BTFSS      STATUS+0, 2
	GOTO       L_main165
;MyProject.c,480 :: 		alarm_saat = 0;
	CLRF       _alarm_saat+0
	GOTO       L_main166
L_main165:
;MyProject.c,482 :: 		alarm_saat = alarm_saat+1;
	INCF       _alarm_saat+0, 1
L_main166:
;MyProject.c,483 :: 		ByteToStrWithZeros(alarm_saat,txt);
	MOVF       _alarm_saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,484 :: 		Lcd_Chr(2,6,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,485 :: 		Lcd_Chr(2,5,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,486 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main167:
	DECFSZ     R13+0, 1
	GOTO       L_main167
	DECFSZ     R12+0, 1
	GOTO       L_main167
	DECFSZ     R11+0, 1
	GOTO       L_main167
	NOP
	NOP
;MyProject.c,487 :: 		}
L_main164:
;MyProject.c,488 :: 		}
L_main159:
;MyProject.c,489 :: 		if(PORTD.RD1 == 1)
	BTFSS      PORTD+0, 1
	GOTO       L_main168
;MyProject.c,491 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,492 :: 		if(pos == 10)
	MOVF       _pos+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main169
;MyProject.c,494 :: 		if(alarm_dakika == 0)
	MOVF       _alarm_dakika+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main170
;MyProject.c,495 :: 		alarm_dakika = 0;
	CLRF       _alarm_dakika+0
	GOTO       L_main171
L_main170:
;MyProject.c,497 :: 		alarm_dakika = alarm_dakika-1;
	DECF       _alarm_dakika+0, 1
L_main171:
;MyProject.c,498 :: 		ByteToStrWithZeros(alarm_dakika,txt);
	MOVF       _alarm_dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,499 :: 		Lcd_Chr(2,9,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,500 :: 		Lcd_Chr(2,8,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,501 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main172:
	DECFSZ     R13+0, 1
	GOTO       L_main172
	DECFSZ     R12+0, 1
	GOTO       L_main172
	DECFSZ     R11+0, 1
	GOTO       L_main172
	NOP
	NOP
;MyProject.c,502 :: 		}
L_main169:
;MyProject.c,503 :: 		if(pos == 7)
	MOVF       _pos+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_main173
;MyProject.c,505 :: 		if(alarm_saat == 0)
	MOVF       _alarm_saat+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main174
;MyProject.c,506 :: 		alarm_saat = 0;
	CLRF       _alarm_saat+0
	GOTO       L_main175
L_main174:
;MyProject.c,508 :: 		alarm_saat = alarm_saat-1;
	DECF       _alarm_saat+0, 1
L_main175:
;MyProject.c,509 :: 		ByteToStrWithZeros(alarm_saat,txt);
	MOVF       _alarm_saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,510 :: 		Lcd_Chr(2,6,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,511 :: 		Lcd_Chr(2,5,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,512 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main176:
	DECFSZ     R13+0, 1
	GOTO       L_main176
	DECFSZ     R12+0, 1
	GOTO       L_main176
	DECFSZ     R11+0, 1
	GOTO       L_main176
	NOP
	NOP
;MyProject.c,513 :: 		}
L_main173:
;MyProject.c,514 :: 		}
L_main168:
;MyProject.c,515 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,516 :: 		}
	GOTO       L_main143
L_main144:
;MyProject.c,517 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,518 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,519 :: 		if(mod == 10)
	MOVF       _mod+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main177
;MyProject.c,521 :: 		Lcd_Out(1,2,"SAAT KURULUMU");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr10_MyProject+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;MyProject.c,522 :: 		ByteToStrWithZeros(saat,txt);
	MOVF       _saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,523 :: 		Lcd_Chr(2,4,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      4
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,524 :: 		Lcd_Chr(2,5,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,525 :: 		Lcd_Chr(2,6,':');
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      6
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,526 :: 		ByteToStrWithZeros(dakika,txt);
	MOVF       _dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,527 :: 		Lcd_Chr(2,7,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,528 :: 		Lcd_Chr(2,8,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,529 :: 		Lcd_Chr(2,9,':');
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      58
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,530 :: 		ByteToStrWithZeros(saniye,txt);
	MOVF       _saniye+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,531 :: 		Lcd_Chr(2,11,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      11
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,532 :: 		Lcd_Chr(2,10,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      10
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,533 :: 		}
L_main177:
;MyProject.c,534 :: 		while(mod == 10)
L_main178:
	MOVF       _mod+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main179
;MyProject.c,536 :: 		Lcd_Cmd(_LCD_BLINK_CURSOR_ON);
	MOVLW      15
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,537 :: 		if(PORTC.RC2 == 1)
	BTFSS      PORTC+0, 2
	GOTO       L_main180
;MyProject.c,539 :: 		if(pos == 4)
	MOVF       _pos+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_main181
;MyProject.c,541 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,542 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,543 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,544 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,545 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,546 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_RIGHT);
	MOVLW      20
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,547 :: 		pos = 10;
	MOVLW      10
	MOVWF      _pos+0
;MyProject.c,548 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main182:
	DECFSZ     R13+0, 1
	GOTO       L_main182
	DECFSZ     R12+0, 1
	GOTO       L_main182
	DECFSZ     R11+0, 1
	GOTO       L_main182
	NOP
	NOP
;MyProject.c,549 :: 		while(PORTC.RC2);
L_main183:
	BTFSS      PORTC+0, 2
	GOTO       L_main184
	GOTO       L_main183
L_main184:
;MyProject.c,550 :: 		}
L_main181:
;MyProject.c,551 :: 		if((pos > 4)&&(PORTC.RC2 == 1))
	MOVF       _pos+0, 0
	SUBLW      4
	BTFSC      STATUS+0, 0
	GOTO       L_main187
	BTFSS      PORTC+0, 2
	GOTO       L_main187
L__main227:
;MyProject.c,553 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
	MOVLW      16
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,554 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
	MOVLW      16
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,555 :: 		Lcd_Cmd(_LCD_MOVE_CURSOR_LEFT);
	MOVLW      16
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,556 :: 		pos = pos-3;
	MOVLW      3
	SUBWF      _pos+0, 1
;MyProject.c,557 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main188:
	DECFSZ     R13+0, 1
	GOTO       L_main188
	DECFSZ     R12+0, 1
	GOTO       L_main188
	DECFSZ     R11+0, 1
	GOTO       L_main188
	NOP
	NOP
;MyProject.c,558 :: 		while(PORTC.RC2);
L_main189:
	BTFSS      PORTC+0, 2
	GOTO       L_main190
	GOTO       L_main189
L_main190:
;MyProject.c,559 :: 		}
L_main187:
;MyProject.c,560 :: 		}
L_main180:
;MyProject.c,561 :: 		if(PORTD.RD0 == 1)
	BTFSS      PORTD+0, 0
	GOTO       L_main191
;MyProject.c,563 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,564 :: 		if(pos == 10)
	MOVF       _pos+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main192
;MyProject.c,566 :: 		if(saniye == 59)
	MOVF       _saniye+0, 0
	XORLW      59
	BTFSS      STATUS+0, 2
	GOTO       L_main193
;MyProject.c,567 :: 		saniye = 0;
	CLRF       _saniye+0
	GOTO       L_main194
L_main193:
;MyProject.c,569 :: 		saniye = saniye +1;
	INCF       _saniye+0, 1
L_main194:
;MyProject.c,570 :: 		ByteToStrWithZeros(saniye,txt);
	MOVF       _saniye+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,571 :: 		Lcd_Chr(2,11,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      11
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,572 :: 		Lcd_Chr(2,10,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      10
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,573 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main195:
	DECFSZ     R13+0, 1
	GOTO       L_main195
	DECFSZ     R12+0, 1
	GOTO       L_main195
	DECFSZ     R11+0, 1
	GOTO       L_main195
	NOP
	NOP
;MyProject.c,575 :: 		}
L_main192:
;MyProject.c,576 :: 		if(pos == 7)
	MOVF       _pos+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_main196
;MyProject.c,578 :: 		if(dakika == 59)
	MOVF       _dakika+0, 0
	XORLW      59
	BTFSS      STATUS+0, 2
	GOTO       L_main197
;MyProject.c,579 :: 		dakika = 0;
	CLRF       _dakika+0
	GOTO       L_main198
L_main197:
;MyProject.c,581 :: 		dakika = dakika +1;
	INCF       _dakika+0, 1
L_main198:
;MyProject.c,582 :: 		ByteToStrWithZeros(dakika,txt);
	MOVF       _dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,583 :: 		Lcd_Chr(2,8,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,584 :: 		Lcd_Chr(2,7,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,585 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main199:
	DECFSZ     R13+0, 1
	GOTO       L_main199
	DECFSZ     R12+0, 1
	GOTO       L_main199
	DECFSZ     R11+0, 1
	GOTO       L_main199
	NOP
	NOP
;MyProject.c,586 :: 		}
L_main196:
;MyProject.c,587 :: 		if(pos == 4)
	MOVF       _pos+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_main200
;MyProject.c,590 :: 		if(saat == 24)
	MOVF       _saat+0, 0
	XORLW      24
	BTFSS      STATUS+0, 2
	GOTO       L_main201
;MyProject.c,591 :: 		saat = 0;
	CLRF       _saat+0
	GOTO       L_main202
L_main201:
;MyProject.c,593 :: 		saat = saat+1;
	INCF       _saat+0, 1
L_main202:
;MyProject.c,594 :: 		ByteToStrWithZeros(saat,txt);
	MOVF       _saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,595 :: 		Lcd_Chr(2,5,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,596 :: 		Lcd_Chr(2,4,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      4
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,597 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main203:
	DECFSZ     R13+0, 1
	GOTO       L_main203
	DECFSZ     R12+0, 1
	GOTO       L_main203
	DECFSZ     R11+0, 1
	GOTO       L_main203
	NOP
	NOP
;MyProject.c,598 :: 		}
L_main200:
;MyProject.c,599 :: 		}
L_main191:
;MyProject.c,600 :: 		if(PORTD.RD1 == 1)
	BTFSS      PORTD+0, 1
	GOTO       L_main204
;MyProject.c,602 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,603 :: 		if(pos == 10)
	MOVF       _pos+0, 0
	XORLW      10
	BTFSS      STATUS+0, 2
	GOTO       L_main205
;MyProject.c,605 :: 		if(saniye == 0)
	MOVF       _saniye+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main206
;MyProject.c,606 :: 		saniye = 0;
	CLRF       _saniye+0
	GOTO       L_main207
L_main206:
;MyProject.c,608 :: 		saniye = saniye-1;
	DECF       _saniye+0, 1
L_main207:
;MyProject.c,609 :: 		ByteToStrWithZeros(saniye,txt);
	MOVF       _saniye+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,610 :: 		Lcd_Chr(2,11,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      11
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,611 :: 		Lcd_Chr(2,10,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      10
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,612 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main208:
	DECFSZ     R13+0, 1
	GOTO       L_main208
	DECFSZ     R12+0, 1
	GOTO       L_main208
	DECFSZ     R11+0, 1
	GOTO       L_main208
	NOP
	NOP
;MyProject.c,614 :: 		}
L_main205:
;MyProject.c,615 :: 		if(pos == 7)
	MOVF       _pos+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L_main209
;MyProject.c,617 :: 		if(dakika == 0)
	MOVF       _dakika+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main210
;MyProject.c,618 :: 		dakika = 0;
	CLRF       _dakika+0
	GOTO       L_main211
L_main210:
;MyProject.c,620 :: 		dakika = dakika-1;
	DECF       _dakika+0, 1
L_main211:
;MyProject.c,621 :: 		ByteToStrWithZeros(dakika,txt);
	MOVF       _dakika+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,622 :: 		Lcd_Chr(2,8,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      8
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,623 :: 		Lcd_Chr(2,7,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,624 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main212:
	DECFSZ     R13+0, 1
	GOTO       L_main212
	DECFSZ     R12+0, 1
	GOTO       L_main212
	DECFSZ     R11+0, 1
	GOTO       L_main212
	NOP
	NOP
;MyProject.c,625 :: 		}
L_main209:
;MyProject.c,626 :: 		if(pos == 4)
	MOVF       _pos+0, 0
	XORLW      4
	BTFSS      STATUS+0, 2
	GOTO       L_main213
;MyProject.c,628 :: 		if(saat == 0)
	MOVF       _saat+0, 0
	XORLW      0
	BTFSS      STATUS+0, 2
	GOTO       L_main214
;MyProject.c,629 :: 		saat = 0;
	CLRF       _saat+0
	GOTO       L_main215
L_main214:
;MyProject.c,631 :: 		saat = saat-1;
	DECF       _saat+0, 1
L_main215:
;MyProject.c,632 :: 		ByteToStrWithZeros(saat,txt);
	MOVF       _saat+0, 0
	MOVWF      FARG_ByteToStrWithZeros_input+0
	MOVLW      _txt+0
	MOVWF      FARG_ByteToStrWithZeros_output+0
	CALL       _ByteToStrWithZeros+0
;MyProject.c,633 :: 		Lcd_Chr(2,5,txt[2]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+2, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,634 :: 		Lcd_Chr(2,4,txt[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      4
	MOVWF      FARG_Lcd_Chr_column+0
	MOVF       _txt+1, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;MyProject.c,635 :: 		delay_ms(250);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      69
	MOVWF      R12+0
	MOVLW      169
	MOVWF      R13+0
L_main216:
	DECFSZ     R13+0, 1
	GOTO       L_main216
	DECFSZ     R12+0, 1
	GOTO       L_main216
	DECFSZ     R11+0, 1
	GOTO       L_main216
	NOP
	NOP
;MyProject.c,636 :: 		}
L_main213:
;MyProject.c,637 :: 		}
L_main204:
;MyProject.c,638 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;MyProject.c,639 :: 		}
	GOTO       L_main178
L_main179:
;MyProject.c,640 :: 		}
	GOTO       L_main56
;MyProject.c,641 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
