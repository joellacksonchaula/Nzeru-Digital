from rest_framework import viewsets, permissions, status, generics, serializers
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.contrib.auth.models import User
from django.db.models import Q, Sum
from django.db.models.functions import TruncMonth
from django.utils import timezone
from decimal import Decimal, InvalidOperation

from .models import (
    UserProfile, SavingsPlan, Transaction, Loan,
    LoanPayment, Penalty, InterestDistribution, Notification,
    IJCGroup, IJCMember, IJCTransaction, IJCAuditLog
)
from .serializers import (
    RegisterSerializer, UserSerializer, UserProfileSerializer,
    SavingsPlanSerializer, TransactionSerializer, LoanSerializer,
    LoanPaymentSerializer, PenaltySerializer, InterestDistributionSerializer,
    NotificationSerializer, IJCGroupSerializer, IJCMemberSerializer,
    IJCTransactionSerializer
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
    profile.recalculate_savings_balance()
    profile.recalculate_loan_balance()
    profile.calculate_financial_score()
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

    active_plans = SavingsPlan.objects.filter(user=user, is_active=True)
    trial_plans = active_plans.filter(is_trial=True)
    secret_plans = active_plans.filter(is_secret=True)
    normal_plans = active_plans.filter(is_secret=False, is_trial=False)

    active_loans = Loan.objects.filter(
        user=user, status__in=['APPROVED', 'ACTIVE']
    )
    active_loan_balance = sum(l.remaining_balance for l in active_loans)
    tracked_savings = sum(p.current_amount for p in active_plans)

    recent_txns = Transaction.objects.filter(user=user).order_by('-timestamp')[:10]
    unread_count = Notification.objects.filter(user=user, is_read=False).count()
    total_penalties = Penalty.objects.filter(user=user).aggregate(Sum('amount'))['amount__sum'] or 0
    trial_penalties = Penalty.objects.filter(
        user=user,
        plan__is_trial=True,
    ).aggregate(Sum('amount'))['amount__sum'] or 0

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
            'tracked_savings_balance': float(tracked_savings),
            'credit_balance': float(profile.loan_balance),
            'loan_balance': float(profile.loan_balance),
            'financial_score': profile.financial_score,
            'settings': profile.settings_payload(),
        },
        'savings_balance': float(profile.savings_balance),
        'tracked_savings_balance': float(tracked_savings),
        'real_savings_balance': float(profile.savings_balance),
        'total_savings': float(tracked_savings),
        'credit_balance': float(profile.loan_balance),
        'loan_balance': float(profile.loan_balance),
        'financial_score': profile.financial_score,
        'active_credit_balance': float(active_loan_balance),
        'active_loan_balance': float(active_loan_balance),
        'active_plans': normal_plans.count(),
        'trial_plans': trial_plans.count(),
        'trial_savings_balance': float(sum(p.current_amount for p in trial_plans)),
        'secret_savings_count': secret_plans.count(),
        'secret_savings_balance': float(
            sum(p.current_amount for p in secret_plans)
        ),
        'total_penalties': float(total_penalties),
        'trial_penalties': float(trial_penalties),
        'recent_transactions': TransactionSerializer(recent_txns, many=True).data,
        'plans': SavingsPlanSerializer(active_plans, many=True).data,
        'active_credit': LoanSerializer(active_loans.first()).data if active_loans.exists() else None,
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
        """Recalculate balances and score."""
        profile, _ = UserProfile.objects.get_or_create(user=request.user)
        profile.recalculate_savings_balance()
        profile.recalculate_loan_balance()
        profile.calculate_financial_score()
        return Response(UserProfileSerializer(profile).data)

    @action(detail=False, methods=['patch'])
    def settings(self, request):
        profile, _ = UserProfile.objects.get_or_create(user=request.user)
        payload = request.data
        simple_fields = [
            'preferred_theme',
            'preferred_language',
            'preferred_currency',
            'notifications_enabled',
            'transaction_alerts',
            'two_factor_enabled',
            'biometric_login_enabled',
            'auto_save_enabled',
            'credit_usage_preference',
            'app_feedback',
        ]
        for field in simple_fields:
            if field in payload:
                setattr(profile, field, payload[field])

        if 'payment_methods' in payload:
            methods = payload.get('payment_methods') or []
            if isinstance(methods, list):
                profile.payment_methods = ','.join(
                    str(item).strip() for item in methods if str(item).strip()
                )
            else:
                profile.payment_methods = str(methods)

        if 'default_savings_plan_id' in payload:
            plan_id = payload.get('default_savings_plan_id')
            profile.default_savings_plan = SavingsPlan.objects.filter(
                user=request.user,
                id=plan_id,
            ).first() if plan_id else None

        profile.save()
        return Response(profile.settings_payload())

    @action(detail=False, methods=['post'])
    def change_password(self, request):
        user = request.user
        current_password = request.data.get('current_password', '')
        new_password = request.data.get('new_password', '')
        if not user.check_password(current_password):
            raise serializers.ValidationError({
                'current_password': 'Current password is incorrect.'
            })
        if not new_password:
            raise serializers.ValidationError({
                'new_password': 'New password is required.'
            })
        user.set_password(new_password)
        user.save(update_fields=['password'])
        return Response({'status': 'password_updated'})


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

    @action(detail=True, methods=['post'])
    def simulate_penalty(self, request, pk=None):
        plan = self.get_object()
        amount = Decimal(str(request.data.get('amount', '250')))
        penalty = Penalty.objects.create(
            user=request.user,
            plan=plan,
            amount=amount,
            penalty_type='MONETARY',
            reason=request.data.get('reason') or 'Simulated penalty for testing.',
            is_applied=True,
        )
        if plan.current_amount > 0:
            plan.current_amount = max(Decimal('0'), plan.current_amount - amount)
            plan.save(update_fields=['current_amount'])
        if not plan.is_trial:
            profile, _ = UserProfile.objects.get_or_create(user=request.user)
            profile.recalculate_savings_balance()
        return Response(PenaltySerializer(penalty).data, status=status.HTTP_201_CREATED)


# ─── Transactions (Deposits) ──────────────────────

class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user).order_by('-timestamp')

    def create(self, request, *args, **kwargs):
        if request.data.get('type') == 'WITHDRAWAL':
            has_credit = request.user.loans.filter(
                status__in=['PENDING', 'APPROVED', 'ACTIVE']
            ).exists()
            if has_credit:
                Notification.objects.create(
                    user=request.user,
                    title='Withdrawal unavailable',
                    message='Withdrawal unavailable while outstanding debt exists.',
                    type='DEBT_ALERT',
                )
                return Response(
                    {
                        'detail': 'Withdrawal unavailable while outstanding debt exists.'
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )
            plan_id = request.data.get('plan')
            if plan_id:
                plan = SavingsPlan.objects.filter(user=request.user, id=plan_id).first()
                if not plan:
                    return Response(
                        {'detail': 'Savings plan not found.'},
                        status=status.HTTP_404_NOT_FOUND,
                    )
                if not plan.is_mature:
                    Notification.objects.create(
                        user=request.user,
                        title='Savings still locked',
                        message='Withdrawals are locked until your savings maturity date is reached.',
                        type='SAVINGS_REMINDER',
                    )
                    return Response(
                        {
                            'detail': 'Withdrawals are locked until your savings maturity date is reached.',
                            'maturity_date': plan.end_date,
                            'days_remaining': plan.days_until_maturity,
                        },
                        status=status.HTTP_400_BAD_REQUEST,
                    )
        return super().create(request, *args, **kwargs)

    def perform_create(self, serializer):
        txn = serializer.save(user=self.request.user)
        if txn.plan and txn.type == 'DEPOSIT':
            plan = txn.plan
            plan.current_amount += txn.amount
            plan.save(update_fields=['current_amount'])
            Notification.objects.create(
                user=self.request.user,
                title='Deposit received',
                message=f'MK {txn.amount} was added to {plan.title}.',
                type='DEPOSIT_RECEIVED',
            )
            if plan.goal_amount > 0 and plan.current_amount >= plan.goal_amount:
                Notification.objects.create(
                    user=self.request.user,
                    title='Savings goal achieved',
                    message=f'{plan.title} has reached its savings goal.',
                    type='GOAL_ACHIEVED',
                )
        elif txn.plan and txn.type in ['WITHDRAWAL', 'PENALTY']:
            plan = txn.plan
            plan.current_amount = max(Decimal('0'), plan.current_amount - txn.amount)
            plan.save(update_fields=['current_amount'])

        if not (txn.plan and txn.plan.is_trial):
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
        """Create a credit request with 40% tracked savings eligibility."""
        plan = serializer.validated_data.get('plan')
        amount = serializer.validated_data['amount']
        interest_rate = serializer.validated_data.get('interest_rate', Decimal('10'))
        tracked_savings = plan.current_amount if plan else sum(
            item.current_amount
            for item in SavingsPlan.objects.filter(user=self.request.user, is_active=True)
        )
        max_credit = Decimal(str(tracked_savings)) * Decimal('0.40')
        if amount > max_credit:
            raise serializers.ValidationError({
                'amount': 'Requested credit exceeds 40% of tracked savings.'
            })
        if self.request.user.loans.filter(status__in=['PENDING', 'APPROVED', 'ACTIVE']).exists():
            raise serializers.ValidationError({
                'detail': 'Only one outstanding credit request is allowed at a time.'
            })
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
    """Check how much the user is eligible to access as credit (40% of tracked savings)."""
    profile, _ = UserProfile.objects.get_or_create(user=request.user)
    profile.recalculate_savings_balance()
    plan_id = request.query_params.get('plan')
    selected_plan = SavingsPlan.objects.filter(user=request.user, id=plan_id).first() if plan_id else None
    tracked_savings = float(
        selected_plan.current_amount if selected_plan else sum(
            plan.current_amount
            for plan in SavingsPlan.objects.filter(user=request.user, is_active=True)
        )
    )
    max_loan = tracked_savings * 0.4
    has_active_loan = request.user.loans.filter(
        status__in=['PENDING', 'APPROVED', 'ACTIVE']
    ).exists()
    return Response({
        'savings_balance': float(profile.savings_balance),
        'tracked_savings_balance': tracked_savings,
        'selected_plan_id': str(selected_plan.id) if selected_plan else None,
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
            plan=loan.plan,
            amount=user_share,
            type='INTEREST_REWARD',
            status='COMPLETED',
            description=f'Interest reward from Credit #{loan.id}',
        )
        if loan.plan:
            loan.plan.current_amount += user_share
            loan.plan.save(update_fields=['current_amount'])
        profile, _ = UserProfile.objects.get_or_create(user=loan.user)
        if not loan.is_trial:
            profile.recalculate_savings_balance()

        Notification.objects.create(
            user=loan.user,
            title='Credit Fully Repaid!',
            message=f'You earned MK {user_share} in interest rewards from your credit.',
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


class IJCGroupViewSet(viewsets.ModelViewSet):
    queryset = IJCGroup.objects.all()
    serializer_class = IJCGroupSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return self.queryset.filter(
            Q(owner=self.request.user) |
            Q(members__user=self.request.user, members__status__in=['PENDING', 'APPROVED']),
            is_active=True,
        ).distinct().order_by('-created_at')

    def perform_create(self, serializer):
        group = serializer.save(owner=self.request.user)
        IJCMember.objects.create(
            group=group,
            user=self.request.user,
            role='OWNER',
            status='APPROVED',
            approved_at=timezone.now(),
        )
        IJCAuditLog.objects.create(
            group=group,
            actor=self.request.user,
            action='IJC_CREATED',
            metadata={'cash_out_policy': group.cash_out_policy},
        )

    def perform_update(self, serializer):
        group = self.get_object()
        self._require_owner(group)
        updated = serializer.save()
        IJCAuditLog.objects.create(
            group=updated,
            actor=self.request.user,
            action='IJC_SETTINGS_UPDATED',
            metadata={},
        )

    def destroy(self, request, *args, **kwargs):
        group = self.get_object()
        self._require_owner(group)
        group.is_active = False
        group.save(update_fields=['is_active'])
        IJCAuditLog.objects.create(
            group=group,
            actor=request.user,
            action='IJC_DEACTIVATED',
            metadata={},
        )
        return Response(status=status.HTTP_204_NO_CONTENT)

    def _membership(self, group):
        return group.members.filter(user=self.request.user).first()

    def _require_owner(self, group):
        membership = self._membership(group)
        if not membership or membership.role != 'OWNER' or membership.status != 'APPROVED':
            raise serializers.ValidationError({
                'detail': 'Only the IJC owner can perform this action.'
            })
        return membership

    @staticmethod
    def _parse_amount(value, field_name='amount'):
        try:
            return Decimal(str(value))
        except (InvalidOperation, TypeError, ValueError):
            raise serializers.ValidationError({
                field_name: 'Enter a valid amount.'
            })

    @action(detail=False, methods=['post'])
    def join(self, request):
        code = str(request.data.get('code', '')).strip().upper()
        if not code:
            raise serializers.ValidationError({'code': 'IJC ID or join code is required.'})
        group = IJCGroup.objects.filter(ijc_id=code).first() or IJCGroup.objects.filter(join_code=code).first()
        if not group:
            return Response({'detail': 'IJC not found.'}, status=status.HTTP_404_NOT_FOUND)
        membership, created = IJCMember.objects.get_or_create(
            group=group,
            user=request.user,
            defaults={'role': 'MEMBER', 'status': 'PENDING'},
        )
        notify_owner = created
        if not created and membership.status == 'REJECTED':
            membership.status = 'PENDING'
            membership.save(update_fields=['status'])
            notify_owner = True
        if notify_owner and request.user != group.owner:
            Notification.objects.create(
                user=group.owner,
                title='IJC member request',
                message=f'{request.user.get_full_name() or request.user.username} requested to join {group.name}.',
                type='IJC_MEMBER_JOINED',
            )
            IJCAuditLog.objects.create(
                group=group,
                actor=request.user,
                action='IJC_JOIN_REQUESTED',
                metadata={'status': membership.status},
            )
        return Response(IJCGroupSerializer(group, context={'request': request}).data)

    @action(detail=True, methods=['post'])
    def approve_member(self, request, pk=None):
        group = self.get_object()
        self._require_owner(group)
        member_id = request.data.get('member_id')
        member = group.members.filter(id=member_id, role='MEMBER').first()
        if not member:
            return Response({'detail': 'Member request not found.'}, status=status.HTTP_404_NOT_FOUND)
        member.status = 'APPROVED'
        member.approved_at = timezone.now()
        member.save(update_fields=['status', 'approved_at'])
        Notification.objects.create(
            user=member.user,
            title='IJC membership approved',
            message=f'You can now contribute to {group.name}.',
            type='IJC_MEMBER_JOINED',
        )
        IJCAuditLog.objects.create(
            group=group,
            actor=request.user,
            action='IJC_MEMBER_APPROVED',
            metadata={'member_id': member.id},
        )
        return Response(IJCMemberSerializer(member).data)

    @action(detail=True, methods=['post'])
    def deposit(self, request, pk=None):
        group = self.get_object()
        membership = self._membership(group)
        if not membership or membership.status != 'APPROVED':
            raise serializers.ValidationError({
                'detail': 'Only approved members can deposit into this IJC.'
            })
        amount = self._parse_amount(request.data.get('amount', '0'))
        if amount <= 0:
            raise serializers.ValidationError({'amount': 'Deposit amount must be greater than zero.'})
        txn = IJCTransaction.objects.create(
            group=group,
            user=request.user,
            amount=amount,
            type='DEPOSIT',
            description=request.data.get('description', ''),
        )
        group.balance += amount
        group.save(update_fields=['balance'])
        membership.total_contributed += amount
        membership.save(update_fields=['total_contributed'])
        Notification.objects.create(
            user=group.owner,
            title='IJC deposit received',
            message=f'MK {amount} was deposited into {group.name}.',
            type='IJC_DEPOSIT_RECEIVED',
        )
        if group.goal_amount > 0 and group.balance >= group.goal_amount:
            for member in group.members.filter(status='APPROVED'):
                Notification.objects.create(
                    user=member.user,
                    title='IJC goal reached',
                    message=f'{group.name} reached its group savings goal.',
                    type='IJC_GOAL_REACHED',
                )
        IJCAuditLog.objects.create(
            group=group,
            actor=request.user,
            action='IJC_DEPOSIT_CREATED',
            metadata={'amount': str(amount)},
        )
        return Response(IJCTransactionSerializer(txn).data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['post'])
    def withdraw(self, request, pk=None):
        group = self.get_object()
        self._require_owner(group)
        if not group.cash_out_available:
            return Response(
                {
                    'detail': 'IJC cash-out is locked until the selected schedule is reached.',
                    'next_cash_out_date': group.next_cash_out_date,
                    'days_remaining': group.days_until_cash_out,
                },
                status=status.HTTP_400_BAD_REQUEST,
            )
        amount = self._parse_amount(request.data.get('amount', '0'))
        if amount <= 0:
            raise serializers.ValidationError({'amount': 'Withdrawal amount must be greater than zero.'})
        if amount > group.balance:
            raise serializers.ValidationError({'amount': 'Withdrawal exceeds group balance.'})
        txn = IJCTransaction.objects.create(
            group=group,
            user=request.user,
            amount=amount,
            type='WITHDRAWAL',
            description=request.data.get('description', ''),
        )
        group.balance -= amount
        group.last_cash_out_at = timezone.now()
        group.save(update_fields=['balance', 'last_cash_out_at'])
        for member in group.members.filter(status='APPROVED'):
            Notification.objects.create(
                user=member.user,
                title='IJC withdrawal completed',
                message=f'MK {amount} was withdrawn from {group.name}.',
                type='IJC_WITHDRAWAL_COMPLETED',
            )
        IJCAuditLog.objects.create(
            group=group,
            actor=request.user,
            action='IJC_WITHDRAWAL_CREATED',
            metadata={'amount': str(amount)},
        )
        return Response(IJCTransactionSerializer(txn).data, status=status.HTTP_201_CREATED)


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
    tracked_savings = sum(
        plan.current_amount
        for plan in SavingsPlan.objects.filter(user=user, is_active=True)
    )
    trial_savings = sum(
        plan.current_amount
        for plan in SavingsPlan.objects.filter(user=user, is_active=True, is_trial=True)
    )

    return Response({
        'savings_balance': float(profile.savings_balance),
        'tracked_savings_balance': float(tracked_savings),
        'trial_savings_balance': float(trial_savings),
        'credit_balance': float(profile.loan_balance),
        'loan_balance': float(profile.loan_balance),
        'financial_score': profile.financial_score,
        'monthly_savings': [
            {'month': entry['month'].strftime('%Y-%m'), 'total': float(entry['total'])}
            for entry in monthly_savings
        ],
        'credits': {
            'total_taken': total_loans_taken,
            'total_borrowed': float(total_borrowed),
            'total_repaid': float(total_repaid),
        },
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
