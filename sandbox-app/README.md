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

## How to get this onto your IBM i

The source in this folder lives on your PC (in the repo). To do the lab, it needs to end up as a
**SANDBOX library** on your IBM i, with the file created and the programs compiled. Here are two ways.

### Option A - Let Bob do it (recommended, and the easiest)

This is the on-brand way, and it doubles as a nice first demo of Bob working on IBM i. Bob reads the
local source files and builds them on your connected IBM i for you.

1. **Get the source onto your machine.** On the GitHub page, click the green **Code** button ->
   **Download ZIP**, unzip it. (Or `git clone` the repo.)
2. **Open this `sandbox-app` folder in Bob.** In Bob/VS Code: **File -> Open Folder...** and open the
   `sandbox-app` folder. Now Bob can see the source files.
3. **Connect to your IBM i** (the Setup section of the main lab covers this).
4. **Start a task in the IBM i Library List workspace, in IBM i Developer mode**, and paste this prompt:

   ```
   I have the SANDBOX application source in this workspace: CUSTMAST.pf (a physical file) in qddssrc,
   and CUSTINQ, CUSTUPD, CUSTRPT, CUSTBAL (RPGLE) plus CREDASM (SQLRPGLE) in qrpglesrc.

   On my IBM i, please:
   1. Create a library called SANDBOX.
   2. Create source physical files SANDBOX/QDDSSRC and SANDBOX/QRPGLESRC, and copy these source
      members into them.
   3. Create the CUSTMAST physical file from the DDS.
   4. Compile the four RPGLE programs (CUSTINQ, CUSTUPD, CUSTRPT, CUSTBAL) into SANDBOX.
   5. Leave the CREDASM source in QRPGLESRC but do NOT compile it yet - a later lab step does that.
   6. Insert three sample customer rows into CUSTMAST so there is data to work with.
   ```

5. **Approve each step** as Bob creates the library, uploads the members, compiles, and adds the data.

That is it - and you have already seen Bob create objects and run commands on your IBM i.

> **Tip:** if any compile fails, just tell Bob the error - it will read it and fix it. That is part of
> the point.

### Option B - Do it by hand (if you prefer the traditional way)

If you would rather use Code for IBM i directly: create the library and source physical files, upload
the members (drag-and-drop in the IFS/Object Browser, FTP, or a save file), then run:

```
CRTLIB     LIB(SANDBOX)
CRTPF      FILE(SANDBOX/CUSTMAST) SRCFILE(SANDBOX/QDDSSRC) SRCMBR(CUSTMAST)
CRTBNDRPG  PGM(SANDBOX/CUSTINQ) SRCFILE(SANDBOX/QRPGLESRC) SRCMBR(CUSTINQ)
CRTBNDRPG  PGM(SANDBOX/CUSTUPD) SRCFILE(SANDBOX/QRPGLESRC) SRCMBR(CUSTUPD)
CRTBNDRPG  PGM(SANDBOX/CUSTRPT) SRCFILE(SANDBOX/QRPGLESRC) SRCMBR(CUSTRPT)
CRTBNDRPG  PGM(SANDBOX/CUSTBAL) SRCFILE(SANDBOX/QRPGLESRC) SRCMBR(CUSTBAL)
```

Then add a few sample rows:

```sql
INSERT INTO SANDBOX.CUSTMAST VALUES (1001, 'Ada Lovelace', 250.00);
INSERT INTO SANDBOX.CUSTMAST VALUES (1002, 'Grace Hopper', -40.00);
INSERT INTO SANDBOX.CUSTMAST VALUES (1003, 'Alan Turing',  980.00);
```

> `CREDASM` is compiled as a module/service program when the testing workflow needs it in Part 4, so
> you do not have to compile it up front - just have the source in `SANDBOX/QRPGLESRC`.

Once SANDBOX exists with the file, the compiled programs, and a few rows of data, you are ready to
start the lab.
