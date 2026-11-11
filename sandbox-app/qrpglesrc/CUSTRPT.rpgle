**free
// =====================================================================
// CUSTRPT - Customer Overdrawn Account Report
// Purpose: Reads all records from CUSTMAST, calls CUSTINQ for each
//          customer, and lists those whose BALANCE is negative.
//          Output is written to the job log via DSPLY for simplicity.
// =====================================================================
ctl-opt dftactgrp(*no) actgrp(*new)
        option(*srcstmt : *nodebugio)
        text('Customer Report - overdrawn accounts');

// Read all customers sequentially, fully qualified for compile-time lookup
dcl-f CUSTMAST disk(*ext) usage(*input)
      extdesc('SANDBOX/CUSTMAST');

// Prototype for CUSTINQ program call
dcl-pr CUSTINQ extpgm('CUSTINQ');
  prCustId  packed(7:0) const;
  prName    char(30);
  prBalance packed(11:2);
  prFound   ind;
end-pr;

// Work variables
dcl-s wCustId  packed(7:0);
dcl-s wName    char(30);
dcl-s wBalance packed(11:2);
dcl-s wFound   ind;
dcl-s wCount   int(5)   inz(0);
dcl-s wMsg     char(52);

// Report header
dsply '--- Overdrawn Accounts Report ---';

// Prime read
read CUSTMAST;

dow not %eof(CUSTMAST);

  wCustId = CUSTID;

  // Call CUSTINQ to retrieve name and balance
  CUSTINQ(wCustId : wName : wBalance : wFound);

  // List customers with a negative balance
  if wFound = *on and wBalance < 0;
    wCount += 1;
    // Build a 52-char-max message: ID + space + name + space + balance
    wMsg = %char(wCustId) + ' ' + %trimr(wName) + ' ' + %char(wBalance);
    dsply wMsg;
  endif;

  read CUSTMAST;

enddo;

// Summary line
if wCount = 0;
  dsply 'No overdrawn accounts found.';
else;
  dsply (%char(wCount) + ' overdrawn account(s) found.');
endif;

*inlr = *on;
