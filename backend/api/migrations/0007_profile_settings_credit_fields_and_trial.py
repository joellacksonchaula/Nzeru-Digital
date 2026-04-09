from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0006_alter_savingsplan_amount_per_period'),
    ]

    operations = [
        migrations.AddField(
            model_name='savingsplan',
            name='is_trial',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='loan',
            name='locked_amount',
            field=models.DecimalField(decimal_places=2, default=0, max_digits=10),
        ),
        migrations.AddField(
            model_name='loan',
            name='plan',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='credits', to='api.savingsplan'),
        ),
        migrations.AddField(
            model_name='loan',
            name='withdrawal_mode',
            field=models.CharField(choices=[('INSTANT', 'All At Once'), ('DAILY', 'Daily Locked Amount'), ('WEEKLY', 'Weekly Locked Amount')], default='INSTANT', max_length=10),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='app_feedback',
            field=models.TextField(blank=True, default=''),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='auto_save_enabled',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='biometric_login_enabled',
            field=models.BooleanField(default=False),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='credit_usage_preference',
            field=models.CharField(default='flexible', max_length=20),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='default_savings_plan',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='default_for_profiles', to='api.savingsplan'),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='notifications_enabled',
            field=models.BooleanField(default=True),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='payment_methods',
            field=models.TextField(blank=True, default=''),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='preferred_currency',
            field=models.CharField(default='MWK', max_length=10),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='preferred_language',
            field=models.CharField(default='en', max_length=20),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='preferred_theme',
            field=models.CharField(default='system', max_length=20),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='transaction_alerts',
            field=models.BooleanField(default=True),
        ),
        migrations.AddField(
            model_name='userprofile',
            name='two_factor_enabled',
            field=models.BooleanField(default=False),
        ),
    ]
