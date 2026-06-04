from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0007_profile_settings_credit_fields_and_trial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AlterField(
            model_name='notification',
            name='type',
            field=models.CharField(choices=[('SAVINGS_REMINDER', 'Savings Reminder'), ('SAVINGS_MISSED', 'Savings Missed'), ('SAVINGS_MILESTONE', 'Savings Milestone'), ('GOAL_ACHIEVED', 'Goal Achieved'), ('DEPOSIT_RECEIVED', 'Deposit Received'), ('WITHDRAWAL_UNLOCK', 'Withdrawal Unlock'), ('DEBT_ALERT', 'Debt Alert'), ('SECURITY_ALERT', 'Security Alert'), ('PENALTY_APPLIED', 'Penalty Applied'), ('LOAN_ELIGIBLE', 'Loan Eligible'), ('LOAN_APPROVED', 'Loan Approved'), ('LOAN_REPAYMENT', 'Loan Repayment Reminder'), ('INTEREST_REWARD', 'Interest Reward'), ('IJC_MEMBER_JOINED', 'IJC Member Joined'), ('IJC_DEPOSIT_RECEIVED', 'IJC Deposit Received'), ('IJC_GOAL_REACHED', 'IJC Goal Reached'), ('IJC_CASHOUT_AVAILABLE', 'IJC Cash-Out Available'), ('IJC_WITHDRAWAL_COMPLETED', 'IJC Withdrawal Completed'), ('GENERAL', 'General')], default='GENERAL', max_length=30),
        ),
        migrations.CreateModel(
            name='IJCGroup',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=140)),
                ('ijc_id', models.CharField(editable=False, max_length=20, unique=True)),
                ('join_code', models.CharField(editable=False, max_length=12, unique=True)),
                ('goal_amount', models.DecimalField(decimal_places=2, default=0, max_digits=12)),
                ('balance', models.DecimalField(decimal_places=2, default=0, max_digits=12)),
                ('cash_out_policy', models.CharField(choices=[('DAILY', 'Daily Cash-Out'), ('WEEKLY', 'Weekly Cash-Out'), ('MONTHLY', 'Monthly Cash-Out')], default='WEEKLY', max_length=10)),
                ('last_cash_out_at', models.DateTimeField(blank=True, null=True)),
                ('is_active', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('owner', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='owned_ijc_groups', to=settings.AUTH_USER_MODEL)),
            ],
            options={'ordering': ['-created_at']},
        ),
        migrations.CreateModel(
            name='IJCMember',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('role', models.CharField(choices=[('OWNER', 'Owner'), ('MEMBER', 'Member')], default='MEMBER', max_length=10)),
                ('status', models.CharField(choices=[('PENDING', 'Pending Approval'), ('APPROVED', 'Approved'), ('REJECTED', 'Rejected')], default='PENDING', max_length=10)),
                ('total_contributed', models.DecimalField(decimal_places=2, default=0, max_digits=12)),
                ('joined_at', models.DateTimeField(auto_now_add=True)),
                ('approved_at', models.DateTimeField(blank=True, null=True)),
                ('group', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='members', to='api.ijcgroup')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='ijc_memberships', to=settings.AUTH_USER_MODEL)),
            ],
            options={'ordering': ['-total_contributed', 'joined_at'], 'unique_together': {('group', 'user')}},
        ),
        migrations.CreateModel(
            name='IJCTransaction',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('amount', models.DecimalField(decimal_places=2, max_digits=12)),
                ('type', models.CharField(choices=[('DEPOSIT', 'Deposit'), ('WITHDRAWAL', 'Withdrawal')], max_length=10)),
                ('description', models.TextField(blank=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('group', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='transactions', to='api.ijcgroup')),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='ijc_transactions', to=settings.AUTH_USER_MODEL)),
            ],
            options={'ordering': ['-created_at']},
        ),
        migrations.CreateModel(
            name='IJCAuditLog',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('action', models.CharField(max_length=120)),
                ('metadata', models.JSONField(blank=True, default=dict)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('actor', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
                ('group', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='audit_logs', to='api.ijcgroup')),
            ],
            options={'ordering': ['-created_at']},
        ),
    ]
