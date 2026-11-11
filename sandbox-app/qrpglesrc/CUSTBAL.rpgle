**FREE
// JH-SHARED-STANDARD
// =========================================================
// Program  : CUSTBAL
// Purpose  : Read CUSTMAST by CUSTID and flag whether the
//            customer's balance is negative.
// Author   : Bob
// Date     : 2025-07-10
// =========================================================

ctl-opt dftactgrp(*no) actgrp(*caller);

// -- File declaration (keyed, library-list resolution) ----
dcl-f CUSTMAST disk(*ext) usage(*input) keyed;

// -- Entry parameters -------------------------------------
dcl-pi *n;
  pCustId  packed(7:0) const;
  pNegBal  ind;
end-pi;

// -- Local variables ---------------------------------------
dcl-s notFound ind inz(*off);

// -- Mainline ----------------------------------------------
pNegBal = *off;

monitor;
  chain pCustId CUSTREC;
  if %found(CUSTMAST);
    if BALANCE < 0;
      pNegBal = *on;
    endif;
  else;
    notFound = *on;
  endif;
on-error;
  // I/O error - leave pNegBal as *off and return
endmon;

*inlr = *on;

