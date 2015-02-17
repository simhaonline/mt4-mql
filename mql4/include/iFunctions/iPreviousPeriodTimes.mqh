/**
 * Ermittelt Beginn und Ende der dem Parameter openTime.fxt vorhergehenden Periode und schreibt das Ergebnis in die �bergebenen
 * Variablen. Ist der Parameter openTime.fxt NULL, werden beginn und Ende der j�ngsten Periode (also ggf. der aktuellen) zur�ckgegeben.
 *
 * @param  _IN_     int       timeframe     - Timeframe der zu ermittelnden Periode (NULL: der aktuelle Timeframe)
 * @param  _IN_OUT_ datetime &openTime.fxt  - Variable zur Aufnahme des Beginns der resultierenden Periode in FXT-Zeit
 * @param  _OUT_    datetime &closeTime.fxt - Variable zur Aufnahme des Endes der resultierenden Periode in FXT-Zeit
 * @param  _OUT_    datetime &openTime.srv  - Variable zur Aufnahme des Beginns der resultierenden Periode in Serverzeit
 * @param  _OUT_    datetime &closeTime.srv - Variable zur Aufnahme des Endes der resultierenden Periode in Serverzeit
 *
 * @return bool - Erfolgsstatus
 */
bool iPreviousPeriodTimes(int timeframe/*=NULL*/, datetime &openTime.fxt/*=NULL*/, datetime &closeTime.fxt, datetime &openTime.srv, datetime &closeTime.srv) {
   if (!timeframe)
      timeframe = Period();
   int month, dom, dow, monthOpenTime, monthNow;
   datetime now.fxt;


   // (1) PERIOD_D1
   if (timeframe == PERIOD_D1) {
      // ist openTime.fxt nicht gesetzt, Variable mit Zeitpunkt des n�chsten Tages initialisieren
      if (!openTime.fxt)
         openTime.fxt = TimeFXT() + 1*DAY;

      // openTime.fxt auf 00:00 Uhr des vorherigen Tages setzen
      openTime.fxt -= (1*DAY + TimeHour(openTime.fxt)*HOURS + TimeMinute(openTime.fxt)*MINUTES + TimeSeconds(openTime.fxt));

      // Wochenenden in openTime.fxt �berspringen
      dow = TimeDayOfWeek(openTime.fxt);
      if      (dow == SATURDAY) openTime.fxt -= 1*DAY;
      else if (dow == SUNDAY  ) openTime.fxt -= 2*DAYS;

      // closeTime.fxt auf 00:00 des folgenden Tages setzen
      closeTime.fxt = openTime.fxt + 1*DAY;
   }


   // (2) PERIOD_W1
   else if (timeframe == PERIOD_W1) {
      // ist openTime.fxt nicht gesetzt, Variable mit Zeitpunkt der n�chsten Woche initialisieren
      if (!openTime.fxt)
         openTime.fxt = TimeFXT() + 7*DAYS;

      // openTime.fxt auf Montag, 00:00 Uhr der vorherigen Woche setzen
      openTime.fxt -= (TimeHour(openTime.fxt)*HOURS + TimeMinute(openTime.fxt)*MINUTES + TimeSeconds(openTime.fxt));    // 00:00 des aktuellen Tages
      openTime.fxt -= (TimeDayOfWeek(openTime.fxt)+6)%7 * DAYS;                                                         // Montag der aktuellen Woche
      openTime.fxt -= 7*DAYS;                                                                                           // Montag der Vorwoche

      // closeTime.fxt auf 00:00 des folgenden Samstags setzen
      closeTime.fxt = openTime.fxt + 5*DAYS;
   }


   // (3) PERIOD_MN1
   else if (timeframe == PERIOD_MN1) {
      // ist openTime.fxt nicht gesetzt, Variable mit Zeitpunkt des n�chsten Monats initialisieren
      if (!openTime.fxt) {
         now.fxt      = TimeFXT();
         openTime.fxt = now.fxt + 1*MONTH;

         monthNow      = TimeMonth(now.fxt     );                                                                       // MONTH ist nicht fix: Sicherstellen, da� openTime.fxt
         monthOpenTime = TimeMonth(openTime.fxt);                                                                       // nicht schon auf den �bern�chsten Monat zeigt.
         if (monthNow > monthOpenTime)
            monthOpenTime += 12;
         if (monthOpenTime > monthNow+1)
            openTime.fxt -= 4*DAYS;
      }

      openTime.fxt -= (TimeHour(openTime.fxt)*HOURS + TimeMinute(openTime.fxt)*MINUTES + TimeSeconds(openTime.fxt));    // 00:00 des aktuellen Tages

      // closeTime.fxt auf den 1. des folgenden Monats, 00:00 setzen
      dom = TimeDay(openTime.fxt);
      closeTime.fxt = openTime.fxt - (dom-1)*DAYS;                                                                      // erster des aktuellen Monats

      // openTime.fxt auf den 1. des vorherigen Monats, 00:00 Uhr setzen
      openTime.fxt  = closeTime.fxt - 1*DAYS;                                                                           // letzter Tag des vorherigen Monats
      openTime.fxt -= (TimeDay(openTime.fxt)-1)*DAYS;                                                                   // erster Tag des vorherigen Monats

      // Wochenenden in openTime.fxt �berspringen
      dow = TimeDayOfWeek(openTime.fxt);
      if      (dow == SATURDAY) openTime.fxt += 2*DAYS;
      else if (dow == SUNDAY  ) openTime.fxt += 1*DAY;

      // Wochenenden in closeTime.fxt �berspringen
      dow = TimeDayOfWeek(closeTime.fxt);
      if      (dow == SUNDAY) closeTime.fxt -= 1*DAY;
      else if (dow == MONDAY) closeTime.fxt -= 2*DAYS;
   }


   // (4) PERIOD_Q1
   else if (timeframe == PERIOD_Q1) {
      // ist openTime.fxt nicht gesetzt, Variable mit Zeitpunkt des n�chsten Quartals initialisieren
      if (!openTime.fxt) {
         now.fxt      = TimeFXT();
         openTime.fxt = now.fxt + 1*QUARTER;

         monthNow      = TimeMonth(now.fxt     );                                                                       // QUARTER ist nicht fix: Sicherstellen, da� openTime.fxt
         monthOpenTime = TimeMonth(openTime.fxt);                                                                       // nicht schon auf das �bern�chste Quartal zeigt.
         if (monthNow > monthOpenTime)
            monthOpenTime += 12;
         if (monthOpenTime > monthNow+3)
            openTime.fxt -= 1*MONTH;
      }

      openTime.fxt -= (TimeHour(openTime.fxt)*HOURS + TimeMinute(openTime.fxt)*MINUTES + TimeSeconds(openTime.fxt));    // 00:00 des aktuellen Tages

      // closeTime.fxt auf den ersten Tag des folgenden Quartals, 00:00 setzen
      switch (TimeMonth(openTime.fxt)) {
         case JANUARY  :
         case FEBRUARY :
         case MARCH    : closeTime.fxt = openTime.fxt - (TimeDayOfYear(openTime.fxt)-1)*DAYS; break;                    // erster Tag des aktuellen Quartals (01.01.)
         case APRIL    : closeTime.fxt = openTime.fxt -       (TimeDay(openTime.fxt)-1)*DAYS; break;
         case MAY      : closeTime.fxt = openTime.fxt - (30+   TimeDay(openTime.fxt)-1)*DAYS; break;
         case JUNE     : closeTime.fxt = openTime.fxt - (30+31+TimeDay(openTime.fxt)-1)*DAYS; break;                    // erster Tag des aktuellen Quartals (01.04.)
         case JULY     : closeTime.fxt = openTime.fxt -       (TimeDay(openTime.fxt)-1)*DAYS; break;
         case AUGUST   : closeTime.fxt = openTime.fxt - (31+   TimeDay(openTime.fxt)-1)*DAYS; break;
         case SEPTEMBER: closeTime.fxt = openTime.fxt - (31+31+TimeDay(openTime.fxt)-1)*DAYS; break;                    // erster Tag des aktuellen Quartals (01.07.)
         case OCTOBER  : closeTime.fxt = openTime.fxt -       (TimeDay(openTime.fxt)-1)*DAYS; break;
         case NOVEMBER : closeTime.fxt = openTime.fxt - (31+   TimeDay(openTime.fxt)-1)*DAYS; break;
         case DECEMBER : closeTime.fxt = openTime.fxt - (31+30+TimeDay(openTime.fxt)-1)*DAYS; break;                    // erster Tag des aktuellen Quartals (01.10.)
      }

      // openTime.fxt auf den ersten Tag des vorherigen Quartals, 00:00 Uhr setzen
      openTime.fxt = closeTime.fxt - 1*DAY;                                                                             // letzter Tag des vorherigen Quartals
      switch (TimeMonth(openTime.fxt)) {
         case MARCH    : openTime.fxt -= (TimeDayOfYear(openTime.fxt)-1)*DAYS; break;                                   // erster Tag des vorherigen Quartals (01.01.)
         case JUNE     : openTime.fxt -= (30+31+TimeDay(openTime.fxt)-1)*DAYS; break;                                   // erster Tag des vorherigen Quartals (01.04.)
         case SEPTEMBER: openTime.fxt -= (31+31+TimeDay(openTime.fxt)-1)*DAYS; break;                                   // erster Tag des vorherigen Quartals (01.07.)
         case DECEMBER : openTime.fxt -= (31+30+TimeDay(openTime.fxt)-1)*DAYS; break;                                   // erster Tag des vorherigen Quartals (01.10.)
      }

      // Wochenenden in openTime.fxt �berspringen
      dow = TimeDayOfWeek(openTime.fxt);
      if      (dow == SATURDAY) openTime.fxt += 2*DAYS;
      else if (dow == SUNDAY  ) openTime.fxt += 1*DAY;

      // Wochenenden in closeTime.fxt �berspringen
      dow = TimeDayOfWeek(closeTime.fxt);
      if      (dow == SUNDAY) closeTime.fxt -= 1*DAY;
      else if (dow == MONDAY) closeTime.fxt -= 2*DAYS;
   }


   // (5) alle �brigen noch nicht implementierten Timeframes
   else {
      string sTimeframe = PeriodToStr(timeframe, MUTE_ERR_INVALID_PARAMETER);
      return(!catch("iPreviousPeriodTimes(1)  not yet supported timeframe = "+ ifString(sTimeframe=="", timeframe, sTimeframe), ERR_INVALID_PARAMETER));
   }


   // (6) entsprechende Serverzeiten ermitteln
   openTime.srv  = FxtToServerTime(openTime.fxt );
   closeTime.srv = FxtToServerTime(closeTime.fxt);

   return(!catch("iPreviousPeriodTimes(2)"));
}