from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0008_ijc_groups_and_notifications'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AlterField(
            model_name='notification',
            name='type',
            field=models.CharField(choices=[('SAVINGS_REMINDER', 'Savings Reminder'), ('SAVINGS_MISSED', 'Savings Missed'), ('SAVINGS_MILESTONE', 'Savings Milestone'), ('GOAL_ACHIEVED', 'Goal Achieved'), ('DEPOSIT_RECEIVED', 'Deposit Received'), ('WITHDRAWAL_UNLOCK', 'Withdrawal Unlock'), ('DEBT_ALERT', 'Debt Alert'), ('SECURITY_ALERT', 'Security Alert'), ('PENALTY_APPLIED', 'Penalty Applied'), ('LOAN_ELIGIBLE', 'Loan Eligible'), ('LOAN_APPROVED', 'Loan Approved'), ('LOAN_REPAYMENT', 'Loan Repayment Reminder'), ('INTEREST_REWARD', 'Interest Reward'), ('IJC_MEMBER_JOINED', 'IJC Member Joined'), ('IJC_DEPOSIT_RECEIVED', 'IJC Deposit Received'), ('IJC_POLICY_UPDATED', 'IJC Policy Updated'), ('IJC_LIMIT_REACHED', 'IJC Limit Reached'), ('IJC_LIMIT_ATTEMPT', 'IJC Limit Attempt'), ('IJC_ALLOWANCE_RESET', 'IJC Allowance Reset'), ('IJC_WITHDRAWAL_COMPLETED', 'IJC Withdrawal Completed'), ('GENERAL', 'General')], default='GENERAL', max_length=30),
        ),
        migrations.AddField(
            model_name='ijcgroup',
            name='allow_rollover',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='ijcgroup',
            name='controller',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='controlled_ijc_groups', to=settings.AUTH_USER_MODEL),
        ),
        migrations.AddField(
            model_name='ijcgroup',
            name='daily_limit',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=12),
        ),
        migrations.AddField(
            model_name='ijcgroup',
            name='monthly_limit',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=12),
        ),
        migrations.AddField(
            model_name='ijcgroup',
            name='reset_type',
            field=models.CharField(choices=[('MIDNIGHT', 'Calendar Midnight'), ('ROLLING_24H', 'Rolling 24 Hours')], default='MIDNIGHT', max_length=12),
        ),
        migrations.AddField(
            model_name='ijcgroup',
            name='weekly_limit',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=12),
        ),
        migrations.AddField(
            model_name='ijctransaction',
            name='client_reference',
            field=models.CharField(blank=True, max_length=80, null=True),
        ),
        migrations.AlterField(
            model_name='ijcmember',
            name='role',
            field=models.CharField(choices=[('USER', 'User'), ('CONTROLLER', 'Controller'), ('OWNER', 'Owner'), ('MEMBER', 'Member')], default='MEMBER', max_length=10),
        ),
        migrations.AddConstraint(
            model_name='ijctransaction',
            constraint=models.UniqueConstraint(condition=models.Q(client_reference__isnull=False), fields=('group', 'client_reference'), name='unique_ijc_transaction_reference'),
        ),
    ]
