from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password
from django.utils import timezone
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.exceptions import AuthenticationFailed
from datetime import timedelta
from .models import (
    UserProfile, SavingsPlan, Transaction, Loan,
    LoanPayment, Penalty, InterestDistribution, Notification
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
