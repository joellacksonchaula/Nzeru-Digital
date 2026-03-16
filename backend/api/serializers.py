from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
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
            attrs['user'] = user
            return super().validate(attrs)
        else:
            raise serializers.ValidationError('Invalid credentials')


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
        UserProfile.objects.create(user=user, phone=phone)
        return user


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']


class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = UserProfile
        fields = '__all__'


class SavingsPlanSerializer(serializers.ModelSerializer):
    progress_percent = serializers.ReadOnlyField()

    class Meta:
        model = SavingsPlan
        fields = '__all__'
        read_only_fields = ['user', 'current_amount']


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

    class Meta:
        model = Loan
        fields = '__all__'
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
