from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password
from django.utils import timezone
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.exceptions import AuthenticationFailed
from datetime import timedelta
from .models import (
    UserProfile, SavingsPlan, Transaction, Loan,
    LoanPayment, Penalty, InterestDistribution, Notification,
    IJCGroup, IJCMember, IJCTransaction, IJCAuditLog
)


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        username = attrs.get('username')
        password = attrs.get('password')

        # Try to authenticate with username or email
        user = None
        if '@' in username:
            try:
                user = User.objects.get(email=username)
            except User.DoesNotExist:
                pass
        else:
            try:
                user = User.objects.get(username=username)
            except User.DoesNotExist:
                pass

        if user and user.check_password(password):
            attrs['username'] = user.username  # Set to actual username for super()
            return super().validate(attrs)
        else:
            raise AuthenticationFailed('Invalid credentials')


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True)
    phone = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'password2', 'first_name', 'last_name', 'phone']

    def validate(self, attrs):
        if attrs['password'] != attrs.pop('password2'):
            raise serializers.ValidationError({"password": "Passwords do not match."})
        return attrs

    def create(self, validated_data):
        phone = validated_data.pop('phone', '')
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', ''),
        )
        profile = UserProfile.objects.create(user=user, phone=phone)
        start = timezone.now()
        trial_plan = SavingsPlan.objects.create(
            user=user,
            title='Trial Savings Plan',
            amount_per_period='2500.00',
            frequency='WEEKLY',
            duration_months=3,
            start_date=start,
            end_date=start + timedelta(days=90),
            penalty_policy='MONETARY',
            goal_amount='30000.00',
            is_trial=True,
        )
        profile.default_savings_plan = trial_plan
        profile.save(update_fields=['default_savings_plan'])
        return user


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']


class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    settings = serializers.SerializerMethodField()
    credit_balance = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = [
            'id',
            'user',
            'phone',
            'savings_balance',
            'loan_balance',
            'financial_score',
            'preferred_theme',
            'preferred_language',
            'preferred_currency',
            'notifications_enabled',
            'transaction_alerts',
            'two_factor_enabled',
            'biometric_login_enabled',
            'auto_save_enabled',
            'credit_usage_preference',
            'payment_methods',
            'app_feedback',
            'default_savings_plan',
            'settings',
            'credit_balance',
        ]

    def get_settings(self, obj):
        return obj.settings_payload()

    def get_credit_balance(self, obj):
        return obj.loan_balance


class SavingsPlanSerializer(serializers.ModelSerializer):
    progress_percent = serializers.ReadOnlyField()
    is_mature = serializers.ReadOnlyField()
    days_until_maturity = serializers.ReadOnlyField()
    lock_status = serializers.ReadOnlyField()
    goal_lock_remaining_amount = serializers.ReadOnlyField()
    is_goal_locked = serializers.ReadOnlyField()

    class Meta:
        model = SavingsPlan
        fields = '__all__'
        read_only_fields = ['user', 'current_amount', 'created_at']


class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = '__all__'
        read_only_fields = ['user']


class PenaltySerializer(serializers.ModelSerializer):
    class Meta:
        model = Penalty
        fields = '__all__'
        read_only_fields = ['user']


class LoanSerializer(serializers.ModelSerializer):
    total_with_interest = serializers.ReadOnlyField()
    monthly_payment = serializers.ReadOnlyField()
    repayment_progress = serializers.ReadOnlyField()
    is_trial = serializers.ReadOnlyField()

    class Meta:
        model = Loan
        fields = [
            'id',
            'user',
            'plan',
            'amount',
            'interest_rate',
            'duration_months',
            'withdrawal_mode',
            'locked_amount',
            'status',
            'approved_date',
            'due_date',
            'remaining_balance',
            'created_at',
            'total_with_interest',
            'monthly_payment',
            'repayment_progress',
            'is_trial',
        ]
        read_only_fields = ['user', 'remaining_balance', 'approved_date', 'status']


class LoanPaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = LoanPayment
        fields = '__all__'


class InterestDistributionSerializer(serializers.ModelSerializer):
    class Meta:
        model = InterestDistribution
        fields = '__all__'


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = '__all__'
        read_only_fields = ['user']


class IJCMemberSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()
    user_email = serializers.SerializerMethodField()

    class Meta:
        model = IJCMember
        fields = [
            'id',
            'group',
            'user',
            'user_name',
            'user_email',
            'role',
            'status',
            'total_contributed',
            'joined_at',
            'approved_at',
        ]
        read_only_fields = [
            'group',
            'user',
            'user_name',
            'user_email',
            'role',
            'total_contributed',
            'joined_at',
            'approved_at',
        ]

    def get_user_name(self, obj):
        return obj.user.get_full_name() or obj.user.username

    def get_user_email(self, obj):
        return obj.user.email


class IJCTransactionSerializer(serializers.ModelSerializer):
    user_name = serializers.SerializerMethodField()

    class Meta:
        model = IJCTransaction
        fields = [
            'id',
            'group',
            'user',
            'user_name',
            'amount',
            'type',
            'description',
            'client_reference',
            'created_at',
        ]
        read_only_fields = ['group', 'user', 'user_name', 'type', 'created_at']

    def get_user_name(self, obj):
        return obj.user.get_full_name() or obj.user.username


class IJCAuditLogSerializer(serializers.ModelSerializer):
    actor_name = serializers.SerializerMethodField()

    class Meta:
        model = IJCAuditLog
        fields = ['id', 'group', 'actor', 'actor_name', 'action', 'metadata', 'created_at']
        read_only_fields = fields

    def get_actor_name(self, obj):
        if not obj.actor:
            return ''
        return obj.actor.get_full_name() or obj.actor.username


class IJCGroupSerializer(serializers.ModelSerializer):
    members = IJCMemberSerializer(many=True, read_only=True)
    transactions = IJCTransactionSerializer(many=True, read_only=True)
    audit_logs = IJCAuditLogSerializer(many=True, read_only=True)
    owner_name = serializers.SerializerMethodField()
    controller_name = serializers.SerializerMethodField()
    pocket_id = serializers.ReadOnlyField(source='ijc_id')
    member_count = serializers.SerializerMethodField()
    current_user_role = serializers.SerializerMethodField()
    current_user_status = serializers.SerializerMethodField()
    total_credit_amount = serializers.SerializerMethodField()
    # allow release_amount to be set on create/update for SELF pockets
    release_frequency = serializers.ReadOnlyField(source='cash_out_policy')
    available_balance = serializers.ReadOnlyField()
    released_balance = serializers.ReadOnlyField(source='available_balance')
    locked_balance = serializers.ReadOnlyField()
    next_release_date = serializers.ReadOnlyField()
    next_cash_out_date = serializers.ReadOnlyField()
    cash_out_available = serializers.ReadOnlyField()
    days_until_cash_out = serializers.ReadOnlyField()
    progress_percent = serializers.ReadOnlyField()
    daily_spent = serializers.ReadOnlyField()
    weekly_spent = serializers.ReadOnlyField()
    monthly_spent = serializers.ReadOnlyField()
    available_today = serializers.ReadOnlyField()
    next_daily_reset_at = serializers.ReadOnlyField()

    class Meta:
        model = IJCGroup
        fields = [
            'id',
            'owner',
            'owner_name',
            'controller',
            'controller_name',
            'name',
            'ijc_id',
            'pocket_id',
            'join_code',
            'pocket_type',
            'goal_amount',
            'total_amount',
            'total_credit_amount',
            'balance',
            'released_balance',
            'release_amount',
            'is_paused',
            'release_frequency',
            'locked_balance',
            'last_cash_out_at',
            'daily_limit',
            'weekly_limit',
            'monthly_limit',
            'reset_type',
            'allow_rollover',
            'next_release_date',
            'next_cash_out_date',
            'cash_out_available',
            'days_until_cash_out',
            'progress_percent',
            'daily_spent',
            'weekly_spent',
            'monthly_spent',
            'available_balance',
            'available_today',
            'next_daily_reset_at',
            'is_active',
            'created_at',
            'member_count',
            'current_user_role',
            'current_user_status',
            'members',
            'transactions',
            'audit_logs',
        ]
        read_only_fields = [
            'owner',
            'controller',
            'ijc_id',
            'pocket_id',
            'join_code',
            'balance',
            'last_cash_out_at',
            'is_active',
            'created_at',
            'release_frequency',
            'available_balance',
            'locked_balance',
            'next_release_date',
        ]

    def get_owner_name(self, obj):
        return obj.owner.get_full_name() or obj.owner.username

    def get_controller_name(self, obj):
        if not obj.controller:
            return ''
        return obj.controller.get_full_name() or obj.controller.username

    def get_member_count(self, obj):
        return obj.members.filter(status='APPROVED').count()

    def _current_membership(self, obj):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return None
        return obj.members.filter(user=request.user).first()

    def get_current_user_role(self, obj):
        membership = self._current_membership(obj)
        return membership.role if membership else None

    def get_current_user_status(self, obj):
        membership = self._current_membership(obj)
        return membership.status if membership else None

    def get_total_credit_amount(self, obj):
        # Prefer explicit total_amount field, fall back to legacy goal_amount
        try:
            return float(obj.total_amount)
        except Exception:
            return float(obj.goal_amount)

    def validate(self, attrs):
        pocket_type = attrs.get('pocket_type', getattr(self.instance, 'pocket_type', 'SPONSORED'))
        total_amount = attrs.get('total_amount', getattr(self.instance, 'total_amount', 0))
        release_amount = attrs.get('release_amount', getattr(self.instance, 'release_amount', 0))
        if pocket_type == 'SELF' and (total_amount <= 0 or release_amount <= 0):
            raise serializers.ValidationError({
                'detail': 'Self pockets require total_amount and release_amount.',
            })
        return attrs
