# SANDBOX - the sample application for this lab

This folder contains the source for **SANDBOX**, the small banking application the lab uses. It is
deliberately simple so you can focus on learning Bob, not on a complex app.

## What is in it

| Source | Type | What it is |
|--------|------|------------|
| `qddssrc/CUSTMAST.pf` | Physical file (DDS) | The customer master file - fields `CUSTID` (key), `CUSTNAME`, `BALANCE` |
| `qrpglesrc/CUSTINQ.rpgle` | RPGLE program | Looks up a customer's name and balance by ID |
| `qrpglesrc/CUSTUPD.rpgle` | RPGLE program | Updates a customer's balance (the only writer) |
| `qrpglesrc/CUSTRPT.rpgle` | RPGLE program | Reports customers with a negative balance |
| `qrpglesrc/CUSTBAL.rpgle` | RPGLE program | Flags a negative balance |
| `qrpglesrc/CREDASM.sqlrpgle` | SQLRPGLE service program | Credit assessment - decides loan eligibility, interest rate, monthly payment |

> **Note on CREDASM:** this is the *original* version on purpose. It has a small rounding issue in the
> monthly-payment calculation - and that is intentional. In Part 4 of the lab, the tests you build
> **catch that bug**, and Bob fixes it. If we shipped the fixed version, you would miss that moment.

> **What is NOT here (on purpose):** the `CUSTOMRZ` table that CREDASM reads. In Part 4, Bob discovers
> it is missing and offers to create it for you - that is one of the teaching moments. So leave it out.

## How to deploy it to your IBM i

You have two easy options.

### Option A - Let Bob do it (recommended)

Download this folder, open it in Bob, connect to your IBM i, and ask:

```
Create a library called SANDBOX. Then create the customer master file from CUSTMAST.pf, and compile
the RPGLE programs (CUSTINQ, CUSTUPD, CUSTRPT, CUSTBAL) and the CREDASM service program into SANDBOX.
```

Approve the steps. (This is itself a nice demo of Bob working on IBM i.)

### Option B - Do it by hand

1. Create the library and upload the source into source physical files (`QDDSSRC` for the DDS,
   `QRPGLESRC` for the RPG). Your preferred upload method works - Code for IBM i, FTP, or a save file.
2. Create the file and compile the programs, for example:

```
CRTLIB     LIB(SANDBOX)
CRTPF      FILE(SANDBOX/CUSTMAST) SRCFILE(SANDBOX/QDDSSRC) SRCMBR(CUSTMAST)
CRTBNDRPG  PGM(SANDBOX/CUSTINQ) SRCFILE(SANDBOX/QRPGLESRC) SRCMBR(CUSTINQ)
CRTBNDRPG  PGM(SANDBOX/CUSTUPD) SRCFILE(SANDBOX/QRPGLESRC) SRCMBR(CUSTUPD)
CRTBNDRPG  PGM(SANDBOX/CUSTRPT) SRCFILE(SANDBOX/QRPGLESRC) SRCMBR(CUSTRPT)
CRTBNDRPG  PGM(SANDBOX/CUSTBAL) SRCFILE(SANDBOX/QRPGLESRC) SRCMBR(CUSTBAL)
```

`CREDASM` is compiled as a module/service program when the testing workflow needs it in Part 4, so you
do not have to compile it up front - just have the source in `SANDBOX/QRPGLESRC`.

3. Add a few sample customer rows so the programs have data to work with, for example:

```sql
INSERT INTO SANDBOX.CUSTMAST VALUES (1001, 'Ada Lovelace', 250.00);
INSERT INTO SANDBOX.CUSTMAST VALUES (1002, 'Grace Hopper', -40.00);
INSERT INTO SANDBOX.CUSTMAST VALUES (1003, 'Alan Turing',  980.00);
```

Once SANDBOX exists with these objects, you are ready to start the lab.
