#line 1 "C:/Users/TRG/Desktop/Projeler/Elektronik/PIC/Ilac_Hatirlaticisi/Program/MyProject.c"
sbit LCD_RS at RD2_bit;
sbit LCD_EN at RD3_bit;
sbit LCD_D4 at RD4_bit;
sbit LCD_D5 at RD5_bit;
sbit LCD_D6 at RD6_bit;
sbit LCD_D7 at RD7_bit;

sbit LCD_RS_Direction at TRISD2_bit;
sbit LCD_EN_Direction at TRISD3_bit;
sbit LCD_D4_Direction at TRISD4_bit;
sbit LCD_D5_Direction at TRISD5_bit;
sbit LCD_D6_Direction at TRISD6_bit;
sbit LCD_D7_Direction at TRISD7_bit;

unsigned short saniye = 0;
unsigned short dakika = 0;
unsigned short saat = 0;
unsigned short alarm_dakika = 0;
unsigned short alarm_saat = 0;
unsigned short sayac = 0;
unsigned short mod = 0;
unsigned short yaz = 0;
unsigned short pos = 10;
unsigned short alarm_kurulum = 0;
unsigned short tekrar = 0;
unsigned yardimci = 0;
char txt[3];

void interrupt()
{
 if(PIR1.TMR1IF == 1)
 {
 if(mod != 10)
 {
 sayac = sayac+1;
 if(sayac == 5)
 {
 saniye = saniye+1;
 yaz = 1;
 if(saniye == 60)
 {
 dakika = dakika+1;
 saniye = 0;
 }
 sayac = 0;
 }
 if(dakika == 60)
 {
 saat = saat+1;
 dakika = 0;
 }
 if(saat == 24)
 {
 saat = 0;
 dakika = 0;
 saniye = 0;
 }
 if((((alarm_saat == saat) && (alarm_dakika == dakika))&&(saniye == 0)) && ((alarm_kurulum == 2) || (alarm_kurulum == 3)))
 {
 if(alarm_kurulum == 3)
 alarm_kurulum = 10;
 if(alarm_kurulum == 2)
 alarm_kurulum = 11;
 }
 if((alarm_kurulum == 10)||(alarm_kurulum == 11))
 {
 if(sayac<=3)
 {
 PORTB = 254;
 }
 else
 PORTB = 0;

 }

 }

 TMR1H = 0b00111100;
 TMR1L = 0b10101111;
 PIR1.TMR1IF = 0;
 }
 if(INTCON.INTF == 1)
 {




 if(alarm_kurulum != 1)
 {
 if((mod == 0)&&(PORTB.RB0 == 1))
 {
 mod = 1;
 while(PORTB.RB0);
 }
 if((mod == 1)&&(PORTB.RB0 == 1))
 {
 mod = 4;
 while(PORTB.RB0);
 }
 if(mod == 2)
 {
 alarm_kurulum = 1;
 mod = 3;
 while(PORTB.RB0);
 }
 if((mod == 4)&&(PORTB.RB0 == 1))
 {
 mod = 10;
 while(PORTB.RB0);
 }
 if((mod == 10)&&(PORTB.RB0 == 1))
 {
 mod = 0;
 while(PORTB.RB0);
 }
 }



 if(alarm_kurulum == 1)
 {
 if(mod == 5)
 {
 alarm_kurulum = 3;
 mod = 0;
 while(PORTB.RB0);
 }
 if((mod == 3)&&(PORTB.RB0 == 1))
 {
 alarm_kurulum = 2;
 mod = 0;
 while(PORTB.RB0);
 }
 }
 INTCON.INTF = 0;
 }
}
void alarm_yaz()
{
 Lcd_Out(1,1,"ILAC SAATI");
 ByteToStrWithZeros(alarm_saat,txt);
 Lcd_Chr(2,9,txt[1]);
 Lcd_Chr(2,10,txt[2]);
 Lcd_Chr(2,11,':');
 ByteToStrWithZeros(alarm_dakika,txt);
 Lcd_Chr(2,12,txt[1]);
 Lcd_Chr(2,13,txt[2]);
}
void alarm_kurulum_yaz()
{
 ByteToStrWithZeros(alarm_saat,txt);
 Lcd_Chr(2,5,txt[1]);
 Lcd_Chr(2,6,txt[2]);
 Lcd_Chr(2,7,':');
 ByteToStrWithZeros(alarm_dakika,txt);
 Lcd_Chr(2,9,txt[2]);
 Lcd_Chr(2,8,txt[1]);
}

void main()
{
 INTCON.GIE = 1;
 INTCON.PEIE = 1;

 INTCON.INTE = 1;
 INTCON.INTF = 0;
 OPTION_REG.INTEDG = 1;

 T1CON.T1CKPS1 = 1;
 T1CON.T1CKPS0 = 0;
 T1CON.TMR1CS = 0;
 T1CON.TMR1ON = 1;
 T1CON.T1OSCEN = 0;
 TMR1H = 0b00111100;
 TMR1L = 0b10101111;
 PIR1.TMR1IF = 0;
 PIE1.TMR1IE = 1;

 TRISB = 0b00000001;
 TRISD = 0b00000011;
 TRISC = 0b00001100;
 PORTB = 0;
 PORTC = 0;
 Lcd_Init();
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
 while(1)
 {
 Lcd_Cmd(_LCD_CLEAR);
 while(mod == 0)
 {
 if((alarm_kurulum == 10)||(alarm_kurulum == 11))
 {
 if(alarm_kurulum == 10)
 {
 alarm_yaz();
 if(PORTC.RC3 == 1)
 {
 alarm_kurulum = 0;
 delay_ms(200);
 PORTB = 0;
 while(PORTC.RC3);
 }
 }
 if(alarm_kurulum == 11)
 {
 alarm_yaz();
 if(PORTC.RC3 == 1)
 {
 yardimci = 24/tekrar;
 yardimci = alarm_saat + yardimci;
 alarm_saat = yardimci%24;
 alarm_kurulum = 2;
 delay_ms(200);
 PORTB = 0;
 while(PORTC.RC3);
 }
 }
 }
 else
 {
 ByteToStrWithZeros(saat,txt);
 Lcd_Out(1,1,"SAAT :");
 Lcd_Chr(1,8,txt[1]);
 Lcd_Chr(1,9,txt[2]);
 Lcd_Chr(1,10,':');
 ByteToStrWithZeros(dakika,txt);
 Lcd_Chr(1,11,txt[1]);
 Lcd_Chr(1,12,txt[2]);
 Lcd_Chr(1,13,':');
 ByteToStrWithZeros(saniye,txt);
 Lcd_Chr(1,14,txt[1]);
 Lcd_Chr(1,15,txt[2]);
 if((alarm_kurulum == 2)||(alarm_kurulum == 3))
 {
 Lcd_Out(2,1,"ALARM :");
 ByteToStrWithZeros(alarm_saat,txt);
 Lcd_Chr(2,9,txt[1]);
 Lcd_Chr(2,10,txt[2]);
 Lcd_Chr(2,11,':');
 ByteToStrWithZeros(alarm_dakika,txt);
 Lcd_Chr(2,12,txt[1]);
 Lcd_Chr(2,13,txt[2]);
 }
 if(yaz == 1)
 {
 Lcd_Cmd(_LCD_CLEAR);
 yaz = 0;
 }
 if(PORTC.RC3 == 1)
 {
 alarm_dakika = 0;
 alarm_saat = 0;
 alarm_kurulum = 0;
 }
 }
 }
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
 while(mod == 1)
 {
 Lcd_Out(1,1,"PERIYODIK ALARM");
 if(PORTC.RC2 == 1)
 {
 mod = 2;
 delay_ms(200);
 }
 if(PORTC.RC3 == 1)
 {
 mod = 0;
 delay_ms(200);
 }
 }
 Lcd_Cmd(_LCD_CLEAR);

 if(mod == 2)
 {
 Lcd_Out(1,2,"ILK ALARM");
 alarm_kurulum_yaz();
 }
 while(mod == 2)
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
 Delay_ms(250);
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
 }
 Lcd_Cmd(_LCD_CURSOR_OFF);
 Lcd_Cmd(_LCD_CLEAR);

 if(mod == 3)
 Lcd_Out(1,1,"GUNDE KAC KEZ?");
 while(mod == 3)
 {
 if(PORTD.RD0 == 1)
 {
 Lcd_Cmd(_LCD_CURSOR_OFF);
 if(tekrar == 4)
 tekrar = 4;
 else
 tekrar = tekrar+1;
 ByteToStrWithZeros(tekrar,txt);
 Lcd_Chr(2,9,txt[2]);
 delay_ms(250);
 }
 if(PORTD.RD1 == 1)
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
 if(PORTC.RC3 == 1)
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
