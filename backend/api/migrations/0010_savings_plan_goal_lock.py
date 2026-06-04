from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0009_ijc_credit_control_policy'),
    ]

    operations = [
        migrations.AddField(
            model_name='savingsplan',
            name='goal_lock_enabled',
            field=models.BooleanField(default=False),
        ),
    ]
