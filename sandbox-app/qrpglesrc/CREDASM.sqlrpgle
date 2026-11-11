**FREE
ctl-opt nomain;

//==============================================================================
// Banking Domain Sample Service - CREDASM
// Provides credit assessment, loan eligibility, interest and payment calculations
//==============================================================================

//------------------------------------------------------------------------------
// Procedure Prototypes
//------------------------------------------------------------------------------

// Procedure 1: CreditCheck (Dynamic / Customer-tiered)
// Returns dynamic credit score (580 - 820) when customer ID passed, or default 750
dcl-pr CreditCheck int(10);
  custId packed(9:0) const options(*nopass);
end-pr;

// Procedure 2: LoanStatus (Simple)
// Determines if credit score meets minimum threshold
dcl-pr LoanStatus ind;
  creditScore int(10) const;
end-pr;

// Procedure 3: checkCustomerExists (Moderate / Embedded SQL)
// Verifies if customer record exists in the database
dcl-pr checkCustomerExists ind;
  custId packed(9:0) const;
end-pr;

// Procedure 4: calculateInterestRate (Moderate / Multi-tier Business Logic)
// Determines annual interest rate based on credit score and loan term
dcl-pr calculateInterestRate packed(5:2);
  creditScore int(10) const;
  loanTermMonths int(5) const;
end-pr;

// Procedure 5: calculateMonthlyPayment (Complex / Financial Calculation)
// Computes fixed monthly amortized payment amount
dcl-pr calculateMonthlyPayment packed(11:2);
  loanAmount packed(11:2) const;
  annualRate packed(5:2) const;
  termMonths int(5) const;
end-pr;

// Procedure 6: evaluateLoanEligibility (Complex / Composite Banking Decision)
// Performs comprehensive multi-criteria loan eligibility evaluation
dcl-pr evaluateLoanEligibility ind;
  custId packed(9:0) const;
  requestedAmount packed(11:2) const;
  monthlyIncome packed(11:2) const;
  existingMonthlyDebt packed(11:2) const;
  termMonths int(5) const;
  approvedAmount packed(11:2);
  estimatedPayment packed(11:2);
  interestRate packed(5:2);
  reasonCode char(10);
end-pr;

//==============================================================================
// Procedure Implementations
//==============================================================================

//------------------------------------------------------------------------------
// Procedure 1: CreditCheck
//------------------------------------------------------------------------------
dcl-proc CreditCheck export;
  dcl-pi *n int(10);
    custId packed(9:0) const options(*nopass);
  end-pi;

  dcl-s remVal int(5);

  if %parms < 1;
    return 750;
  endif;

  if custId <= 0;
    return 300;
  endif;

  // Calculate dynamic credit score based on customer profile hash
  remVal = %rem(custId : 10);

  select;
    when remVal = 0;
      return 820;
    when remVal <= 3;
      return 760;
    when remVal <= 6;
      return 710;
    when remVal <= 8;
      return 640;
    other;
      return 580;
  endsl;
end-proc;

//------------------------------------------------------------------------------
// Procedure 2: LoanStatus
//------------------------------------------------------------------------------
dcl-proc LoanStatus export;
  dcl-pi *n ind;
    creditScore int(10) const;
  end-pi;

  if creditScore >= 700;
    return *on;
  else;
    return *off;
  endif;
end-proc;

//------------------------------------------------------------------------------
// Procedure 3: checkCustomerExists
//------------------------------------------------------------------------------
dcl-proc checkCustomerExists export;
  dcl-pi *n ind;
    custId packed(9:0) const;
  end-pi;

  dcl-s rowCount int(10) inz(0);

  exec sql
    select count(*)
      into :rowCount
      from CUSTOMRZ
      where CUSTNO = :custId;

  return (SQLCODE = 0 and rowCount > 0);
end-proc;

//------------------------------------------------------------------------------
// Procedure 4: calculateInterestRate
//------------------------------------------------------------------------------
dcl-proc calculateInterestRate export;
  dcl-pi *n packed(5:2);
    creditScore int(10) const;
    loanTermMonths int(5) const;
  end-pi;

  dcl-s rate packed(5:2);

  // Base rate based on credit score tier
  select;
    when creditScore >= 800;
      rate = 4;
    when creditScore >= 750;
      rate = 5;
    when creditScore >= 700;
      rate = 6;
    when creditScore >= 650;
      rate = 7;
    other;
      rate = 9;
  endsl;

  // Add term adjustment for extended loan terms (> 60 months)
  if loanTermMonths > 60;
    rate += 1;
  endif;

  return rate;
end-proc;

//------------------------------------------------------------------------------
// Procedure 5: calculateMonthlyPayment
//------------------------------------------------------------------------------
dcl-proc calculateMonthlyPayment export;
  dcl-pi *n packed(11:2);
    loanAmount packed(11:2) const;
    annualRate packed(5:2) const;
    termMonths int(5) const;
  end-pi;

  dcl-s monthlyRate packed(9:6);
  dcl-s factor      packed(15:6);
  dcl-s monthlyPmt  packed(11:2) inz(0);

  if loanAmount <= 0 or termMonths <= 0;
    return 0;
  endif;

  if annualRate <= 0;
    monthlyPmt = loanAmount / termMonths;
    return monthlyPmt;
  endif;

  // Monthly interest rate = Annual Rate / 100 / 12
  monthlyRate = (annualRate / 100) / 12;

  // Factor = (1 + r) ^ n
  factor = (1 + monthlyRate) ** termMonths;

  // Payment = Principal * (r * factor) / (factor - 1)
  if factor > 1;
    monthlyPmt = loanAmount * ((monthlyRate * factor) / (factor - 1));
  else;
    monthlyPmt = loanAmount / termMonths;
  endif;

  return monthlyPmt;
end-proc;

//------------------------------------------------------------------------------
// Procedure 6: evaluateLoanEligibility
//------------------------------------------------------------------------------
dcl-proc evaluateLoanEligibility export;
  dcl-pi *n ind;
    custId packed(9:0) const;
    requestedAmount packed(11:2) const;
    monthlyIncome packed(11:2) const;
    existingMonthlyDebt packed(11:2) const;
    termMonths int(5) const;
    approvedAmount packed(11:2);
    estimatedPayment packed(11:2);
    interestRate packed(5:2);
    reasonCode char(10);
  end-pi;

  dcl-s score int(10);
  dcl-s totalMonthlyDebt packed(11:2);
  dcl-s dtiRatio packed(5:2);

  // Initialize output parameters
  approvedAmount = 0;
  estimatedPayment = 0;
  interestRate = 0;
  reasonCode = *blanks;

  // 1. Verify customer exists in database
  if not checkCustomerExists(custId);
    reasonCode = 'NO_CUST';
    return *off;
  endif;

  // 2. Validate input parameters
  if requestedAmount <= 0 or monthlyIncome <= 0 or termMonths <= 0;
    reasonCode = 'INV_INPUT';
    return *off;
  endif;

  // 3. Obtain and evaluate credit score dynamically
  score = CreditCheck(custId);
  if not LoanStatus(score);
    reasonCode = 'LOW_SCORE';
    return *off;
  endif;

  // 4. Calculate interest rate and monthly payment
  interestRate = calculateInterestRate(score : termMonths);
  estimatedPayment = calculateMonthlyPayment(requestedAmount : interestRate : termMonths);

  // 5. Debt-To-Income (DTI) evaluation: max allowed is 43%
  totalMonthlyDebt = existingMonthlyDebt + estimatedPayment;
  dtiRatio = (totalMonthlyDebt / monthlyIncome) * 100;

  if dtiRatio > 43;
    reasonCode = 'HIGH_DTI';
    return *off;
  endif;

  // 6. Approval granted
  approvedAmount = requestedAmount;
  reasonCode = 'APPROVED';

  return *on;
end-proc;
