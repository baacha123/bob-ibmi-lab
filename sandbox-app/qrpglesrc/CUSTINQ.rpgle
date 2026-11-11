**free
// =====================================================================
// CUSTINQ - Customer Inquiry
// Purpose: Look up a customer in CUSTMAST by CUSTID.
//          Returns customer name and balance to the caller.
//          Returns found indicator (*ON = found, *OFF = not found).
// Parameters:
//   pCustId  (Input)  - Customer ID to look up
//   pName    (Output) - Customer name returned
//   pBalance (Output) - Account balance returned
//   pFound   (Output) - *ON if record was found
// =====================================================================
ctl-opt dftactgrp(*no) actgrp(*caller)
        option(*srcstmt : *nodebugio)
        text('Customer Inquiry - lookup by CUSTID');

// File declaration - keyed input, fully qualified so compiler finds it
dcl-f CUSTMAST disk(*ext) usage(*input) keyed
      extdesc('SANDBOX/CUSTMAST');

// Program parameters
dcl-pi CUSTINQ;
  pCustId  packed(7:0) const;
  pName    char(30);
  pBalance packed(11:2);
  pFound   ind;
end-pi;

// Initialise output parameters
pName    = *blanks;
pBalance = 0;
pFound   = *off;

// Look up the customer record by key
chain pCustId CUSTREC;

if %found(CUSTMAST);
  pName    = CUSTNAME;
  pBalance = BALANCE;
  pFound   = *on;
endif;

*inlr = *on;
