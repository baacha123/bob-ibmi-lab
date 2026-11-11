**free
ctl-opt dftactgrp(*no) actgrp(*caller);

dcl-f CUSTMAST disk(*ext) usage(*input : *update) keyed
      extdesc('SANDBOX/CUSTMAST');

dcl-pi CUSTUPD;
  id     packed(7:0) const;
  newbal packed(11:2) const;
end-pi;

chain id CUSTREC;

if %found(CUSTMAST);
  BALANCE = newbal;
  update CUSTREC;
endif;

*inlr = *on;

