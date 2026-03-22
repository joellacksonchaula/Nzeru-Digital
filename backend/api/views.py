from rest_framework import viewsets, permissions, status, generics
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.contrib.auth.models import User
from django.utils import timezone
from decimal import Decimal

from .models import (
    UserProfile, SavingsPlan, Transaction, Loan,
    LoanPayment, Penalty, InterestDistribution, Notification
)
from .serializers import (
    RegisterSerializer, UserSerializer, UserProfileSerializer,
    SavingsPlanSerializer, TransactionSerializer, LoanSerializer,
    LoanPaymentSerializer, PenaltySerializer, InterestDistributionSerializer,
    NotificationSerializer
)


# ─── Auth ───────────────────────────────────────────

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def current_user(request):
    """Return the current authenticated user's profile."""
    profile, _ = UserProfile.objects.get_or_create(user=request.user)
    serializer = UserProfileSerializer(profile)
    return Response(serializer.data)


# ─── Dashboard Summary (single-call endpoint) ───────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def dashboard_summary(request):
    """
    Returns all data needed for the dashboard in one API call.
    Reduces round-trips and keeps the UI in sync.
    """
    user = request.user
    profile, _ = UserProfile.objects.get_or_create(user=user)

    # Ensure balances are up to date
    profile.recalculate_savings_balance()
    profile.recalculate_loan_balance()
    profile.calculate_financial_score()

    # Active plans summary
    active_plans = SavingsPlan.objects.filter(user=user, is_active=True)
    secret_plans = active_plans.filter(is_secret=True)
    normal_plans = active_plans.filter(is_secret=False)

    # Active loans
    active_loans = Loan.objects.filter(
        user=user, status__in=['APPROVED', 'ACTIVE']
    )
    active_loan_balance = sum(l.remaining_balance for l in active_loans)

    # Recent transactions (last 10 for charts)
    recent_txns = Transaction.objects.filter(user=user).order_by('-timestamp')[:10]

    # Unread notifications count
    unread_count = Notification.objects.filter(user=user, is_read=False).count()

    # Total Penalties
    from django.db.models import Sum
    total_penalties = Penalty.objects.filter(user=user).aggregate(Sum('amount'))['amount__sum'] or 0

    return Response({
        'user': {
            'id': str(user.id),
            'username': user.username,
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'name': f"{user.first_name} {user.last_name}".strip() or user.username,
            'phone': profile.phone,
            'savings_balance': float(profile.savings_balance),
            'loan_balance': float(profile.loan_balance),
            'financial_score': profile.financial_score,
        },
        'savings_balance': float(profile.savings_balance),
        'total_savings': float(profile.savings_balance), # Alias for frontend compatibility
        'loan_balance': float(profile.loan_balance),
        'financial_score': profile.financial_score,
        'active_loan_balance': float(active_loan_balance),
        'active_plans': normal_plans.count(), # Changed from active_plans_count
        'secret_savings_count': secret_plans.count(),
        'secret_savings_balance': float(
            sum(p.current_amount for p in secret_plans)
        ),
        'total_penalties': float(total_penalties),
        'recent_transactions': TransactionSerializer(recent_txns, many=True).data,
        'unread_notifications': unread_count,
    })


# ─── User Profile ──────────────────────────────────

class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

    @action(detail=False, methods=['post'])
    def recalculate(self, request):
        """Recalculate savings balance, loan balance, and financial score."""
        profile, _ = UserProfile.objects.get_or_create(user=request.user)
        profile.recalculate_savings_balance()
        profile.recalculate_loan_balance()
        profile.calculate_financial_score()
        return Response(UserProfileSerializer(profile).data)


# ─── Savings Plans ─────────────────────────────────

class SavingsPlanViewSet(viewsets.ModelViewSet):
    queryset = SavingsPlan.objects.all()
    serializer_class = SavingsPlanSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        qs = self.queryset.filter(user=self.request.user).order_by('-start_date')
        # Allow ?secret=true / ?secret=false filtering
        secret = self.request.query_params.get('secret')
        if secret is not None:
            qs = qs.filter(is_secret=secret.lower() == 'true')
        return qs

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


# ─── Transactions (Deposits) ──────────────────────

class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user).order_by('-timestamp')

    def perform_create(self, serializer):
        txn = serializer.save(user=self.request.user)
        # If this is a deposit linked to a plan, update the plan's current_amount
        if txn.type == 'DEPOSIT' and txn.plan:
            plan = txn.plan
            plan.current_amount += txn.amount
            plan.save(update_fields=['current_amount'])
        # Recalculate user balances
        profile, _ = UserProfile.objects.get_or_create(user=self.request.user)
        profile.recalculate_savings_balance()


# ─── Penalties ─────────────────────────────────────

class PenaltyViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Penalty.objects.all()
    serializer_class = PenaltySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user).order_by('-date')


# ─── Loans ─────────────────────────────────────────

class LoanViewSet(viewsets.ModelViewSet):
    queryset = Loan.objects.all()
    serializer_class = LoanSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user).order_by('-created_at')

    def perform_create(self, serializer):
        """Create a loan request — status starts as PENDING."""
        amount = serializer.validated_data['amount']
        interest_rate = serializer.validated_data.get('interest_rate', Decimal('10'))
        total = amount * (1 + interest_rate / 100)
        serializer.save(
            user=self.request.user,
            status='PENDING',
            remaining_balance=total,
        )


# ─── Loan Eligibility ─────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def loan_eligibility(request):
    """Check how much the user is eligible to borrow (50% of savings)."""
    profile, _ = UserProfile.objects.get_or_create(user=request.user)
    profile.recalculate_savings_balance()
    savings = float(profile.savings_balance)
    max_loan = savings * 0.5
    has_active_loan = request.user.loans.filter(
        status__in=['PENDING', 'APPROVED', 'ACTIVE']
    ).exists()
    return Response({
        'savings_balance': savings,
        'max_loan_amount': max_loan,
        'has_active_loan': has_active_loan,
        'eligible': max_loan > 0 and not has_active_loan,
        'financial_score': profile.financial_score,
    })


# ─── Loan Payments ─────────────────────────────────

class LoanPaymentViewSet(viewsets.ModelViewSet):
    queryset = LoanPayment.objects.all()
    serializer_class = LoanPaymentSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(loan__user=self.request.user).order_by('-payment_date')

    def perform_create(self, serializer):
        loan_id = self.request.data.get('loan')
        try:
            loan = Loan.objects.get(
                id=loan_id, user=self.request.user,
                status__in=['APPROVED', 'ACTIVE']
            )
        except Loan.DoesNotExist:
            return

        amount = serializer.validated_data['amount_paid']
        new_remaining = max(Decimal('0'), loan.remaining_balance - amount)
        serializer.save(remaining_balance=new_remaining)

        loan.remaining_balance = new_remaining
        if new_remaining <= 0:
            loan.status = 'PAID'
            self._distribute_interest(loan)
        else:
            loan.status = 'ACTIVE'
        loan.save()

        profile, _ = UserProfile.objects.get_or_create(user=loan.user)
        profile.recalculate_loan_balance()

    def _distribute_interest(self, loan):
        """Split interest 50/50 between user savings and platform."""
        total_interest = loan.amount * loan.interest_rate / 100
        user_share = total_interest / 2
        platform_share = total_interest / 2

        InterestDistribution.objects.create(
            loan=loan,
            total_interest=total_interest,
            user_savings_share=user_share,
            platform_share=platform_share,
        )
        Transaction.objects.create(
            user=loan.user,
            amount=user_share,
            type='INTEREST_REWARD',
            status='COMPLETED',
            description=f'Interest reward from Loan #{loan.id}',
        )
        profile, _ = UserProfile.objects.get_or_create(user=loan.user)
        profile.recalculate_savings_balance()

        Notification.objects.create(
            user=loan.user,
            title='Loan Fully Repaid!',
            message=f'You earned MK {user_share} in interest rewards from your loan.',
            type='INTEREST_REWARD',
        )


# ─── Interest Distributions ───────────────────────

class InterestDistributionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = InterestDistribution.objects.all()
    serializer_class = InterestDistributionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(loan__user=self.request.user).order_by('-distributed_at')


# ─── Notifications ─────────────────────────────────

class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user).order_by('-created_at')

    @action(detail=True, methods=['post'])
    def mark_read(self, request, pk=None):
        notification = self.get_object()
        notification.is_read = True
        notification.save(update_fields=['is_read'])
        return Response({'status': 'marked as read'})

    @action(detail=False, methods=['post'])
    def mark_all_read(self, request):
        self.get_queryset().filter(is_read=False).update(is_read=True)
        return Response({'status': 'all marked as read'})


# ─── Reports ───────────────────────────────────────

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def financial_report(request):
    """Generate financial summary report for the authenticated user."""
    user = request.user
    profile, _ = UserProfile.objects.get_or_create(user=user)
    profile.recalculate_savings_balance()
    profile.recalculate_loan_balance()
    profile.calculate_financial_score()

    from django.db.models import Sum
    from django.db.models.functions import TruncMonth

    monthly_savings = (
        Transaction.objects.filter(user=user, type='DEPOSIT', status='COMPLETED')
        .annotate(month=TruncMonth('timestamp'))
        .values('month')
        .annotate(total=Sum('amount'))
        .order_by('month')
    )

    loans = Loan.objects.filter(user=user)
    total_loans_taken = loans.count()
    total_borrowed = loans.aggregate(total=Sum('amount'))['total'] or 0
    total_repaid = LoanPayment.objects.filter(loan__user=user).aggregate(
        total=Sum('amount_paid')
    )['total'] or 0

    total_penalties = Penalty.objects.filter(user=user).aggregate(
        total=Sum('amount')
    )['total'] or 0
    penalty_count = Penalty.objects.filter(user=user).count()

    return Response({
        'savings_balance': float(profile.savings_balance),
        'loan_balance': float(profile.loan_balance),
        'financial_score': profile.financial_score,
        'monthly_savings': [
            {'month': entry['month'].strftime('%Y-%m'), 'total': float(entry['total'])}
            for entry in monthly_savings
        ],
        'loans': {
            'total_taken': total_loans_taken,
            'total_borrowed': float(total_borrowed),
            'total_repaid': float(total_repaid),
        },
        'penalties': {
            'total_amount': float(total_penalties),
            'count': penalty_count,
        },
    })
