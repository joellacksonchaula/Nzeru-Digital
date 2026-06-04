from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from decimal import Decimal
from django.db.models import Q
import secrets


class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    phone = models.CharField(max_length=15, blank=True)
    savings_balance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    loan_balance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    financial_score = models.IntegerField(default=50)
    preferred_theme = models.CharField(max_length=20, default='system')
    preferred_language = models.CharField(max_length=20, default='en')
    preferred_currency = models.CharField(max_length=10, default='MWK')
    notifications_enabled = models.BooleanField(default=True)
    transaction_alerts = models.BooleanField(default=True)
    two_factor_enabled = models.BooleanField(default=False)
    biometric_login_enabled = models.BooleanField(default=False)
    auto_save_enabled = models.BooleanField(default=False)
    credit_usage_preference = models.CharField(max_length=20, default='flexible')
    payment_methods = models.TextField(blank=True, default='')
    app_feedback = models.TextField(blank=True, default='')
    default_savings_plan = models.ForeignKey(
        'SavingsPlan',
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='default_for_profiles',
    )

    def __str__(self):
        return self.user.username

    class Meta:
        ordering = ['user__username']

    def recalculate_savings_balance(self):
        """Balance = Deposits + Interest Rewards - Penalties - Withdrawals"""
        deposits = self.user.transactions.filter(
            Q(plan__isnull=True) | Q(plan__is_trial=False),
            type='DEPOSIT',
            status='COMPLETED',
        ).aggregate(total=models.Sum('amount'))['total'] or Decimal('0')

        interest = self.user.transactions.filter(
            Q(plan__isnull=True) | Q(plan__is_trial=False),
            type='INTEREST_REWARD',
            status='COMPLETED',
        ).aggregate(total=models.Sum('amount'))['total'] or Decimal('0')

        penalties = self.user.transactions.filter(
            Q(plan__isnull=True) | Q(plan__is_trial=False),
            type='PENALTY',
            status='COMPLETED',
        ).aggregate(total=models.Sum('amount'))['total'] or Decimal('0')

        withdrawals = self.user.transactions.filter(
            Q(plan__isnull=True) | Q(plan__is_trial=False),
            type='WITHDRAWAL',
            status='COMPLETED',
        ).aggregate(total=models.Sum('amount'))['total'] or Decimal('0')

        self.savings_balance = deposits + interest - penalties - withdrawals
        self.save(update_fields=['savings_balance'])
        return self.savings_balance

    def recalculate_loan_balance(self):
        """Credit balance = sum of remaining balances for active credits."""
        active_loans = self.user.loans.filter(
            Q(plan__isnull=True) | Q(plan__is_trial=False),
            status__in=['APPROVED', 'ACTIVE'],
        )
        total = Decimal('0')
        for loan in active_loans:
            total += loan.remaining_balance
        self.loan_balance = total
        self.save(update_fields=['loan_balance'])
        return self.loan_balance

    def settings_payload(self):
        return {
            'preferred_theme': self.preferred_theme,
            'preferred_language': self.preferred_language,
            'preferred_currency': self.preferred_currency,
            'notifications_enabled': self.notifications_enabled,
            'transaction_alerts': self.transaction_alerts,
            'two_factor_enabled': self.two_factor_enabled,
            'biometric_login_enabled': self.biometric_login_enabled,
            'auto_save_enabled': self.auto_save_enabled,
            'credit_usage_preference': self.credit_usage_preference,
            'payment_methods': [
                method.strip()
                for method in self.payment_methods.split(',')
                if method.strip()
            ],
            'app_feedback': self.app_feedback,
            'default_savings_plan_id': (
                str(self.default_savings_plan_id) if self.default_savings_plan_id else None
            ),
        }

    def calculate_financial_score(self):
        """Score based on savings consistency, loan repayment, and penalty frequency."""
        score = 50  # base score

        # Savings consistency (up to +30 points)
        plans = self.user.savings_plans.filter(is_active=True, is_trial=False)
        if plans.exists():
            total_expected = 0
            total_deposited = 0
            for plan in plans:
                months_active = max(
                    1,
                    (timezone.now() - plan.start_date).days // 30
                )
                if plan.frequency == 'WEEKLY':
                    total_expected += float(plan.amount_per_period) * months_active * 4
                elif plan.frequency == 'BIWEEKLY':
                    total_expected += float(plan.amount_per_period) * months_active * 2
                elif plan.frequency == 'MONTHLY':
                    total_expected += float(plan.amount_per_period) * months_active
                elif plan.frequency == 'DAILY':
                    total_expected += float(plan.amount_per_period) * months_active * 30
                total_deposited += float(plan.current_amount)

            if total_expected > 0:
                consistency = min(1.0, total_deposited / total_expected)
                score += int(consistency * 30)

        # Loan repayment record (up to +20 points)
        paid_loans = self.user.loans.filter(
            Q(plan__isnull=True) | Q(plan__is_trial=False),
            status='PAID',
        ).count()
        defaulted_loans = self.user.loans.filter(
            Q(plan__isnull=True) | Q(plan__is_trial=False),
            status='DEFAULTED',
        ).count()
        total_loans = paid_loans + defaulted_loans
        if total_loans > 0:
            repayment_rate = paid_loans / total_loans
            score += int(repayment_rate * 20)
        elif self.user.loans.filter(
            Q(plan__isnull=True) | Q(plan__is_trial=False)
        ).count() == 0:
            score += 10  # neutral — no loan history

        # Penalty frequency (up to -20 points)
        penalty_count = self.user.penalties.filter(
            Q(plan__isnull=True) | Q(plan__is_trial=False)
        ).count()
        if penalty_count == 0:
            score += 10
        elif penalty_count <= 2:
            score += 0
        elif penalty_count <= 5:
            score -= 10
        else:
            score -= 20

        self.financial_score = max(0, min(100, score))
        self.save(update_fields=['financial_score'])
        return self.financial_score


class SavingsPlan(models.Model):
    FREQUENCY_CHOICES = [
        ('DAILY', 'Daily'),
        ('WEEKLY', 'Weekly'),
        ('BIWEEKLY', 'Bi-Weekly'),
        ('MONTHLY', 'Monthly'),
    ]
    PENALTY_CHOICES = [
        ('MONETARY', 'Monetary Deduction'),
        ('RESTRICTION', 'App Restriction'),
        ('BOTH', 'Both'),
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='savings_plans')
    title = models.CharField(max_length=120, default='Savings Plan')
    amount_per_period = models.DecimalField(max_digits=12, decimal_places=2)
    frequency = models.CharField(max_length=10, choices=FREQUENCY_CHOICES)
    duration_months = models.IntegerField()
    start_date = models.DateTimeField(default=timezone.now)
    end_date = models.DateTimeField()
    penalty_policy = models.CharField(max_length=15, choices=PENALTY_CHOICES)
    goal_amount = models.DecimalField(max_digits=12, decimal_places=2)
    current_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    grace_period_days = models.IntegerField(default=3)
    is_active = models.BooleanField(default=True)
    is_secret = models.BooleanField(default=False)
    is_trial = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True, null=True, blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.title}"

    class Meta:
        ordering = ['-start_date']

    @property
    def progress_percent(self):
        if self.goal_amount > 0:
            return min(100, float(self.current_amount / self.goal_amount * 100))
        return 0

    def get_next_deadline(self):
        """Calculate the next savings deadline based on frequency."""
        now = timezone.now()
        if not self.is_active or now > self.end_date:
            return None
        from datetime import timedelta
        if self.frequency == 'DAILY':
            delta = timedelta(days=1)
        elif self.frequency == 'WEEKLY':
            delta = timedelta(weeks=1)
        elif self.frequency == 'BIWEEKLY':
            delta = timedelta(weeks=2)
        else:  # MONTHLY
            delta = timedelta(days=30)

        deadline = self.start_date
        while deadline <= now:
            deadline += delta
        return deadline

    def get_deadline_with_grace(self):
        """Deadline + grace period before penalty starts."""
        from datetime import timedelta
        deadline = self.get_next_deadline()
        if deadline:
            return deadline + timedelta(days=self.grace_period_days)
        return None

    @property
    def is_mature(self):
        return timezone.now() >= self.end_date

    @property
    def days_until_maturity(self):
        remaining = self.end_date - timezone.now()
        return max(0, remaining.days)


class Transaction(models.Model):
    TYPE_CHOICES = [
        ('DEPOSIT', 'Deposit'),
        ('WITHDRAWAL', 'Withdrawal'),
        ('PENALTY', 'Penalty'),
        ('INTEREST_REWARD', 'Interest Reward'),
    ]
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('COMPLETED', 'Completed'),
        ('FAILED', 'Failed'),
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='transactions')
    plan = models.ForeignKey(SavingsPlan, null=True, blank=True, on_delete=models.CASCADE, related_name='transactions')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    timestamp = models.DateTimeField(auto_now_add=True)
    type = models.CharField(max_length=15, choices=TYPE_CHOICES)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='COMPLETED')
    description = models.TextField(blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.type} - {self.amount}"

    class Meta:
        ordering = ['-timestamp']


class Penalty(models.Model):
    PENALTY_TYPE_CHOICES = [
        ('MONETARY', 'Monetary Deduction'),
        ('RESTRICTION', 'App Restriction'),
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='penalties')
    plan = models.ForeignKey(SavingsPlan, null=True, blank=True, on_delete=models.CASCADE, related_name='penalties')
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    penalty_type = models.CharField(max_length=15, choices=PENALTY_TYPE_CHOICES, default='MONETARY')
    reason = models.TextField()
    date = models.DateTimeField(auto_now_add=True)
    is_applied = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.user.username} - Penalty: {self.amount}"

    class Meta:
        ordering = ['-date']


class Loan(models.Model):
    WITHDRAWAL_MODE_CHOICES = [
        ('INSTANT', 'All At Once'),
        ('DAILY', 'Daily Locked Amount'),
        ('WEEKLY', 'Weekly Locked Amount'),
    ]
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('APPROVED', 'Approved'),
        ('ACTIVE', 'Active'),
        ('REJECTED', 'Rejected'),
        ('PAID', 'Paid'),
        ('DEFAULTED', 'Defaulted'),
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='loans')
    plan = models.ForeignKey(
        SavingsPlan,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name='credits',
    )
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    interest_rate = models.DecimalField(max_digits=5, decimal_places=2, default=10)
    duration_months = models.IntegerField()
    withdrawal_mode = models.CharField(
        max_length=10,
        choices=WITHDRAWAL_MODE_CHOICES,
        default='INSTANT',
    )
    locked_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='PENDING')
    approved_date = models.DateTimeField(null=True, blank=True)
    due_date = models.DateTimeField()
    remaining_balance = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - Loan: {self.amount} ({self.status})"

    class Meta:
        ordering = ['-created_at']

    @property
    def total_with_interest(self):
        return self.amount * (1 + self.interest_rate / 100)

    @property
    def monthly_payment(self):
        if self.duration_months > 0:
            return self.total_with_interest / self.duration_months
        return self.total_with_interest

    @property
    def is_trial(self):
        return bool(self.plan and self.plan.is_trial)

    @property
    def repayment_progress(self):
        total = float(self.total_with_interest)
        if total > 0:
            repaid = total - float(self.remaining_balance)
            return min(1.0, repaid / total)
        return 0


class LoanPayment(models.Model):
    loan = models.ForeignKey(Loan, on_delete=models.CASCADE, related_name='payments')
    amount_paid = models.DecimalField(max_digits=10, decimal_places=2)
    payment_date = models.DateTimeField(auto_now_add=True)
    remaining_balance = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Payment: {self.amount_paid} for Loan #{self.loan.id}"

    class Meta:
        ordering = ['-payment_date']


class InterestDistribution(models.Model):
    loan = models.OneToOneField(Loan, on_delete=models.CASCADE, related_name='interest_distribution')
    total_interest = models.DecimalField(max_digits=10, decimal_places=2)
    user_savings_share = models.DecimalField(max_digits=10, decimal_places=2)
    platform_share = models.DecimalField(max_digits=10, decimal_places=2)
    distributed_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Interest for Loan #{self.loan.id}: User={self.user_savings_share}, Platform={self.platform_share}"

    class Meta:
        ordering = ['-distributed_at']


class Notification(models.Model):
    TYPE_CHOICES = [
        ('SAVINGS_REMINDER', 'Savings Reminder'),
        ('SAVINGS_MISSED', 'Savings Missed'),
        ('SAVINGS_MILESTONE', 'Savings Milestone'),
        ('GOAL_ACHIEVED', 'Goal Achieved'),
        ('DEPOSIT_RECEIVED', 'Deposit Received'),
        ('WITHDRAWAL_UNLOCK', 'Withdrawal Unlock'),
        ('DEBT_ALERT', 'Debt Alert'),
        ('SECURITY_ALERT', 'Security Alert'),
        ('PENALTY_APPLIED', 'Penalty Applied'),
        ('LOAN_ELIGIBLE', 'Loan Eligible'),
        ('LOAN_APPROVED', 'Loan Approved'),
        ('LOAN_REPAYMENT', 'Loan Repayment Reminder'),
        ('INTEREST_REWARD', 'Interest Reward'),
        ('IJC_MEMBER_JOINED', 'IJC Member Joined'),
        ('IJC_DEPOSIT_RECEIVED', 'IJC Deposit Received'),
        ('IJC_GOAL_REACHED', 'IJC Goal Reached'),
        ('IJC_CASHOUT_AVAILABLE', 'IJC Cash-Out Available'),
        ('IJC_WITHDRAWAL_COMPLETED', 'IJC Withdrawal Completed'),
        ('GENERAL', 'General'),
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=200)
    message = models.TextField()
    type = models.CharField(max_length=30, choices=TYPE_CHOICES, default='GENERAL')
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.username} - {self.title}"


class IJCGroup(models.Model):
    CASH_OUT_CHOICES = [
        ('DAILY', 'Daily Cash-Out'),
        ('WEEKLY', 'Weekly Cash-Out'),
        ('MONTHLY', 'Monthly Cash-Out'),
    ]
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_ijc_groups')
    name = models.CharField(max_length=140)
    ijc_id = models.CharField(max_length=20, unique=True, editable=False)
    join_code = models.CharField(max_length=12, unique=True, editable=False)
    goal_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    balance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    cash_out_policy = models.CharField(max_length=10, choices=CASH_OUT_CHOICES, default='WEEKLY')
    last_cash_out_at = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.ijc_id} - {self.name}"

    def save(self, *args, **kwargs):
        if not self.ijc_id:
            self.ijc_id = self._generate_ijc_id()
        if not self.join_code:
            self.join_code = self._generate_join_code()
        super().save(*args, **kwargs)

    @staticmethod
    def _generate_ijc_id():
        while True:
            candidate = f"IJC-NZL-{secrets.randbelow(900000) + 100000}"
            if not IJCGroup.objects.filter(ijc_id=candidate).exists():
                return candidate

    @staticmethod
    def _generate_join_code():
        alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
        while True:
            candidate = ''.join(secrets.choice(alphabet) for _ in range(8))
            if not IJCGroup.objects.filter(join_code=candidate).exists():
                return candidate

    @property
    def next_cash_out_date(self):
        from datetime import timedelta
        base = self.last_cash_out_at or self.created_at or timezone.now()
        if self.cash_out_policy == 'DAILY':
            return base + timedelta(days=1)
        if self.cash_out_policy == 'MONTHLY':
            return base + timedelta(days=30)
        return base + timedelta(days=7)

    @property
    def cash_out_available(self):
        return timezone.now() >= self.next_cash_out_date

    @property
    def days_until_cash_out(self):
        remaining = self.next_cash_out_date - timezone.now()
        return max(0, remaining.days)

    @property
    def progress_percent(self):
        if self.goal_amount > 0:
            return min(100, float(self.balance / self.goal_amount * 100))
        return 0


class IJCMember(models.Model):
    ROLE_CHOICES = [
        ('OWNER', 'Owner'),
        ('MEMBER', 'Member'),
    ]
    STATUS_CHOICES = [
        ('PENDING', 'Pending Approval'),
        ('APPROVED', 'Approved'),
        ('REJECTED', 'Rejected'),
    ]
    group = models.ForeignKey(IJCGroup, on_delete=models.CASCADE, related_name='members')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='ijc_memberships')
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='MEMBER')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='PENDING')
    total_contributed = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    joined_at = models.DateTimeField(auto_now_add=True)
    approved_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        unique_together = ('group', 'user')
        ordering = ['-total_contributed', 'joined_at']

    def __str__(self):
        return f"{self.user.username} - {self.group.ijc_id} ({self.role})"


class IJCTransaction(models.Model):
    TYPE_CHOICES = [
        ('DEPOSIT', 'Deposit'),
        ('WITHDRAWAL', 'Withdrawal'),
    ]
    group = models.ForeignKey(IJCGroup, on_delete=models.CASCADE, related_name='transactions')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='ijc_transactions')
    amount = models.DecimalField(max_digits=12, decimal_places=2)
    type = models.CharField(max_length=10, choices=TYPE_CHOICES)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.group.ijc_id} - {self.type} - {self.amount}"


class IJCAuditLog(models.Model):
    group = models.ForeignKey(IJCGroup, on_delete=models.CASCADE, related_name='audit_logs')
    actor = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    action = models.CharField(max_length=120)
    metadata = models.JSONField(default=dict, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
