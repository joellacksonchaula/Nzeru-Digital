from django.contrib import admin
from django.utils import timezone
from .models import (
    UserProfile, SavingsPlan, Transaction, Loan,
    LoanPayment, Penalty, InterestDistribution, Notification
)


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'phone', 'savings_balance', 'loan_balance', 'financial_score')
    search_fields = ('user__username', 'phone')
    readonly_fields = ('savings_balance', 'loan_balance', 'financial_score')
    actions = ['recalculate_balances']

    @admin.action(description='Recalculate balances and scores')
    def recalculate_balances(self, request, queryset):
        for profile in queryset:
            profile.recalculate_savings_balance()
            profile.recalculate_loan_balance()
            profile.calculate_financial_score()
        self.message_user(request, f'Recalculated {queryset.count()} profiles.')


@admin.register(SavingsPlan)
class SavingsPlanAdmin(admin.ModelAdmin):
    list_display = ('user', 'amount_per_period', 'frequency', 'duration_months',
                    'goal_amount', 'current_amount', 'grace_period_days', 'is_active', 'is_trial')
    list_filter = ('frequency', 'is_active', 'penalty_policy', 'is_trial')
    search_fields = ('user__username',)


@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('user', 'type', 'amount', 'status', 'timestamp', 'plan')
    list_filter = ('type', 'status', 'timestamp')
    search_fields = ('user__username', 'description')


@admin.register(Penalty)
class PenaltyAdmin(admin.ModelAdmin):
    list_display = ('user', 'amount', 'penalty_type', 'reason', 'date', 'is_applied')
    list_filter = ('penalty_type', 'is_applied', 'date')
    search_fields = ('user__username', 'reason')


@admin.register(Loan)
class LoanAdmin(admin.ModelAdmin):
    list_display = ('user', 'plan', 'amount', 'interest_rate', 'withdrawal_mode', 'status', 'approved_date',
                    'due_date', 'remaining_balance')
    list_filter = ('status', 'approved_date', 'withdrawal_mode')
    search_fields = ('user__username',)
    actions = ['approve_loans', 'reject_loans']

    @admin.action(description='Approve selected loans')
    def approve_loans(self, request, queryset):
        updated = queryset.filter(status='PENDING').update(
            status='APPROVED',
            approved_date=timezone.now(),
        )
        for loan in queryset.filter(status='APPROVED'):
            Notification.objects.create(
                user=loan.user,
                title='Credit Approved!',
                message=f'Your credit of MK {loan.amount} has been approved.',
                type='LOAN_APPROVED',
            )
        self.message_user(request, f'{updated} credit request(s) approved.')

    @admin.action(description='Reject selected loans')
    def reject_loans(self, request, queryset):
        updated = queryset.filter(status='PENDING').update(status='REJECTED')
        self.message_user(request, f'{updated} credit request(s) rejected.')


@admin.register(LoanPayment)
class LoanPaymentAdmin(admin.ModelAdmin):
    list_display = ('loan', 'amount_paid', 'payment_date', 'remaining_balance')
    list_filter = ('payment_date',)


@admin.register(InterestDistribution)
class InterestDistributionAdmin(admin.ModelAdmin):
    list_display = ('loan', 'total_interest', 'user_savings_share', 'platform_share', 'distributed_at')
    list_filter = ('distributed_at',)


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'title', 'type', 'is_read', 'created_at')
    list_filter = ('type', 'is_read', 'created_at')
    search_fields = ('user__username', 'title', 'message')
